-- scenes/snake.lua
local Class = require 'lib.classic'
local snake = Class:extend()

local gridSize = 40  -- Double the grid size
local snakeSegments = {{x = 5, y = 5}}
local snakeDir = {x = 1, y = 0}  
local nextDir = {x = 1, y = 0}
local food = {x = 10, y = 10}
local gameOver = false
local timer = 0
local speed = 0.1  
local score = 0
--vas for drawing the Snake game (doubled).
local canvasWidth, canvasHeight = 800, 600  
local borderThickness = 10  

function snake:new(object)
    self.font = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 32)
    self:resetGame() -- Reset all variables related to the Snake Game.
    self.isOver = false
    self.achieved10Score = false
    self.object = object
    self.wallpaper = love.graphics.newImage('assets/images/wallpaperSnake.png')
end

function snake:returnOver()
    return self.isOver
end

function snake:resetGame()
    snakeSegments = {{x=5,y=5}}
    snakeDir   ={x=1,y=0}
    nextDir     ={x=1,y=0}
    food         ={x=10,y=10}
    score       =0    
    timer       =0    
    gameOver     =false  
end

function snake:update(dt)

    
    timer = timer + dt
    if timer >= speed then
        timer = 0
        self:moveSnake()
    end
    if gameOver then
        GameState.pop()
    elseif score >= 10 then
        print(ISBRONZE)
        self.object.game = "done"
        ISBRONZE=true
        print(ISBRONZE)
        
        
        GameState.pop()
    end
end

function snake:moveSnake()
    snakeDir = {x = nextDir.x, y = nextDir.y}

    local headX, headY = snakeSegments[1].x, snakeSegments[1].y
    local nextX = headX + snakeDir.x
    local nextY = headY + snakeDir.y

    if self:checkCollision(nextX, nextY) then
        gameOver = true
        self.isOver = true
        return
    end

    table.insert(snakeSegments, 1, {x = nextX, y = nextY})

    if nextX == food.x and nextY == food.y then
        score = score + 1
        self:spawnFood()
    else
        table.remove(snakeSegments)
    end
end


function snake:spawnFood()
    -- Calculate the grid size within the playable area, excluding the border.
    local gridWidth = (canvasWidth - 2 * borderThickness) / gridSize
    local gridHeight = (canvasHeight - 2 * borderThickness) / gridSize

    -- Ensure food does not spawn on the border by excluding the first and last rows/columns.
    food.x = love.math.random(1, gridWidth - 2)
    food.y = love.math.random(1, gridHeight - 2)
end


function snake:draw()
    if self.wallpaper then
        love.graphics.draw(
            self.wallpaper, 
            0, 
            0, 
            0, 
            love.graphics.getWidth() / self.wallpaper:getWidth(), 
            love.graphics.getHeight() / self.wallpaper:getHeight()
        )
    end

    -- Center the canvas
    local offsetX = (love.graphics.getWidth() - canvasWidth) / 2
    local offsetY = (love.graphics.getHeight() - canvasHeight) / 2

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    -- Draw the game area border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", borderThickness, borderThickness, canvasWidth - 2 * borderThickness, canvasHeight - 2 * borderThickness)

    -- Draw the snake
    love.graphics.setColor(0.1, 0.8, 0.2)
    for _, segment in ipairs(snakeSegments) do
        love.graphics.rectangle(
            "fill", 
            borderThickness + (segment.x * gridSize), 
            borderThickness + (segment.y * gridSize), 
            gridSize, 
            gridSize
        )
    end

    -- Draw the food
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill", 
        borderThickness + (food.x * gridSize), 
        borderThickness + (food.y * gridSize), 
        gridSize, 
        gridSize
    )

    -- Draw the score
    love.graphics.setFont(love.graphics.newFont("assets/fonts/mainmenufont.ttf", 16))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, borderThickness + 10, borderThickness + 10)

    -- Draw "Game Over" text
    if gameOver then
        love.graphics.printf(
            "Game Over\nPress Enter to Restart", 
            0, 
            canvasHeight / 2 - 20, 
            canvasWidth, 
            "center"
        )
    end

    love.graphics.pop()
end


function snake:checkCollision(x, y)
    if x < 0 or y < 0 or x >= (canvasWidth - 2 * borderThickness) / gridSize or y >= (canvasHeight - 2 * borderThickness) / gridSize then
        gameOver = true
        snakeIsActive = false
        return true
    end

    for i, segment in ipairs(snakeSegments) do
        if i > 1 and segment.x == x and segment.y == y then
            gameOver = true
            snakeIsActive = false
            return true
        end
    end

    return false
end

function snake:keypressed(key)   
    if key == "return" and gameOver then
        self:new()
        return
    end

    if not gameOver then
        if key == "up" and not (snakeDir.y == 1) then 
            nextDir = {x=0, y=-1}
        elseif key == "down" and not (snakeDir.y == -1) then 
            nextDir = {x=0, y=1}
        elseif key == "left" and not (snakeDir.x == 1) then 
            nextDir = {x=-1, y=0}
        elseif key == "right" and not (snakeDir.x == -1) then 
            nextDir = {x=1, y=0}
        end
    end  
end

return snake
