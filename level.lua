local sti = require("sti")
local bump = require("bump")
local Vector
Vector = require("util").Vector
local Level
do
  local _class_0
  local _base_0 = {
    map_file = "error_level.lua",
    max_entities = 50,
    backgrounds = { },
    load = function(self)
      self.map = sti("res/maps/" .. self.map_file, {
        "bump"
      })
      self.map.findObject = function(self, layername, name)
        local o = self.layers[layername].objects
        for _index_0 = 1, #o do
          local v = o[_index_0]
          if v.name == name then
            return v
          end
        end
      end
      self.map:addCustomLayer("entities", 4)
      local entityLayer = self.map.layers["entities"]
      entityLayer.entities = { }
      entityLayer.spritesheet = game.spritesheet
      entityLayer.spriteBatch = love.graphics.newSpriteBatch(entityLayer.spritesheet.image, 50, "dynamic")
      self.map:bump_init(game.bump_world)
      entityLayer.draw = function(self)
        self.spriteBatch:clear()
        for _, entity in ipairs(self.entities) do
          local x = math.floor(entity.position.x)
          local y = math.floor(entity.position.y)
          local sx = 1
          if entity.flip_x then
            sx = -1
            x = x + entity.bounding_box.x
          end
          self.spriteBatch:add(self.spritesheet.quads[entity.sprite], x, y, 0, sx, 1)
        end
        return love.graphics.draw(self.spriteBatch, 0, 0)
      end
      local backgrounds = { }
      local _list_0 = self.backgrounds
      for _index_0 = 1, #_list_0 do
        local bg = _list_0[_index_0]
        local image = love.graphics.newImage("res/backgrounds/" .. bg[1])
        local ratio = Vector(bg[2], bg[3])
        table.insert(backgrounds, {
          image = image,
          ratio = ratio
        })
      end
      self.backgrounds = backgrounds
    end,
    unload = function(self)
      self.map = nil
      self.backgrounds = nil
    end,
    spawn_player = function(self, player, spawn)
      local entityLayer = self.map.layers["entities"]
      local player_spawn = assert(self.map:findObject("objects", spawn), "Could not find " .. spawn)
      player.position = Vector(player_spawn.x, player_spawn.y - 64)
      player.velocity = Vector(0, 0)
      player.dead = nil
      player.move_position = nil
      assert(player.position.x == player_spawn.x)
      table.insert(entityLayer.entities, player)
      return game.world:addEntity(player)
    end,
    update = function(self, dt)
      return self.map:update(dt)
    end,
    draw = function(self, camera)
      local gw, gh = love.graphics.getDimensions()
      local tx, ty, sx, sy = camera:get_translate_and_zoom()
      local _list_0 = self.backgrounds
      for _index_0 = 1, #_list_0 do
        local bg = _list_0[_index_0]
        local parallax_x = tx * bg.ratio.x
        local parallax_y = ty * bg.ratio.y
        love.graphics.draw(bg.image, math.floor(parallax_x), math.floor(parallax_y))
      end
      return self.map:draw(tx, ty, sx, sy)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Level"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Level = _class_0
  return _class_0
end
