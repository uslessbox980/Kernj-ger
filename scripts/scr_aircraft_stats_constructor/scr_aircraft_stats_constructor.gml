/// @description Aircraft stats system
/// All performance numbers live in an Aircraft_Stats struct.
/// Physics modules only read from this struct — they never write to it.
/// Stats can be recalculated dynamically (e.g., from equipped parts) in
/// Calculate_Aircraft_Stats() before the physics solver runs.

// ============================================================
//  STATS STRUCT CONSTRUCTOR
//  Call once in Create: aircraft_stats = new Aircraft_Stats();
//  Then override individual fields for each aircraft type.
// ============================================================

/// @function Aircraft_Stats()
/// @description Default stats for a generic aircraft. Override per-prefab.
function Aircraft_Stats() constructor {

    // --- Thrust & Speed ---
    // aircraft_acceleration: pixels added to velocity per step when thrusting
    aircraft_acceleration   = 0.5;

    // aircraft_max_speed: velocity cap in pixels per step
    aircraft_max_speed      = 15;

    // aircraft_stall_speed: below this speed, Apply_Lift produces zero lift
    aircraft_stall_speed    = 5;

    // --- Aerodynamics ---
    // aircraft_aerodynamics: drag coefficient — higher = more drag, lower top speed
    // This feeds into: drag = air resistance * aerodynamics * speed²
    aircraft_aerodynamics   = 1;

    // aircraft_lift_coef: fraction of gravity cancelled at max speed [0.0 – 1.0]
    aircraft_lift_coef      = 0.95;

    // --- Rotation ---
    // aircraft_turn_rate: maximum degrees per step the aircraft can rotate
    aircraft_turn_rate      = 4;

    // aircraft_turn_acceleration: degrees per step added to angular velocity each step
    // Lower = sluggish turning; higher = snappy turning
    aircraft_turn_acceleration = 1;

    // --- Gravity response ---
    aircraft_gravity_scale  = 1.0;

    // --- Braking ---
    aircraft_brake_power    = 3.0;

    // --- Mass ---
    // aircraft_mass: divides force in Physics_Commit. Higher = less responsive.
    aircraft_mass           = 1.0;
}



// ============================================================
//  DYNAMIC STAT CALCULATOR
//  Call this before the physics solver if stats can change
//  at runtime (e.g., from modular parts or damage states).
// ============================================================

/// @function Calculate_Aircraft_Stats(stats, parts_struct)
/// @param {Struct} stats        The aircraft's Aircraft_Stats() instance (mutated in place)
/// @param {Struct} parts_struct A struct describing currently equipped parts (optional, pass noone if unused)
/// @description Recomputes derived stats from base values + equipped parts.
///              Expand this function as the modular part system is implemented.
function Calculate_Aircraft_Stats(stats, parts_struct) {
    // Placeholder: in future, iterate over parts_struct and apply modifiers.
    // Example pattern (to be implemented with part system):
    //
    //   if (parts_struct != noone) {
    //       stats.aircraft_max_speed += parts_struct.engine_speed_bonus;
    //       stats.aircraft_mass      += parts_struct.body_mass_bonus;
    //   }
    //
    // For now, stats are used as-is from the preset or manual assignment.
    // This function exists so the solver doesn't need to change when parts arrive.
}
