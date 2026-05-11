function Rendering_Aircraft_Body_Turning(physics_state){
	
/// @function render_get_direction_index(_physics_state)
/// @param _physics_state
/// Returns sprite/frame index from 0-11 based on heading

    var _heading = physics_state.heading;

    // Normalize angle to 0-359
    _heading = (_heading mod 360 + 360) mod 360;

    // Offset by half-sector for proper rounding
    var _index = ((_heading + 15) div 30) mod 12;

    return _index;


}

/// @function Rendering_Aircraft_Draw_Thrust(
///     physics_state,
///     input_struct,
///     sprite,
///     frame_count,
///     animation_framerate,
///     offset_x,
///     offset_y
/// )
///
/// Draws animated thrust sprite behind object.
/// Uses heading for rotation.
/// Only draws when thrust_input > 0.

function Rendering_Aircraft_Draw_Thrust( physics_state, input_struct, sprite, frame_count, animation_framerate, offset_x,offset_y)
{
    // Do not draw if not thrusting
    if (input_struct.thrust_input <= 0)
    {
        return;
    }

    var _heading = physics_state.heading;

    // Convert local offset into world position
    var _draw_x = x + lengthdir_x(offset_x, _heading)
                    + lengthdir_x(offset_y, _heading + 90);

    var _draw_y = y + lengthdir_y(offset_x, _heading)
                    + lengthdir_y(offset_y, _heading + 90);

    // Animated frame
    var _frame = floor(current_time / animation_framerate) mod frame_count;

    draw_sprite_ext( sprite, _frame, _draw_x, _draw_y, 1, 1, _heading, c_white, 1);
}