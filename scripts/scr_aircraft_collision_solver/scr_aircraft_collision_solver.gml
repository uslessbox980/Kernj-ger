/// @function Aircraft_Collision_Solver(_collision_object)
///
/// Prevents overlapping with other aircraft.
/// Uses sprite collision masks.

function Aircraft_Collision_Solver(collision_object)
{
    var _other = instance_place(x, y, collision_object);

    if (_other == noone || _other == id)
    {
        return;
    }

    // Direction away from other object
    var _dir = point_direction(
        _other.x,
        _other.y,
        x,
        y
    );

    // Small soft push
    var _push_strength = 2;

    var _push_x = lengthdir_x(_push_strength, _dir);
    var _push_y = lengthdir_y(_push_strength, _dir);

    x += _push_x;
    y += _push_y;

    _other.x -= _push_x;
    _other.y -= _push_y;
}