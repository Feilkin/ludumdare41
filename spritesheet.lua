-- loads ShoeBox exported spritesheets into löveable format

local spritesheet = {}
local parsexml = require "parsexml"

function spritesheet.newSheet(quads, image)
	return setmetatable({ quads = quads or {}, image = image or {} }, Sheet)
end

function spritesheet.load(filename)
	local contents, size = love.filesystem.read(filename)
	local parsed = assert(parsexml(contents), "failed to parse XML")[2]
	print(parsed.label)

	local folder_name = filename:match("(.*/)")
	print("folder: " .. folder_name)
	local image_filename = folder_name .. "/" ..parsed.xarg.imagePath
	local image = love.graphics.newImage(image_filename)
	local sw, sh = image:getDimensions()


	local sheet = spritesheet.newSheet({}, image)

	for _, subtexture in ipairs(parsed) do
		if type(subtexture) == "table" then
			local xarg = subtexture.xarg
			if subtexture.label == "SubTexture" and xarg then
				local name = xarg.name
				local quad = love.graphics.newQuad(xarg.x, xarg.y, xarg.width, xarg.height, sw, sh)
				sheet.quads[name] = quad
			end
		else
			print(subtexture)
		end
	end

	return sheet
end

return spritesheet