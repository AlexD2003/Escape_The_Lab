local game = {}

-- loading libraries
local bump = require 'lib.bump'

-- loading entities
local ObjectManager = require "objects.objectManager"

-- starting instances of the entities
local object_manager = ObjectManager(player)

local snake = require "games.snake"

function game:init()
end

function game:update(dt)
    object_manager:update(dt)
end

function game:draw()
    love.graphics.push()
    object_manager:draw()
    love.graphics.pop()
end

function game:keypressed(key)
    object_manager:keypressed(key)
    snake:keypressed(key)
    if key == "escape" then
        GameState.push(require("scenes.pause"))
    end
end




return game 
