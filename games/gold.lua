-- scenes/snake.lua
local Class = require 'lib.classic'
local Map = require 'objects.map'
local done = Class:extend()

function done:new(object)
    -- Load a much larger font size
    self.font = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 100)
    self.map = Map(self.id_counter)
    self.map:loadMap("assets/maps/puzzle_game_background.lua")
end

function done:update(dt)
end

-- Draw snake and food with a border around the Snake game area.
function done:draw()
    self.map:draw(0, 0, 4, 4)

    -- Display the text
    local text = "gold key not achieved"
    love.graphics.setFont(self.font) -- Ensure the font is applied
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local textWidth = self.font:getWidth(text)
    local textHeight = self.font:getHeight()

    -- Calculate the position to center the text
    local x = (screenWidth - textWidth) / 2
    local y = (screenHeight - textHeight) / 2

    love.graphics.print(text, x, y)
end

function done:keypressed(key)
end

function done:mousepressed(x, y)
end

return done
