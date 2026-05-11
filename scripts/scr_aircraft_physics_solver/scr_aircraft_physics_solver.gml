/// @description Physics solvers
/// A solver orchestrates module calls and commits the result to the object's position.
/// There is one solver per vehicle ARCHETYPE.
///
/// The solver is the only place that decides WHICH modules run.
/// Modules themselves are universal — the solver controls scope.

// ============================================================
//  PHYSICS COMMIT
//  Call at the END of every solver.
//  Converts the accumulated force this step into velocity, then moves the object.
// ============================================================

/// @function Physics_Commit(physics_state, aircraft_stats)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats
/// @description Integrates force → velocity → position for this step.
///              Also updates physics_state.speed so modules can read it next step.
function Physics_Commit(physics_state, aircraft_stats) {
    // Add this step's accumulated force directly to velocity.
    // Because we're at fixed 60 steps/s, force values are already per-step amounts.
    physics_state.velocity_x += physics_state.force_x / aircraft_stats.aircraft_mass;
    physics_state.velocity_y += physics_state.force_y / aircraft_stats.aircraft_mass;

    // Recalculate speed (used by Apply_Lift and Apply_Drag next step).
    physics_state.speed = point_distance(0, 0, physics_state.velocity_x, physics_state.velocity_y);

    // Safety clamp: hard ceiling at 4x max speed.
    // Drag should prevent reaching this under normal conditions.
    // This catches edge cases like simultaneous dash + dive.
    if (physics_state.speed > aircraft_stats.aircraft_max_speed * 4) {
        var _scale = (aircraft_stats.aircraft_max_speed * 4) / physics_state.speed;
        physics_state.velocity_x *= _scale;
        physics_state.velocity_y *= _scale;
        physics_state.speed       = aircraft_stats.aircraft_max_speed * 4;
    }

    // Move the object.
    x += physics_state.velocity_x;
    y += physics_state.velocity_y;

    // Sync the sprite to the current heading.
    image_angle = physics_state.heading;
}

// ============================================================
//  PLAYER PHYSICS SOLVER
// ============================================================

/// @function Aircraft_Player_Physics_Solver(physics_state, aircraft_stats, input_struct)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats
/// @param {Struct} input_struct
/// @description Runs the full physics pass for the player aircraft each step.
///              To add a new ability: write its Apply_X() module, then add one line here.
function Aircraft_Player_Physics_Solver(physics_state, aircraft_stats, input_struct) {
    // 1. Clear force accumulator from last step.
    Physics_State_Reset(physics_state);

    // 2. Rotation runs first so heading is up to date before thrust is applied.
    Apply_Rotation(physics_state, aircraft_stats, input_struct);

    // 3. Forces — order within this block does not matter.
    Apply_Gravity(physics_state, aircraft_stats);
    Apply_Lift(physics_state, aircraft_stats);       // aircraft only — not called for ground vehicles
    Apply_Thrust(physics_state, aircraft_stats, input_struct);
	Apply_Air_Brake(physics_state, aircraft_stats, input_struct);
    Apply_Drag(physics_state, aircraft_stats);

    // --- EXPANSION POINT ---
    // Add new module calls here as abilities are built:
    //   Apply_Dash(physics_state, aircraft_stats, input_struct);
    //   Apply_Dodge(physics_state, aircraft_stats, input_struct);

    // 4. Commit forces to position.
    Physics_Commit(physics_state, aircraft_stats);
}

// ============================================================
//  AI PHYSICS SOLVER — LIGHT FIGHTER
// ============================================================

/// @function AI_Enemy_Fighter_Light_Physics_Solver(physics_state, aircraft_stats, input_struct)
/// @param {Struct} physics_state
/// @param {Struct} aircraft_stats
/// @param {Struct} input_struct    Populated by the AI brain, not the player
/// @description Identical module set to the player solver.
///              The AI brain fills input_struct before this runs — everything else is shared.
function AI_Enemy_Fighter_Light_Physics_Solver(physics_state, aircraft_stats, input_struct) {
    Physics_State_Reset(physics_state);

    Apply_Rotation(physics_state, aircraft_stats, input_struct);

    Apply_Gravity(physics_state, aircraft_stats);
    Apply_Lift(physics_state, aircraft_stats);
    Apply_Thrust(physics_state, aircraft_stats, input_struct);
    Apply_Drag(physics_state, aircraft_stats);

    Physics_Commit(physics_state, aircraft_stats);
}

// ============================================================
//  AI PHYSICS SOLVER — HEAVY FIGHTER
// ============================================================

/// @function AI_Enemy_Fighter_Heavy_Physics_Solver(physics_state, aircraft_stats, input_struct)
/// @description Same modules as light fighter for now.
///              Add heavy-exclusive modules (e.g. Apply_Shield_Thruster) here when ready.
function AI_Enemy_Fighter_Heavy_Physics_Solver(physics_state, aircraft_stats, input_struct) {
    Physics_State_Reset(physics_state);
	
	Apply_Gravity(physics_state, aircraft_stats);
    Apply_Lift(physics_state, aircraft_stats);
	Apply_Drag(physics_state, aircraft_stats);
	
    Apply_Rotation(physics_state, aircraft_stats, input_struct);
	Apply_Thrust(physics_state, aircraft_stats, input_struct);

 
    // Expansion point:
    //   Apply_Shield_Thruster(physics_state, aircraft_stats, input_struct);

    Physics_Commit(physics_state, aircraft_stats);
}
