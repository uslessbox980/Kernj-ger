/// @description Physics modules
/// Each function is a single, independent force calculator.
/// Modules only READ from their inputs and WRITE to physics_state.force_x / force_y.
/// They never read each other, call each other, or touch x/y directly.
///
/// All values are tuned for 60 steps per second (GMS2 default game speed).
///
/// WHICH MODULES TO CALL PER VEHICLE TYPE:
///   Aircraft (player / AI jet) : Apply_Gravity, Apply_Lift, Apply_Thrust, Apply_Drag, Apply_Rotation
///   Ground vehicle             : Apply_Gravity                (no lift, no rotation module)
///   Turret                     : Apply_Gravity                (no lift, no thrust)
///   Hovercraft                 : Apply_Gravity, Apply_Lift    (constant lift regardless of speed — tweak lift_coef to 1.0)
///
/// The SOLVER decides which modules to call. The modules themselves never care.

// ============================================================
//  PHYSICS STATE STRUCT
//  One instance per object. Created once in the Create event.
//  Carries all the persistent physics data between steps.
// ============================================================

/// @function Physics_State()
/// @description Create with:  physics_state = new Physics_State();
function Physics_State() constructor {
    // Velocity: how many pixels the object moves per step
    velocity_x       = 0;
    velocity_y       = 0;

    // Force accumulator: reset to 0 each step, then each module adds its contribution.
    // After all modules run, the solver converts this into velocity.
    force_x          = 0;
    force_y          = 0;

    // The direction the object is currently FACING (degrees).
    // GMS2 convention: 0 = right, 90 = up, 180 = left, 270 = down.
    heading          = 0;

    // Turning inertia: current rotation speed in degrees per step.
    // Stored here so turning feels weighted rather than instant.
    angular_velocity = 0;

    // Speed: the total magnitude of velocity (pixels per step).
    // Recalculated by Physics_Commit each step. Modules read this for lift and drag.
    speed            = 0;
}

/// @function Physics_State_Reset(physics_state)
/// @param {Struct} physics_state
/// @description Zeros the force accumulator. Call at the VERY START of every Step,
///              before any module runs. Velocity and heading are NOT reset here —
///              they persist across steps by design.
function Physics_State_Reset(physics_state) {
    physics_state.force_x = 0;
    physics_state.force_y = 0;
}

// ============================================================
//  MODULE: GRAVITY
//  Suitable for: ALL vehicles (aircraft, ground, turret, hovercraft)
// ============================================================

/// @function Apply_Gravity(physics_state, vehicle_stats)
/// @param {Struct} physics_state
/// @param {Struct} vehicle_stats   Any stats struct that has aircraft_gravity_scale
/// @description Applies a constant downward force every step.
///              This is ONLY gravity — it knows nothing about lift or flight.
///              gravity_pixels_per_step is tuned for 60 steps/s.
///              Adjust aircraft_gravity_scale per vehicle (1.0 = normal, 0.5 = light, 0.0 = ignore gravity).
function Apply_Gravity(physics_state, vehicle_stats) {
    // At 60 steps/s, ~0.27 pixels/step feels like gentle arcade gravity.
    // Increase for heavier/faster-falling feel. Decrease for floatier feel.
    var _gravity_per_step = global.gravity;

    // GMS2's Y axis points downward, so positive Y = falling down.
    physics_state.force_y += _gravity_per_step * vehicle_stats.aircraft_gravity_scale;
}

// ============================================================
//  MODULE: LIFT
//  Suitable for: Aircraft, Hovercraft
//  Do NOT call this for ground vehicles or turrets.
// ============================================================

/// @function Apply_Lift(physics_state, aircraft_stats)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats  Must have: aircraft_stall_speed, aircraft_max_speed, aircraft_lift_coef
/// @description Applies an upward force that counteracts gravity.
///              Lift is speed-dependent:
///                - At or below stall speed  → zero lift  (the aircraft falls)
///                - Between stall and max    → lift scales up linearly
///                - At max speed             → lift equals (gravity * lift_coef)
///              aircraft_lift_coef = 1.0 means full lift cancels gravity at max speed.
///              aircraft_lift_coef < 1.0 means the aircraft still sinks slightly even at full speed.
function Apply_Lift(physics_state, aircraft_stats) {
    // How far are we between stall speed and max speed? (0.0 to 1.0)
	
	
	var _horizontal_factor = abs(cos(degtorad(physics_state.heading)));
	var _speed_factor = clamp(speed / aircraft_stats.aircraft_max_speed, 0, 1);
	
	var _lift_force = _horizontal_factor * (_speed_factor * aircraft_stats.aircraft_lift_coef* aircraft_stats.aircraft_gravity_scale);

    _lift_force = min(_lift_force, global.gravity);

    // Lift is upward — negative Y in GMS2.
    physics_state.force_y -= _lift_force;
}

// ============================================================
//  MODULE: THRUST
//  Suitable for: Aircraft, Hovercraft, Ground vehicle (forward force)
// ============================================================

/// @function Apply_Thrust(physics_state, aircraft_stats, input_struct)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats  Must have: aircraft_acceleration, aircraft_mass
/// @param {Struct} input_struct    Must have: thrust_input (0 = off, 1 = pressed, 2 = held)
/// @description Pushes the object in its current heading direction when thrust input is active.
///              Force magnitude = acceleration * mass, applied once per step.
function Apply_Thrust(physics_state, aircraft_stats, input_struct) {
    if (input_struct.thrust_input <= 0) exit;

    var _thrust_force = aircraft_stats.aircraft_acceleration * aircraft_stats.aircraft_mass;

    // lengthdir_x/y decompose a magnitude+angle into X and Y components.
    // lengthdir_y is negated because GMS2's Y axis is flipped vs standard math convention.
    physics_state.force_x += lengthdir_x(_thrust_force, physics_state.heading);
    physics_state.force_y += lengthdir_y(_thrust_force, physics_state.heading);
}

