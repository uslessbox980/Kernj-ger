// ============================================================
//  STAT PRESETS — one function per aircraft archetype.
//  Call the appropriate one after constructing the stats struct
//  to apply archetype-specific overrides.
// ============================================================

/// @function Stats_Preset_Fighter_Light(stats)
/// @param {Struct} stats  An Aircraft_Stats() instance
/// @description Fast, agile, low mass. Low survivability.
function Stats_Preset_Fighter_Light(stats) {
    stats.aircraft_acceleration     = 0.22;
    stats.aircraft_max_speed        = 12;
    stats.aircraft_stall_speed      = 1.5;
    stats.aircraft_turn_rate        = 4;
    stats.aircraft_turn_acceleration = 0.8;
    stats.aircraft_aerodynamics     = 0.007;
    stats.aircraft_lift_coef        = 0.98;
    stats.aircraft_mass             = 0.8;
    stats.aircraft_brake_power      = 2.5;
}

/// @function Stats_Preset_Fighter_Heavy(stats)
/// @param {Struct} stats  An Aircraft_Stats() instance
/// @description Slower turns, higher mass, harder to stop.
function Stats_Preset_Fighter_Heavy(stats) {
    stats.aircraft_acceleration     = 0.14;
    stats.aircraft_max_speed        = 9;
    stats.aircraft_stall_speed      = 2.5;
    stats.aircraft_turn_rate        = 2.2;
    stats.aircraft_turn_acceleration = 0.35;
    stats.aircraft_aerodynamics     = 0.010;
    stats.aircraft_lift_coef        = 0.90;
    stats.aircraft_mass             = 1.4;
    stats.aircraft_brake_power      = 3.5;
}