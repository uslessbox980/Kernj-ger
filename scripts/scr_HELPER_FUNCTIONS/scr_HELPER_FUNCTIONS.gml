// ============================================================
//  HELPER
// ============================================================

/// @function T_Approach(current, target, step)
/// @param {Real} current
/// @param {Real} target
/// @param {Real} step     Maximum change per call (must be positive)
/// @returns {Real}        New value, stepped toward target without overshooting
function T_Approach(current, target, step) {
    if (abs(target - current) <= step) return target;
    return current + sign(target - current) * step;
}