// ============================================================
//  MODULE: DRAG
//  Suitable for: Aircraft, Hovercraft (anything that moves through air or fluid)
// ============================================================

/// @function Apply_Drag(physics_state, aircraft_stats, input_struct)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats  Must have: aircraft_aerodynamics, aircraft_max_speed, aircraft_brake_power
/// @param {Struct} input_struct    Must have: brake_input (0 = off, 1+ = active)
/// @description Applies a drag force that opposes the current velocity direction.
///              Two behaviours:
///                1. Base drag   — always active, bleeds speed naturally each step.
///                2. Brake drag  — multiplied when brake_input is held; rapidly kills speed.
///              Also applies extra drag above max speed, acting as a soft velocity cap.
function Apply_Drag(physics_state, aircraft_stats) {
    if (physics_state.speed <= 1) exit;

    // Base drag scales with speed squared (quadratic drag model).
    // aircraft_aerodynamics controls how "slippery" the vehicle is.
    // A higher value = more drag = lower effective top speed and faster braking.
    var _drag = aircraft_stats.aircraft_aerodynamics * (sqr(physics_state.speed)/2) * global.air_resistance;

    // Over-speed drag: if somehow above max speed (e.g. from a steep dive),
    // pile on extra drag proportionally. This is a soft cap — not a hard clamp.
    //if (physics_state.speed > aircraft_stats.aircraft_max_speed) {
    //    var _over_ratio = (physics_state.speed - aircraft_stats.aircraft_max_speed)
    //                      / max(aircraft_stats.aircraft_max_speed, 1);
    //    _drag += aircraft_stats.aircraft_aerodynamics * sqr(physics_state.speed) * _over_ratio * 1;
    // }

    // Drag always opposes the direction of movement.
    var _vel_angle = point_direction(0, 0, physics_state.velocity_x, physics_state.velocity_y);
    physics_state.force_x += lengthdir_x(-_drag, _vel_angle);
    physics_state.force_y += lengthdir_y(-_drag, _vel_angle);
}


// ============================================================
//  MODULE: Air Brake
//  Suitable for: Aircraft, Hovercraft (anything that moves through air or fluid)
// ============================================================

/// @function Apply_AIr_Brake(physics_state, aircraft_stats, input_struct)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats  Must have: aircraft_aerodynamics, aircraft_max_speed, aircraft_brake_power
/// @param {Struct} input_struct    Must have: brake_input (0 = off, 1+ = active)
/// @description Applies a drag force that opposes the current velocity direction.
///               Brake drag  — multiplied when brake_input is held; rapidly kills speed.
function Apply_Air_Brake(physics_state, aircraft_stats, input_struct) {
    if (physics_state.speed <= 10) exit;
	
	var _air_brake_force = 0
	
    if (input_struct.brake_input > 0) {
       _air_brake_force = aircraft_stats.aircraft_brake_power;
    }

    // Drag always opposes the direction of movement.
    var _vel_angle = point_direction(0, 0, physics_state.velocity_x, physics_state.velocity_y);
    physics_state.force_x += lengthdir_x(-_air_brake_force, _vel_angle);
    physics_state.force_y += lengthdir_y(-_air_brake_force, _vel_angle);
}

// ============================================================
//  MODULE: ROTATION
//  Suitable for: Aircraft, Hovercraft
//  Not needed for turrets (they rotate differently) or ground vehicles.
// ============================================================

/// @function Apply_Rotation(physics_state, aircraft_stats, input_struct)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats  Must have: aircraft_turn_rate, aircraft_turn_acceleration
/// @param {Struct} input_struct    Must have: aim_angle (target heading in degrees)
/// @description Rotates the object's heading toward aim_angle with inertia.
///              Instead of snapping instantly, angular_velocity ramps up and down,
///              giving turns a weighted, physical feel.
///
///              HOW IT WORKS:
///                1. Find the shortest angle gap between current heading and aim_angle.
///                2. Calculate the target angular velocity proportional to that gap.
///                3. Step angular_velocity toward that target (acceleration).
///                4. Apply angular drag (damping) to prevent oscillation/overshoot.
///                5. Add angular_velocity to heading.
function Apply_Rotation(physics_state, aircraft_stats, input_struct) {
    // angle_difference() always returns the shortest path between two angles (-180 to +180).
    var _angle_diff = angle_difference(input_struct.aim_angle, physics_state.heading);

    // Target angular velocity: proportional to how far off we are, capped at turn_rate.
    // Dividing by 90 means: at 90° off → full turn rate; at 10° off → 1/9th of turn rate.
    var _target_angular_vel = clamp(_angle_diff * (aircraft_stats.aircraft_turn_rate / 90),
		-aircraft_stats.aircraft_turn_rate,
         aircraft_stats.aircraft_turn_rate
    );

    // Step angular_velocity toward its target by turn_acceleration per step.
    // This is the "inertia" — the aircraft can't change direction instantly.
    physics_state.angular_velocity = approach(
        physics_state.angular_velocity,
        _target_angular_vel,
        aircraft_stats.aircraft_turn_acceleration
    );

    // Angular drag: reduces angular_velocity slightly each step.
    // Prevents the aircraft from overshooting and wobbling past its target angle.
    // 0.85 means angular velocity decays to 85% of its value each step.
    physics_state.angular_velocity *= 0.85;

    // Apply the rotation and keep heading in the [0, 360) range.
    physics_state.heading += physics_state.angular_velocity;
    physics_state.heading  = ((physics_state.heading mod 360) + 360) mod 360;
}

