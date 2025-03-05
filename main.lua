-- main.lua
GameState = require "lib.gamestate"
local menu = require "scenes.menu"
local game = require "scenes.game"
local pause = require "scenes.pause"
local options = require "scenes.options"
local puzzle = require "scenes.puzzle"


ISBRONZE = false
ISSILVER = false
ISGOLD = false  


UNIQUE_ID = 0


local filewrite = io.open("witness.txt", "w")
local filewrite2 = io.open("case.txt", "w")


function love.load()
    backgroundMusic = love.audio.newSource("assets/sounds/LeanOn.mp3", "stream")
    backgroundMusic:setLooping(true) -- Set the music to loop
    backgroundMusic:setVolume(0.5)  -- Adjust the volume (0.0 to 1.0)
    love.audio.play(backgroundMusic) -- Play the music
    filewrite:write("")
    filewrite2:write("")
    filewrite:close()
    filewrite2:close()
    -- Create an entity
    -- Start the game with the main menu or directly with the game scene
    GameState.registerEvents()  -- Handle love callbacks automatically

    GameState.switch(menu)  -- Start with the game scene
end


function love.update(dt)
    
end

function love.draw()

end
