-- my ludum dare 41 game

tiny = require "tiny"
bump = require "bump"
spritesheet = require "spritesheet"

import Camera from require "camera"
import Vector from require "util"
import Player from require "entity"
levels = require "levels"

import physicsSystem, collisionSystem, entityStateSystem, corpseSystem, animationSystem from require "systems"

local camera
local player

export game
game = {
  checkpoint: nil
}

game.switch_level = (to) =>
  level_name, connector = to\match("^([^:]+):(.+)$")
  new_level = assert(levels[level_name], "level " .. level_name .. " not found")
  if game.level ~= new_level
    game.level\unload()
    game.world\clearEntities()
    game.world\refresh()
    game.bump_world = bump.newWorld(256)
    collisionSystem.bump_world = game.bump_world
    new_level\load()
    collisionSystem.map = new_level.map
  game.level = new_level
  game.level\spawn_player(player, connector)
  if game.bump_world\hasItem(player)
    game.bump_world\update(player, player.position.x, player.position.y, player.bounding_box.x, player.bounding_box.y)

  game.current_door = nil
  game.current_sign = nil


love.load = ->
  game.spritesheet = spritesheet.load("res/sprites/spritesheet_complete.xml")
  game.bump_world = bump.newWorld(256)
  game.world = tiny.world(
      physicsSystem, collisionSystem, entityStateSystem,
      corpseSystem, animationSystem)
  collisionSystem.bump_world = game.bump_world

  camera = Camera(Vector(2048, 2048))
  game.camera = camera

  player = Player(Vector(0, 0))

  game.level = levels["Level01"]
  game.level\load()
  collisionSystem.map = game.level.map
  game.level\spawn_player(player, "player_spawn")

  font = love.graphics.newFont("res/block_font.ttf", 20)
  love.graphics.setFont(font)

love.update = (dt) ->
  if game.switch_level_to
    game\switch_level(game.switch_level_to)
    game.switch_level_to = nil
    return

  game.systems_running = false
  game.world\update(dt)
  game.level\update(dt)

  camera\lookAt(player)
  camera\update(dt)

  if not player.dead
    if love.keyboard.isDown("d")
      player.velocity.x = 200
      player.flip_x = false
    elseif love.keyboard.isDown("a") 
      player.velocity.x = -200
      player.flip_x = true
    else
      player.velocity.x = 0

    if love.keyboard.isDown("space") and player.on_ground
      player.velocity.y = -650

love.keypressed = (key, code) ->
  if key == "w"
    if game.current_door
      if not game.current_door.properties.locked
        game.switch_level_to = game.current_door.properties.connects_to
      else
        camera\shake(0.1, 4)

love.draw = ->
  --camera\attach()
  game.level\draw(camera)
  --camera\detach()

  gw, gh = love.graphics.getDimensions()

  if game.current_sign
    font = love.graphics.getFont()
    text = game.current_sign.properties.message
    x = gw/2 - 200
    y = gh/2 - 100
    w = 400
    actual_w, lines = font\getWrap(text, 400)
    line_h = font\getHeight()
    spacing = 10
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", gw/2 - actual_w / 2 - spacing, y - spacing, actual_w + spacing * 2, line_h * #lines + spacing * 2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(text, x, y, w, "center")
    love.graphics.setColor(1, 1, 1, 1)

  if game.current_door
    font = love.graphics.getFont()
    text = game.current_door.properties.locked and "locked!" or game.current_door.properties.message or game.current_door.properties.connects_to
    x = gw/2 - 200
    y = gh/2 - 100
    w = 400
    actual_w, lines = font\getWrap(text, 400)
    line_h = font\getHeight()
    spacing = 10
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", gw/2 - actual_w / 2 - spacing, y - spacing, actual_w + spacing * 2, line_h * #lines + spacing * 2)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(text, x, y, w, "center")
    love.graphics.setColor(1, 1, 1, 1)

  love.graphics.print(string.format("%0.2d, %0.2d %s" ,player.position.x, player.position.y, game.systems_running), 2, 2)