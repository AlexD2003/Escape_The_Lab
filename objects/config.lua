local Class = require 'lib.classic'

local Config = Class:extend()

function Config.load()
    Config.screenWidth, Config.screenHeight = love.window.getMode()
end

function Config:getWidth()
    return self.width
end

function Config:getHeight()
    return self.height
end

function Config:setWidth(width)
    self.width = width
end

function Config:setHeight(height)
    self.height = height
end

return Config