/// @description Input handling system
/// Provides a unified input struct used by both the Player and AI.
/// The Player populates it from keyboard/mouse; AI populates it by simulating intentions.
/// Physics modules only ever read from this struct — they never care about the source.

// ============================================================
//  INPUT STRUCT CONSTRUCTOR
//  Call once per object in Create event: input = new Input_State();
// ============================================================

/// @function Input_State()
/// @description Creates a blank, zeroed-out input state struct.
function Input_State() constructor {
    // --- Movement intentions ---
    // thrust_input: 0.0 = no thrust, 1.0 = full thrust
    thrust_input        = 0;

    // brake_input: 0.0 = no brake, 1.0 = full air brake
    brake_input         = 0;

    // aim_angle: world-space angle the aircraft wants to point toward (degrees)
    // For the player this is the mouse world position angle; for AI it's the target angle.
    aim_angle           = 0;

    // --- Action intentions (0 = not pressed, 1 = pressed this frame, 2 = held) ---
    dash_input          = 0;
    dodge_input         = 0;
    countermeasure_input = 0;
    ability1_input      = 0;
    ability2_input      = 0;

    // --- Weapon intentions ---
    // 0 = not firing, 1 = pressed this frame, 2 = held
    fire_primary_input   = 0;
    fire_secondary_input = 0;
}

// ============================================================
//  PLAYER INPUT READER
//  Call every step from the player object's Step event.
//  Writes real hardware state into the aircraft's input struct.
// ============================================================

/// @function Read_Player_Inputs(input_struct)
/// @param {Struct} input_struct  The Input_State() belonging to the player object
/// @description Reads keyboard/mouse and writes normalised values into input_struct.
function Read_Player_Inputs(input_struct) {
    // --- Thrust & Brake ---
    // Raw boolean keys mapped through configurable bindings (stored in global.bindings)
    input_struct.thrust_input = keyboard_check(global.binding_thrust) ? 1 : 0;
    input_struct.brake_input  = keyboard_check(global.binding_brake)  ? 1 : 0;

    // --- Aim angle from mouse world position ---
    // We use the aircraft's own position so the angle is always relative to the aircraft.
    var _mx = device_mouse_x_to_gui(0); // placeholder; swap for world coords with camera
    var _my = device_mouse_y_to_gui(0);
    // In a camera setup, use: point_direction(x, y, mouse_x + camera_x, mouse_y + camera_y)
    input_struct.aim_angle = point_direction(x, y, mouse_x, mouse_y);

    // --- Action buttons ---
    input_struct.dash_input   = _read_button(global.binding_dash);
    input_struct.dodge_input  = _read_button(global.binding_dodge);
    input_struct.countermeasure_input = _read_button(global.binding_countermeasure);
    input_struct.ability1_input       = _read_button(global.binding_ability1);
    input_struct.ability2_input       = _read_button(global.binding_ability2);

    // --- Weapons ---
    input_struct.fire_primary_input   = _read_mouse_button(mb_left);
    input_struct.fire_secondary_input = _read_mouse_button(mb_right);
}

/// @function _read_button(key)
/// @param {Real} key  Virtual key constant
/// @returns {Real}  0 = not pressed, 1 = pressed this frame, 2 = held
/// @description Internal helper. Returns press state for a keyboard key.
function _read_button(key) {
    if (keyboard_check_pressed(key)) return 1;
    if (keyboard_check(key))         return 2;
    return 0;
}

/// @function _read_mouse_button(button)
/// @param {Real} button  Mouse button constant (mb_left, mb_right, etc.)
/// @returns {Real}  0 = not pressed, 1 = pressed this frame, 2 = held
function _read_mouse_button(button) {
    if (mouse_check_button_pressed(button)) return 1;
    if (mouse_check_button(button))         return 2;
    return 0;
}

// ============================================================
//  DEFAULT KEY BINDINGS
//  Call once in a game-init object or the first room's creation code.
//  Players can override these values in a settings screen.
// ============================================================

/// @function Init_Default_Bindings()
/// @description Sets global key binding variables to their defaults.
function Init_Default_Bindings() {
    global.binding_thrust          = ord("W");
    global.binding_brake           = ord("S");
    global.binding_dash            = vk_shift;
    global.binding_dodge           = vk_space;
    global.binding_countermeasure  = vk_control;
    global.binding_ability1        = ord("Q");
    global.binding_ability2        = ord("E");
    // Weapons use mouse buttons — see _read_mouse_button above.
}
