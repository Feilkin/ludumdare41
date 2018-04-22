import Vector from require "util"

class Camera
  new: (bounds) =>
    @position = Vector(0, 0)
    @zoom = Vector(1, 1)
    @bounds = bounds

  lookAt: (entity) =>
    @position = entity.position\clone()

  shake: (duration, magnitude) =>
    @_shake = { duration, magnitude }

  get_translate_and_zoom: () =>
    gw = love.graphics.getWidth()
    gh = love.graphics.getHeight()

    tx, ty = gw / 2 - @position.x, gh / 2 - @position.y

    if @_shake
      { _, magnitude } = @_shake
      tx += love.math.random(-magnitude, magnitude)
      ty += love.math.random(-magnitude, magnitude)

    return tx, ty, @zoom.x, @zoom.y

  attach: () =>
    love.graphics.push()
    tx, ty = @get_transalate()

    love.graphics.translate(tx, ty)

    love.graphics.scale(@zoom.x, @zoom.y)

  detach: () =>
    love.graphics.pop()

  update: (dt) =>
    if @_shake
      { duration, magnitude } = @_shake
      duration -= dt
      if duration <= 0
        @_shake = nil
      else
        @_shake = { duration, magnitude } 

    -- keep camera in bounds
    gw, gh = love.graphics.getDimensions()
    hgw, hgh = gw/2, gh/2

    if @position.x - hgw < 0 then @position.x = hgw
    if @position.x + hgw > @bounds.x then @position.x = @bounds.x - hgw
    if @position.y - hgh < 0 then @position.y = hgh
    if @position.y + hgh > @bounds.y then @position.y = @bounds.y - hgh


{
  :Camera
}