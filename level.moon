sti = require "sti"
bump = require "bump"

import Vector from require "util"

class Level
  map_file: "error_level.lua"
  max_entities: 50
  backgrounds: {}

  load: () =>
    @map = sti("res/maps/" .. @map_file, { "bump" })

    @map.findObject = (layername, name) =>
        o = @layers[layername].objects

        for v in *o
            if v.name == name then return v

    @map\addCustomLayer("entities", 4)
    entityLayer = @map.layers["entities"]

    entityLayer.entities = {}
    entityLayer.spritesheet = game.spritesheet
    entityLayer.spriteBatch = love.graphics.newSpriteBatch(entityLayer.spritesheet.image,
      50, "dynamic")

    @map\bump_init(game.bump_world)

    entityLayer.draw = () =>
      @spriteBatch\clear()

      for _, entity in ipairs(@entities)
        x = math.floor(entity.position.x)
        y = math.floor(entity.position.y)
        sx = 1

        if entity.flip_x
          sx = -1
          x += entity.bounding_box.x

        @spriteBatch\add(@spritesheet.quads[entity.sprite], x, y, 0, sx, 1)

      love.graphics.draw(@spriteBatch, 0, 0)

    -- set up parallax background
    backgrounds = {}

    for bg in *@backgrounds
      image = love.graphics.newImage("res/backgrounds/" .. bg[1])
      ratio = Vector(bg[2], bg[3])

      table.insert(backgrounds, { image: image, ratio: ratio })

    @backgrounds = backgrounds

  unload: () =>
    --game.world\clearEntities()
    @map = nil
    @backgrounds = nil

  spawn_player: (player, spawn) =>
    entityLayer = @map.layers["entities"]
    player_spawn = assert(@map\findObject("objects", spawn), "Could not find " .. spawn)
    player.position = Vector(player_spawn.x, player_spawn.y - 64)
    player.velocity = Vector(0, 0)
    player.dead = nil
    player.move_position = nil

    assert(player.position.x == player_spawn.x)

    table.insert(entityLayer.entities, player)
    game.world\addEntity(player)

  update: (dt) =>
    @map\update(dt)

  draw: (camera) =>
    gw, gh = love.graphics.getDimensions()
    tx, ty, sx, sy = camera\get_translate_and_zoom()

    -- draw parallax background
    for bg in *@backgrounds
      parallax_x = tx * bg.ratio.x
      parallax_y = ty * bg.ratio.y
      love.graphics.draw(bg.image, math.floor(parallax_x), math.floor(parallax_y))

    -- draw map
    @map\draw(tx, ty, sx, sy)
