instance_of = (i, c) ->
  type(i) == "table" and i.__class == c

class Vector
  new: (x, y) =>
    @x = x
    @y = y

  __add: (a, b) ->
    if instance_of(a, Vector)
      if instance_of(b, Vector)
        return Vector(a.x + b.x, a.y + b.y)
    error("You can only add Vectors to Vectors")

  __sub: (a, b) ->
    if instance_of(a, Vector)
      if instance_of(b, Vector)
        return Vector(a.x - b.x, a.y - b.y)
    error("You can only subtract Vectors from Vectors")

  __mul: (a, b) ->
    if instance_of(a, Vector)
      if instance_of(b, Vector)
        error("Don't multiply Vector by Vector, use dotProduct or crossProduct instead")
      return Vector(a.x * b, a.y * b)
    else
      return Vector.__mul(b, a)

  magnitude: (v) ->
    assert(instance_of(v, Vector), "argument must be Vector")
    math.sqrt(v.x^2 + v.y^2)

  direction: (v) ->
    assert(instance_of(v, Vector), "argument must be Vector")
    math.atan2(v.y, v.x)

  normalize: (v) ->
    assert(instance_of(v, Vector), "argument must be Vector")
    m = v\magnitude()
    return Vector(v.x / m, v.y / m)

  distance: (a, b) ->
    assert(instance_of(a, Vector) and instance_of(b, Vector), "arguments must be Vectors")
    return Vector.magnitude(a - b)

  clone: () =>
    return Vector(@x, @y)

multiply_color = (a, b) ->
  if type(b) == "number" then
    b = {b, b, b}

  return {
    math.min(a[1] * b[1], 255),
    math.min(a[2] * b[2], 255),
    math.min(a[3] * b[3], 255),
    math.min(a[4] and a[4] or 255, 255),
  }

clamp = (low, val, high) ->
  if val <= low
    return low
  if val >= high
    return high
  return val

filter = (t, f) ->
  { k, v for k, v in pairs(t) when f(v, k) }

ifilter = (t, f) ->
  [ v for k, v in pairs(t) when f(v, k) ]

iextend = (a, ...) ->
  b = {...}
  if (not b) or #b == 0 then return a

  for _, c in ipairs(b) do
    for i, v in ipairs(c) do
      a[#a + 1] = v

  return a

recursivefind = (pattern, dir) ->
  items = love.filesystem.getDirectoryItems(dir)
  out = {}

  for i, v in ipairs(items)
    file = dir .. '/' .. v

    if love.filesystem.isFile(file) and file\match(pattern) then
      table.insert(out, file)
    elseif love.filesystem.isDirectory(file) then
      utils.extend(out, recursiveFind(pattern, file))

  return out


load_sound = (name, path, options) ->
  if type(path) == "string"
    path = {path}
  options = options or {}

  source_pool = {}

  for path in *path
    source = love.audio.newSource("res/sounds/" .. path, "static")
    if options.volume then
      source\setVolume(options.volume)

    for i = 1, options.pool_size or 10
      clone = source\clone()

      if options.pitch_variation then
        v_min, v_max = options.pitch_variation.min, options.pitch_variation.max
        var_d = v_max - v_min
        variation = v_min + love.math.random() * var_d
        clone\setPitch(variation)

      table.insert(source_pool, clone)

  {
    source_pool: source_pool
    name: name
  }

{
  :instance_of
  :Vector
  :multiply_color
  :clamp
  :filter
  :ifilter
  :iextend
  :recursivefind
  :load_sound
}