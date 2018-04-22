bump = require "bump"
tiny = require "tiny"

import Vector from require "util"

physicsSystem = tiny.processingSystem()
physicsSystem.filter = tiny.requireAll("position", "velocity")
physicsSystem.process = (e, dt) =>
  game.systems_running = true
  if e.affected_by_gravity and not e.on_ground
    e.velocity.y += 1500 * dt
    if e.velocity.y > 800
      e.velocity.y = 800
      game.camera\shake(0.01, 1)
  e.move_position = e.position + e.velocity * dt

collisionSystem = tiny.processingSystem()
collisionSystem.filter = tiny.requireAll("position", "bounding_box")
collisionSystem.onAdd = (e) =>
  if not @bump_world\hasItem(e)
    @bump_world\add(e, e.position.x, e.position.y, e.bounding_box.x, e.bounding_box.y)
  else
    @bump_world\update(e, e.position.x, e.position.y, e.bounding_box.x, e.bounding_box.y)

collisionSystem.onRemove = (e) =>
  if @bump_world\hasItem(e)
    @bump_world\remove(e)

collisionSystem.process = (e, dt) =>
  if e.update_bb
    e.bounding_box = e.update_bb
    e.update_bb = nil
    @bump_world\update(e, e.position.x, e.position.y, e.bounding_box.x, e.bounding_box.y)

  if e.move_position
    was_on_ground = e.on_ground
    played_sound = false
    e.on_ground = false
    game.current_sign = nil
    game.current_door = nil

    actualX, actualY, cols, len = @bump_world\move(e, e.move_position.x, e.move_position.y,
      @collision_filter)
    if len == 0
      e.position.x = actualX
      e.position.y = actualY
    else
      e.position.x = actualX
      e.position.y = actualY

      for col in *cols
        switch (col.other.type or col.other.properties.type)
          when "water"
            e.dead = true
          when "spikes"
            if not e.dead
              game.play_sound("impaled", true)
            e.velocity.x = 0
            e.dead = true
          when "sign"
            game.current_sign = col.other
          when "door"
            game.current_door = col.other
          when "checkpoint"
            if not e.dead
              other = col.other.object

              if game.checkpoint
                if game.checkpoint.checkpoint == other
                  continue
                game.checkpoint.checkpoint.gid =  190

              game.checkpoint = { level: game.level, checkpoint: other }
              other.gid = 189
              @map.layers.objects._batches_dirty = true
          else
            if col.normal.y == -1
              if e.velocity.y > 700
                if not played_sound
                  played_sound = true
                  game.play_sound("crash", true)
                game.camera\shake(0.1, 16 * e.velocity.y / 800)
              elseif e.velocity.y > 300
                if not played_sound
                  played_sound = true
                  game.play_sound("land", true)
              elseif (e.velocity.y > 10) and not was_on_ground
                if not played_sound
                  played_sound = true
                  game.play_sound("walk", true)
              e.velocity.y = 0
              e.on_ground = true

      if e.dead
        @world\addEntity(e)

collisionSystem.collision_filter = (e, other) ->
  -- do not collide with the dead
  if other.dead
    return false

  if (other.properties.type or other.type)
    switch (other.properties.type or other.type)
      when "sign", "water", "spikes", "door", "checkpoint"
        return "cross"

  return "slide"

entityStateSystem = tiny.processingSystem()
entityStateSystem.filter = tiny.requireAll("state", "velocity")
entityStateSystem.process = (e, dt) =>
  if e.dead
    e.state = "dead"
    return

  if (e.velocity.y > 100) and not e.on_ground
    e.state = "fall"
    return

  if e.velocity.y < 0
    e.state = "jump"
    return

  if math.abs(e.velocity.x) > 50
    e.state = "walk"
    return

  e.state = "stand"

corpseSystem = tiny.processingSystem()
corpseSystem.filter = tiny.requireAll("dead")
corpseSystem.onAdd = (e) =>
  e.corpse_timer = 2

corpseSystem.onRemove = (e) =>
  if e.is_player
    game.switch_level_to = game.checkpoint.level.__class.__name .. ":" ..
      game.checkpoint.checkpoint.name

corpseSystem.process = (e, dt) =>
  e.corpse_timer -= dt
  if e.corpse_timer <= 0
    @world\removeEntity(e)

animationSystem = tiny.processingSystem()
animationSystem.filter = tiny.requireAll("state", "animations")
animationSystem.process = (e, dt) =>
  if (not e.current_anim) or e.current_anim.name ~= e.state
    e.current_anim = assert(e.animations[e.state], "Animation " .. " not found")
    e.current_anim.name = e.state
    e.current_frame = 1
    e.animation_timer = 0

  e.animation_timer += dt

  if (e.current_anim.rate > 0) and (e.animation_timer >= e.current_anim.rate)
    e.animation_timer = 0
    e.current_frame += 1
    if e.current_frame > #e.current_anim
      e.current_frame = 1

  e.sprite = e.current_anim[e.current_frame]

{
  :physicsSystem
  :collisionSystem
  :entityStateSystem
  :corpseSystem
  :animationSystem
}