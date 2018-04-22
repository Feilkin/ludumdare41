local Vector
Vector = require("util").Vector
local Camera
do
  local _class_0
  local _base_0 = {
    lookAt = function(self, entity)
      self.position = entity.position:clone()
    end,
    shake = function(self, duration, magnitude)
      self._shake = {
        duration,
        magnitude
      }
    end,
    get_translate_and_zoom = function(self)
      local gw = love.graphics.getWidth()
      local gh = love.graphics.getHeight()
      local tx, ty = gw / 2 - self.position.x, gh / 2 - self.position.y
      if self._shake then
        local _, magnitude
        do
          local _obj_0 = self._shake
          _, magnitude = _obj_0[1], _obj_0[2]
        end
        tx = tx + love.math.random(-magnitude, magnitude)
        ty = ty + love.math.random(-magnitude, magnitude)
      end
      return tx, ty, self.zoom.x, self.zoom.y
    end,
    attach = function(self)
      love.graphics.push()
      local tx, ty = self:get_transalate()
      love.graphics.translate(tx, ty)
      return love.graphics.scale(self.zoom.x, self.zoom.y)
    end,
    detach = function(self)
      return love.graphics.pop()
    end,
    update = function(self, dt)
      if self._shake then
        local duration, magnitude
        do
          local _obj_0 = self._shake
          duration, magnitude = _obj_0[1], _obj_0[2]
        end
        duration = duration - dt
        if duration <= 0 then
          self._shake = nil
        else
          self._shake = {
            duration,
            magnitude
          }
        end
      end
      local gw, gh = love.graphics.getDimensions()
      local hgw, hgh = gw / 2, gh / 2
      if self.position.x - hgw < 0 then
        self.position.x = hgw
      end
      if self.position.x + hgw > self.bounds.x then
        self.position.x = self.bounds.x - hgw
      end
      if self.position.y - hgh < 0 then
        self.position.y = hgh
      end
      if self.position.y + hgh > self.bounds.y then
        self.position.y = self.bounds.y - hgh
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, bounds)
      self.position = Vector(0, 0)
      self.zoom = Vector(1, 1)
      self.bounds = bounds
    end,
    __base = _base_0,
    __name = "Camera"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Camera = _class_0
end
return {
  Camera = Camera
}
