local instance_of
instance_of = function(i, c)
  return type(i) == "table" and i.__class == c
end
local Vector
do
  local _class_0
  local _base_0 = {
    __add = function(a, b)
      if instance_of(a, Vector) then
        if instance_of(b, Vector) then
          return Vector(a.x + b.x, a.y + b.y)
        end
      end
      return error("You can only add Vectors to Vectors")
    end,
    __sub = function(a, b)
      if instance_of(a, Vector) then
        if instance_of(b, Vector) then
          return Vector(a.x - b.x, a.y - b.y)
        end
      end
      return error("You can only subtract Vectors from Vectors")
    end,
    __mul = function(a, b)
      if instance_of(a, Vector) then
        if instance_of(b, Vector) then
          error("Don't multiply Vector by Vector, use dotProduct or crossProduct instead")
        end
        return Vector(a.x * b, a.y * b)
      else
        return Vector.__mul(b, a)
      end
    end,
    magnitude = function(v)
      assert(instance_of(v, Vector), "argument must be Vector")
      return math.sqrt(v.x ^ 2 + v.y ^ 2)
    end,
    direction = function(v)
      assert(instance_of(v, Vector), "argument must be Vector")
      return math.atan2(v.y, v.x)
    end,
    normalize = function(v)
      assert(instance_of(v, Vector), "argument must be Vector")
      local m = v:magnitude()
      return Vector(v.x / m, v.y / m)
    end,
    distance = function(a, b)
      assert(instance_of(a, Vector) and instance_of(b, Vector), "arguments must be Vectors")
      return Vector.magnitude(a - b)
    end,
    clone = function(self)
      return Vector(self.x, self.y)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x = x
      self.y = y
    end,
    __base = _base_0,
    __name = "Vector"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Vector = _class_0
end
local multiply_color
multiply_color = function(a, b)
  if type(b) == "number" then
    b = {
      b,
      b,
      b
    }
  end
  return {
    math.min(a[1] * b[1], 255),
    math.min(a[2] * b[2], 255),
    math.min(a[3] * b[3], 255),
    math.min(a[4] and a[4] or 255, 255)
  }
end
local clamp
clamp = function(low, val, high)
  if val <= low then
    return low
  end
  if val >= high then
    return high
  end
  return val
end
local filter
filter = function(t, f)
  local _tbl_0 = { }
  for k, v in pairs(t) do
    if f(v, k) then
      _tbl_0[k] = v
    end
  end
  return _tbl_0
end
local ifilter
ifilter = function(t, f)
  local _accum_0 = { }
  local _len_0 = 1
  for k, v in pairs(t) do
    if f(v, k) then
      _accum_0[_len_0] = v
      _len_0 = _len_0 + 1
    end
  end
  return _accum_0
end
local iextend
iextend = function(a, ...)
  local b = {
    ...
  }
  if (not b) or #b == 0 then
    return a
  end
  for _, c in ipairs(b) do
    for i, v in ipairs(c) do
      a[#a + 1] = v
    end
  end
  return a
end
local recursivefind
recursivefind = function(pattern, dir)
  local items = love.filesystem.getDirectoryItems(dir)
  local out = { }
  for i, v in ipairs(items) do
    local file = dir .. '/' .. v
    print(file)
    if love.filesystem.isFile(file) and file:match(pattern) then
      table.insert(out, file)
    elseif love.filesystem.isDirectory(file) then
      utils.extend(out, recursiveFind(pattern, file))
    end
  end
  return out
end
return {
  instance_of = instance_of,
  Vector = Vector,
  multiply_color = multiply_color,
  clamp = clamp,
  filter = filter,
  ifilter = ifilter,
  iextend = iextend,
  recursivefind = recursivefind
}
