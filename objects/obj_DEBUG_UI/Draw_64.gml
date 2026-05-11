var _player = instance_find(obj_Player, 0);

if (_player == noone)
{
    exit;
}

draw_set_colour(c_white);

draw_text(20, 20,
    "Heading: " + string(_player.physics_state.heading));

draw_text(20, 40,
    "Velocity X: " + string(_player.physics_state.velocity_x));

draw_text(20, 60,
    "Velocity Y: " + string(_player.physics_state.velocity_y));

draw_text(20, 80,
    "Thrust: " + string(_player.player_input.thrust_input));