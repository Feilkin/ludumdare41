Level = require "level"

class Level01 extends Level
  map_file: "map_01.lua"
  backgrounds: {
    { "set1_background_parallax_1.png", 0.5, 0.50 },
    { "set1_background_parallax_2.png", 0.25, 0.45 },
  }