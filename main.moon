-- my ludum dare 41 game

tiny = require "tiny"
bump = require "bump"
spritesheet = require "spritesheet"

import Camera from require "camera"
import Vector, load_sound from require "util"
import Player from require "entity"
levels = require "levels"

import physicsSystem, collisionSystem, entityStateSystem, corpseSystem, animationSystem from require "systems"

local camera
local player

export game
game = {
  checkpoint: nil,
  sounds: {}
}

game.play_sound = (name, once) ->
  sound = assert(game.sounds[name], "no sound named " .. name)

  source_count = #sound.source_pool
  offset = math.floor(love.math.random() * source_count)

  if once
    for source in *sound.source_pool
      if source\isPlaying()
        return

  for i = 1, source_count do
    index = (i + offset) % source_count + 1

    source = sound.source_pool[index]
    if not source\isPlaying() then
      if options then
        if options.position then
          source\setPosition(options.position.x,
            options.position.y,
            options.position.z or 0)
        else
          source\setPosition(0,0,0)

      source\seek(0)
      source\play()
      return

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

  game.sounds.walk = load_sound("walk", {"walk1.ogg", "walk2.ogg"}, { pool_size: 1 })
  game.sounds.land = load_sound("land", {"land1.ogg", "land2.ogg", "land3.ogg"}, { pool_size: 1, volume: 0.6 })
  game.sounds.crash = load_sound("crash", {"crash1.ogg", "crash2.ogg"}, { pool_size: 1, volume: 1 })
  game.sounds.jump = load_sound("jump", {"jump1.ogg",}, { pool_size: 1 })
  game.sounds.impaled = load_sound("impaled", {"spikes1.ogg", "spikes2.ogg"}, { pool_size: 1, volume: 0.6 })

love.update = (dt) ->
  if dt > 0.1
    dt = 0.1

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
    if love.keyboard.isDown("d") or love.keyboard.isDown("right")
      player.velocity.x = 200
      player.flip_x = false

      if player.on_ground
        game.play_sound("walk", true)
    elseif love.keyboard.isDown("a") or love.keyboard.isDown("left")
      player.velocity.x = -200
      player.flip_x = true
      if player.on_ground
        game.play_sound("walk", true)
    else
      player.velocity.x = 0

    if (love.keyboard.isDown("space") or love.keyboard.isDown("kp0")) and player.on_ground
      player.velocity.y = -650
      game.play_sound("jump", true)

love.keypressed = (key, code) ->
  switch key
    when "w", "up"
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