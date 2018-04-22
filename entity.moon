import Vector from require "util"

class Entity
  bounding_box: Vector(64, 64)

  new: (position, sprite) =>
    @position = position
    @sprite = sprite


class Player extends Entity
  bounding_box: Vector(45, 54)
  affected_by_gravity: true
  is_player: true

  animations:
    dead:   { "playerBlue_dead.png", rate: 0 }
    duck:   { "playerBlue_duck.png", rate: 0 }
    fall:   { "playerBlue_fall.png", rate: 0 }
    hit:    { "playerBlue_hit.png", rate: 0 }
    roll:   { "playerBlue_roll.png", rate: 0 }
    stand:  { "playerBlue_stand.png", rate: 0 }
    swim:   { "playerBlue_swim1.png", "playerBlue_swim2.png", rate: 0.1 }
    switch: { "playerBlue_switch1.png", "playerBlue_switch2.png", rate: 0.1 }
    jump:   { "playerBlue_up1.png", "playerBlue_up2.png", "playerBlue_up3.png", "playerBlue_up2.png", "playerBlue_up1.png", rate: 0.1 }
    walk:   { "playerBlue_walk1.png", "playerBlue_walk2.png", "playerBlue_walk3.png", "playerBlue_walk4.png", "playerBlue_walk3.png", rate: 0.1 }

  new: (position) =>
    super(position, @@animations.duck[1])
    @velocity = Vector(0, 0)
    @state = "fall"


{
  :Entity
  :Player
}