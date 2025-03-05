-- screen.lua
local screen = {}

function screen:updateDimensions()
    self.width, self.height = love.window.getMode()
end

function screen:getWidth()
    return self.width or love.graphics.getWidth()
end

function screen:getHeight()
    return self.height or love.graphics.getHeight()
end

-- Initialize dimensions
screen:updateDimensions()

return screen
