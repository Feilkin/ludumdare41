local Vector
Vector = require("util").Vector
local Entity
do
  local _class_0
  local _base_0 = {
    bounding_box = Vector(64, 64)
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, position, sprite)
      self.position = position
      self.sprite = sprite
    end,
    __base = _base_0,
    __name = "Entity"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Entity = _class_0
end
local Player
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    bounding_box = Vector(45, 54),
    affected_by_gravity = true,
    is_player = true,
    animations = {
      dead = {
        "playerBlue_dead.png",
        rate = 0
      },
      duck = {
        "playerBlue_duck.png",
        rate = 0
      },
      fall = {
        "playerBlue_fall.png",
        rate = 0
      },
      hit = {
        "playerBlue_hit.png",
        rate = 0
      },
      roll = {
        "playerBlue_roll.png",
        rate = 0
      },
      stand = {
        "playerBlue_stand.png",
        rate = 0
      },
      swim = {
        "playerBlue_swim1.png",
        "playerBlue_swim2.png",
        rate = 0.1
      },
      switch = {
        "playerBlue_switch1.png",
        "playerBlue_switch2.png",
        rate = 0.1
      },
      jump = {
        "playerBlue_up1.png",
        "playerBlue_up2.png",
        "playerBlue_up3.png",
        "playerBlue_up2.png",
        "playerBlue_up1.png",
        rate = 0.1
      },
      walk = {
        "playerBlue_walk1.png",
        "playerBlue_walk2.png",
        "playerBlue_walk3.png",
        "playerBlue_walk4.png",
        "playerBlue_walk3.png",
        rate = 0.1
      }
    }
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, position)
      _class_0.__parent.__init(self, position, self.__class.animations.duck[1])
      self.velocity = Vector(0, 0)
      self.state = "fall"
    end,
    __base = _base_0,
    __name = "Player",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Player = _class_0
end
return {
  Entity = Entity,
  Player = Player
}
