local IDCounter = require "objects.IDCounter"
local Snake = require "games.snake"
local Tiles = require "games.tiles"
local Done = require "games.done"
local Witness = require "games.witness"
local Witness2 = require "games.witnessDeprecated"
local silver = require "games.silver"
local gold = require "games.gold"  

local puzzle = {}


function puzzle:enter(from, object)
    self.from = from -- record previous state
    print(game_name)
    local game_name = object.game
    if game_name == "snake" then
        self.game = Snake(object)
    elseif game_name == "tiles" then
        self.game = Tiles(object)
    elseif game_name == "witnessMain" then
        self.game = Witness(object)
    elseif game_name == "witnessSecond" then
        self.game = Witness2(object)
    elseif game_name == "done" then
        self.game = Done(object)
    end
    
    
end

function puzzle:init()
    self.id_counter = IDCounter()
end

function puzzle:update(dt)
    self.game:update(dt)
end


function puzzle:draw()
    
    self.game:draw()
end

function puzzle:keypressed(key)
    if key == 'escape' then
        GameState.pop()
    end
    self.game:keypressed(key)
end

function puzzle:mousepressed(x, y,button)
    self.game:mousepressed(x,y,button)
end


return puzzle
