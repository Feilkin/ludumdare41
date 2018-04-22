local bump = require("bump")
local tiny = require("tiny")
local Vector
Vector = require("util").Vector
local physicsSystem = tiny.processingSystem()
physicsSystem.filter = tiny.requireAll("position", "velocity")
physicsSystem.process = function(self, e, dt)
  game.systems_running = true
  if e.affected_by_gravity and not e.on_ground then
    e.velocity.y = e.velocity.y + (1500 * dt)
    if e.velocity.y > 800 then
      e.velocity.y = 800
      game.camera:shake(0.01, 1)
    end
  end
  e.move_position = e.position + e.velocity * dt
end
local collisionSystem = tiny.processingSystem()
collisionSystem.filter = tiny.requireAll("position", "bounding_box")
collisionSystem.onAdd = function(self, e)
  if not self.bump_world:hasItem(e) then
    return self.bump_world:add(e, e.position.x, e.position.y, e.bounding_box.x, e.bounding_box.y)
  else
    return self.bump_world:update(e, e.position.x, e.position.y, e.bounding_box.x, e.bounding_box.y)
  end
end
collisionSystem.onRemove = function(self, e)
  if self.bump_world:hasItem(e) then
    return self.bump_world:remove(e)
  end
end
collisionSystem.process = function(self, e, dt)
  if e.update_bb then
    e.bounding_box = e.update_bb
    e.update_bb = nil
    self.bump_world:update(e, e.position.x, e.position.y, e.bounding_box.x, e.bounding_box.y)
  end
  if e.move_position then
    local was_on_ground = e.on_ground
    local played_sound = false
    e.on_ground = false
    game.current_sign = nil
    game.current_door = nil
    local actualX, actualY, cols, len = self.bump_world:move(e, e.move_position.x, e.move_position.y, self.collision_filter)
    if len == 0 then
      e.position.x = actualX
      e.position.y = actualY
    else
      e.position.x = actualX
      e.position.y = actualY
      for _index_0 = 1, #cols do
        local _continue_0 = false
        repeat
          local col = cols[_index_0]
          local _exp_0 = (col.other.type or col.other.properties.type)
          if "water" == _exp_0 then
            e.dead = true
          elseif "spikes" == _exp_0 then
            if not e.dead then
              game.play_sound("impaled", true)
            end
            e.velocity.x = 0
            e.dead = true
          elseif "sign" == _exp_0 then
            game.current_sign = col.other
          elseif "door" == _exp_0 then
            game.current_door = col.other
          elseif "checkpoint" == _exp_0 then
            if not e.dead then
              local other = col.other.object
              if game.checkpoint then
                if game.checkpoint.checkpoint == other then
                  _continue_0 = true
                  break
                end
                game.checkpoint.checkpoint.gid = 190
              end
              game.checkpoint = {
                level = game.level,
                checkpoint = other
              }
              other.gid = 189
              self.map.layers.objects._batches_dirty = true
            end
          else
            if col.normal.y == -1 then
              if e.velocity.y > 700 then
                if not played_sound then
                  played_sound = true
                  game.play_sound("crash", true)
                end
                game.camera:shake(0.1, 16 * e.velocity.y / 800)
              elseif e.velocity.y > 300 then
                if not played_sound then
                  played_sound = true
                  game.play_sound("land", true)
                end
              elseif (e.velocity.y > 10) and not was_on_ground then
                if not played_sound then
                  played_sound = true
                  game.play_sound("walk", true)
                end
              end
              e.velocity.y = 0
              e.on_ground = true
            end
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      if e.dead then
        return self.world:addEntity(e)
      end
    end
  end
end
collisionSystem.collision_filter = function(e, other)
  if other.dead then
    return false
  end
  if (other.properties.type or other.type) then
    local _exp_0 = (other.properties.type or other.type)
    if "sign" == _exp_0 or "water" == _exp_0 or "spikes" == _exp_0 or "door" == _exp_0 or "checkpoint" == _exp_0 then
      return "cross"
    end
  end
  return "slide"
end
local entityStateSystem = tiny.processingSystem()
entityStateSystem.filter = tiny.requireAll("state", "velocity")
entityStateSystem.process = function(self, e, dt)
  if e.dead then
    e.state = "dead"
    return 
  end
  if (e.velocity.y > 100) and not e.on_ground then
    e.state = "fall"
    return 
  end
  if e.velocity.y < 0 then
    e.state = "jump"
    return 
  end
  if math.abs(e.velocity.x) > 50 then
    e.state = "walk"
    return 
  end
  e.state = "stand"
end
local corpseSystem = tiny.processingSystem()
corpseSystem.filter = tiny.requireAll("dead")
corpseSystem.onAdd = function(self, e)
  e.corpse_timer = 2
end
corpseSystem.onRemove = function(self, e)
  if e.is_player then
    game.switch_level_to = game.checkpoint.level.__class.__name .. ":" .. game.checkpoint.checkpoint.name
  end
end
corpseSystem.process = function(self, e, dt)
  e.corpse_timer = e.corpse_timer - dt
  if e.corpse_timer <= 0 then
    return self.world:removeEntity(e)
  end
end
local animationSystem = tiny.processingSystem()
animationSystem.filter = tiny.requireAll("state", "animations")
animationSystem.process = function(self, e, dt)
  if (not e.current_anim) or e.current_anim.name ~= e.state then
    e.current_anim = assert(e.animations[e.state], "Animation " .. " not found")
    e.current_anim.name = e.state
    e.current_frame = 1
    e.animation_timer = 0
  end
  e.animation_timer = e.animation_timer + dt
  if (e.current_anim.rate > 0) and (e.animation_timer >= e.current_anim.rate) then
    e.animation_timer = 0
    e.current_frame = e.current_frame + 1
    if e.current_frame > #e.current_anim then
      e.current_frame = 1
    end
  end
  e.sprite = e.current_anim[e.current_frame]
end
return {
  physicsSystem = physicsSystem,
  collisionSystem = collisionSystem,
  entityStateSystem = entityStateSystem,
  corpseSystem = corpseSystem,
  animationSystem = animationSystem
}
