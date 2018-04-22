local tiny = require("tiny")
local bump = require("bump")
local spritesheet = require("spritesheet")
local Camera
Camera = require("camera").Camera
local Vector, load_sound
do
  local _obj_0 = require("util")
  Vector, load_sound = _obj_0.Vector, _obj_0.load_sound
end
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
  checkpoint = nil,
  sounds = { }
}
game.play_sound = function(name, once)
  local sound = assert(game.sounds[name], "no sound named " .. name)
  local source_count = #sound.source_pool
  local offset = math.floor(love.math.random() * source_count)
  if once then
    local _list_0 = sound.source_pool
    for _index_0 = 1, #_list_0 do
      local source = _list_0[_index_0]
      if source:isPlaying() then
        return 
      end
    end
  end
  for i = 1, source_count do
    local index = (i + offset) % source_count + 1
    local source = sound.source_pool[index]
    if not source:isPlaying() then
      if options then
        if options.position then
          source:setPosition(options.position.x, options.position.y, options.position.z or 0)
        else
          source:setPosition(0, 0, 0)
        end
      end
      source:seek(0)
      source:play()
      return 
    end
  end
end
game.switch_level = function(self, to)
  local level_name, connector = to:match("^([^:]+):(.+)$")
  local new_level = assert(levels[level_name], "level " .. level_name .. " not found")
  if game.level ~= new_level then
    game.level:unload()
    game.world:clearEntities()
    game.world:refresh()
    game.bump_world = bump.newWorld(256)
    collisionSystem.bump_world = game.bump_world
    new_level:load()
    collisionSystem.map = new_level.map
  end
  game.level = new_level
  game.level:spawn_player(player, connector)
  if game.bump_world:hasItem(player) then
    game.bump_world:update(player, player.position.x, player.position.y, player.bounding_box.x, player.bounding_box.y)
  end
  game.current_door = nil
  game.current_sign = nil
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
  love.graphics.setFont(font)
  game.sounds.walk = load_sound("walk", {
    "walk1.ogg",
    "walk2.ogg"
  }, {
    pool_size = 1
  })
  game.sounds.land = load_sound("land", {
    "land1.ogg",
    "land2.ogg",
    "land3.ogg"
  }, {
    pool_size = 1,
    volume = 0.6
  })
  game.sounds.crash = load_sound("crash", {
    "crash1.ogg",
    "crash2.ogg"
  }, {
    pool_size = 1,
    volume = 1
  })
  game.sounds.jump = load_sound("jump", {
    "jump1.ogg"
  }, {
    pool_size = 1
  })
  game.sounds.impaled = load_sound("impaled", {
    "spikes1.ogg",
    "spikes2.ogg"
  }, {
    pool_size = 1,
    volume = 0.6
  })
end
love.update = function(dt)
  if dt > 0.1 then
    dt = 0.1
  end
  if game.switch_level_to then
    game:switch_level(game.switch_level_to)
    game.switch_level_to = nil
    return 
  end
  game.systems_running = false
  game.world:update(dt)
  game.level:update(dt)
  camera:lookAt(player)
  camera:update(dt)
  if not player.dead then
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
      player.velocity.x = 200
      player.flip_x = false
      if player.on_ground then
        game.play_sound("walk", true)
      end
    elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then
      player.velocity.x = -200
      player.flip_x = true
      if player.on_ground then
        game.play_sound("walk", true)
      end
    else
      player.velocity.x = 0
    end
    if (love.keyboard.isDown("space") or love.keyboard.isDown("kp0")) and player.on_ground then
      player.velocity.y = -650
      return game.play_sound("jump", true)
    end
  end
end
love.keypressed = function(key, code)
  local _exp_0 = key
  if "w" == _exp_0 or "up" == _exp_0 then
    if game.current_door then
      if not game.current_door.properties.locked then
        game.switch_level_to = game.current_door.properties.connects_to
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
  return love.graphics.print(string.format("%0.2d, %0.2d %s", player.position.x, player.position.y, game.systems_running), 2, 2)
end
