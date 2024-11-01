local Math   = { _version = '1.0', _name = "Math", _author = 'Derple', }
Math.__index = Math

--- Calculates the distance between two points (x1, y1) and (x2, y2).
--- @param x1 number The x-coordinate of the first point.
--- @param y1 number The y-coordinate of the first point.
--- @param x2 number The x-coordinate of the second point.
--- @param y2 number The y-coordinate of the second point.
--- @return number The distance between the two points.
function Math.GetDistance(x1, y1, x2, y2)
    --return mq.TLO.Math.Distance(string.format("%d,%d:%d,%d", y1 or 0, x1 or 0, y2 or 0, x2 or 0))()
    return math.sqrt(Math.GetDistanceSquared(x1, y1, x2, y2))
end

--- Calculates the squared distance between two points (x1, y1) and (x2, y2).
--- This is useful for distance comparisons without the computational cost of a square root.
--- @param x1 number The x-coordinate of the first point.
--- @param y1 number The y-coordinate of the first point.
--- @param x2 number The x-coordinate of the second point.
--- @param y2 number The y-coordinate of the second point.
--- @return number The squared distance between the two points.
function Math.GetDistanceSquared(x1, y1, x2, y2)
    return ((x2 or 0) - (x1 or 0)) ^ 2 + ((y2 or 0) - (y1 or 0)) ^ 2
end

return Math
