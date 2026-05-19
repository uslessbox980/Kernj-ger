/// @function Aircraft_AI_Follow(
///     _physics_state,
///     _input_struct,
///     _desired_distance
/// )
///
/// Simple follow AI.
/// Simulates player inputs.

function AI_Enemy_Aircraft_Basic(physics_state, input_struct, desired_distance)
{
    var _player = instance_find(obj_Player, 0);

    if (_player == noone)
    {
        return;
    }

    // Distance to player
    var _dist = point_distance(
        x,
        y,
        _player.x,
        _player.y
    );

    // Angle to player
    var _target_angle = point_direction(
        x,
        y,
        _player.x,
        _player.y
    );

    // Simulated inputs
    input_struct.aim_angle = _target_angle;

    // Only thrust if too far away
    if (_dist > desired_distance)
    {
        input_struct.thrust_input = 1;
    }
    else
    {
        input_struct.thrust_input = 0;
    }
}