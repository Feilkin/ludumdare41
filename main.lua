local tiny = require("tiny")
local bump = require("bump")
local spritesheet = require("spritesheet")
local Camera
Camera = require("camera").Camera
local Vector
Vector = require("util").Vector
local Player
Player = require("entity").Player
local levels = require("levels")
local physicsSystem, collisionSystem, entityStateSystem, corpseSystem, animationSystem
do
  local _obj_0 = require("systems")
  physicsSystem, collisionSystem, entityStateSystem, corpseSystem, animationSystem = _obj_0.physicsSystem, _obj_0.collisionSystem, _obj_0.entityStateSystem, _obj_0.corpseSystem, _obj_0.animationSystem
end
local camera
local player
game = {
  checkpoint = nil
}
game.switch_level = function(self, to)
  local level_name, connector = to:match("^([^:]+):(.+)$")
  local new_level = assert(levels[level_name], "level " .. level_name .. " not found")
  if game.level ~= new_level then
    game.level:unload()
    game.world:clearEntities()
    game.world:addEntity(player)
    game.bump_world = bump.newWorld(256)
    collisionSystem.bump_world = game.bump_world
    new_level:load()
    collisionSystem.map = new_level.map
  end
  game.level = new_level
  game.level:spawn_player(player, connector)
  if game.bump_world:hasItem(player) then
    return game.bump_world:update(player, player.position.x, player.position.y, player.bounding_box.x, player.bounding_box.y)
  end
end
love.load = function()
  game.spritesheet = spritesheet.load("res/sprites/spritesheet_complete.xml")
  game.bump_world = bump.newWorld(256)
  game.world = tiny.world(physicsSystem, collisionSystem, entityStateSystem, corpseSystem, animationSystem)
  collisionSystem.bump_world = game.bump_world
  camera = Camera(Vector(2048, 2048))
  game.camera = camera
  player = Player(Vector(0, 0))
  game.level = levels["Level01"]
  game.level:load()
  collisionSystem.map = game.level.map
  game.level:spawn_player(player, "player_spawn")
  local font = love.graphics.newFont("res/block_font.ttf", 20)
  return love.graphics.setFont(font)
end
love.update = function(dt)
  game.world:update(dt)
  game.level:update(dt)
  camera:lookAt(player)
  camera:update(dt)
  if not player.dead then
    if love.keyboard.isDown("d") then
      player.velocity.x = 200
      player.flip_x = false
    elseif love.keyboard.isDown("a") then
      player.velocity.x = -200
      player.flip_x = true
    else
      player.velocity.x = 0
    end
    if love.keyboard.isDown("space") and player.on_ground then
      player.velocity.y = -650
    end
  end
  if game.switch_level_to then
    game:switch_level(game.switch_level_to)
    game.switch_level_to = nil
  end
end
love.keyreleased = function(key, code)
  if key == "w" then
    if game.current_door then
      if not game.current_door.properties.locked then
        return game:switch_level(game.current_door.properties.connects_to)
      else
        return camera:shake(0.1, 4)
      end
    end
  end
end
love.draw = function()
  game.level:draw(camera)
  local gw, gh = love.graphics.getDimensions()
  if game.current_sign then
    local font = love.graphics.getFont()
    local text = game.current_sign.properties.message
    local x = gw / 2 - 200
    local y = gh / 2 - 100
    local w = 400
    local actual_w, lines = font:getWrap(text, 400)
    local line_h = font:getHeight()
    local spacing = 10
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", gw / 2 - actual_w / 2 - spacing, y - spacing, actual_w + spacing * 2, line_h * #lines + spacing * 2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(text, x, y, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
  end
  if game.current_door then
    local font = love.graphics.getFont()
    local text = game.current_door.properties.locked and "locked!" or game.current_door.properties.message or game.current_door.properties.connects_to
    local x = gw / 2 - 200
    local y = gh / 2 - 100
    local w = 400
    local actual_w, lines = font:getWrap(text, 400)
    local line_h = font:getHeight()
    local spacing = 10
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", gw / 2 - actual_w / 2 - spacing, y - spacing, actual_w + spacing * 2, line_h * #lines + spacing * 2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(text, x, y, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
  end
  return love.graphics.print(string.format("%0.2d, %0.2d", player.position.x, player.position.y), 2, 2)
end
