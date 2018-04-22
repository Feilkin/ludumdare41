local recursivefind
recursivefind = require("util").recursivefind
local level_files = recursivefind("^levels/level_[0-9]+%.lua$", "levels")
local levels = { }
for _index_0 = 1, #level_files do
  local level_file = level_files[_index_0]
  local level = love.filesystem.load(level_file)()
  levels[level.__class.__name] = level
end
return levels
