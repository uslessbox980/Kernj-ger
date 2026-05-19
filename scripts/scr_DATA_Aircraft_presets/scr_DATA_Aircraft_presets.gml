// ============================================================
//  STAT PRESETS — one function per aircraft archetype.
//  Call the appropriate one after constructing the stats struct
//  to apply archetype-specific overrides.
// ============================================================

/// @function Stats_Preset_Fighter_Light(stats)
/// @param {Struct} stats  An Aircraft_Stats() instance
/// @description Fast, agile, low mass. Low survivability.
function Stats_Preset_Fighter_Light(stats) {
	
	stats.hp = 1000;
	stats.shield = 200;
	
	stats.kinetic_res_flat = 10;
	stats.explosion_res_flat = 5;
	stats.energy_res_flat = 0;
	
	stats.kinetic_res_percent = 0.05;
	stats.explosion_res_percent = 0.1;
	stats.energy_res_percent = 0;
	
    stats.aircraft_acceleration     = 2;
    stats.aircraft_max_speed        = 15;
    stats.aircraft_stall_speed      = 4;
    stats.aircraft_turn_rate        = 6;
    stats.aircraft_turn_acceleration = 2;
    stats.aircraft_aerodynamics     = 0.9;
    stats.aircraft_lift_coef        = 0.98;
    stats.aircraft_mass             = 1;
    stats.aircraft_brake_power      = 3;
}

/// @function Stats_Preset_Fighter_Heavy(stats)
/// @param {Struct} stats  An Aircraft_Stats() instance
/// @description Slower turns, higher mass, harder to stop.
function Stats_Preset_Fighter_Heavy(stats) {
	
	stats.hp = 1000;
	stats.kinetic_res_flat = 10;
	stats.explosion_res_flat = 5;
	stats.energy_res_flat = 0;
	
	stats.kinetic_res_percent = 0.05;
	stats.explosion_res_percent = 0.1;
	stats.energy_res_percent = 0;
	
    stats.aircraft_acceleration     = 1;
    stats.aircraft_max_speed        = 12;
    stats.aircraft_stall_speed      = 3;
    stats.aircraft_turn_rate        = 12;
    stats.aircraft_turn_acceleration = 2;
    stats.aircraft_aerodynamics     = 1;
    stats.aircraft_lift_coef        = 0.99;
    stats.aircraft_mass             = 1.5;
    stats.aircraft_brake_power      = 3.5;
}