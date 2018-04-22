-- autoloader for levels

import recursivefind from require "util"

level_files = recursivefind("^levels/level_[0-9]+%.lua$", "levels")
levels = {}

for level_file in *level_files
  level = love.filesystem.load(level_file)()
  levels[level.__class.__name] = level

return levels