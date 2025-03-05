local Class = require 'lib.classic'
local tiles = Class:extend()

local gridSize = 4 -- 4x4 grid
local tileSize = 200 -- Increased size of each tile
local tilesData = {}
local revealedTiles = {}
local matchesFound = 0
local totalPairs = 8 -- Total pairs of tiles (16 tiles)
local gameOver = false
local flipBackTimer = nil -- Timer for flipping back tiles
local flipBackDelay = 0.5 -- Delay for flipping back tiles

local tileAssets = {} -- Table to hold image assets for all tile types
local backgroundImage -- Variable for the background image

function tiles:new(object)
    self.object = object
    --self.object.game = "silver"
    -- Load the image assets
    for i = 1, totalPairs do
        tileAssets[i] = love.graphics.newImage('assets/images/Asset' .. i .. '.png')
    end

    -- Load the background image
    backgroundImage = love.graphics.newImage('assets/images/tileWallpaper.png') -- Adjust the path as needed
    backgroundImage2 =  love.graphics.newImage('assets/maps/puzzle_background.png')
    -- Initialize tile data
    local tileTypes = {}
    for i = 1, totalPairs do
        table.insert(tileTypes, i)
        table.insert(tileTypes, i) -- Add each type twice
    end
    self.font = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 100)
  
    -- Shuffle the tile types
    self:shuffle(tileTypes)

    -- Create the grid
    tilesData = {} -- Ensure tilesData is reset
    for i = 0, gridSize - 1 do
        tilesData[i] = {}
        for j = 0, gridSize - 1 do
            tilesData[i][j] = {
                type = tileTypes[i * gridSize + j + 1],
                revealed = false,
                matched = false,
            }
        end
    end

    revealedTiles = {}
    matchesFound = 0
    gameOver = false
    flipBackTimer = nil -- Reset the flip timer
end

function tiles:shuffle(array)
    for i = #array, 2, -1 do
        local j = love.math.random(i)
        array[i], array[j] = array[j], array[i]
    end
end

function tiles:update(dt)
    -- Check if the game is over (all pairs matched)
    if matchesFound == totalPairs then
        self.object.game = "done"
        ISSILVER=true
        GameState.pop()
    end

    -- Handle flip-back timer
    if flipBackTimer then
        flipBackTimer = flipBackTimer - dt
        if flipBackTimer <= 0 then
            -- Flip the tiles back
            for _, tile in ipairs(revealedTiles) do
                tile.revealed = false
            end
            revealedTiles = {}
            flipBackTimer = nil
        end
    end
end

function tiles:draw()
    print(ISBRONZE)
    if ISBRONZE==false then
        if backgroundImage then
            love.graphics.draw(backgroundImage, 0, 0, 0, love.graphics.getWidth() / backgroundImage:getWidth(), love.graphics.getHeight() / backgroundImage:getHeight())
        end
        local text = "bronze key not achieved"
    love.graphics.setFont(self.font) -- Ensure the font is applied
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local textWidth = self.font:getWidth(text)
    local textHeight = self.font:getHeight()

    -- Calculate the position to center the text
    local x = (screenWidth - textWidth) / 2
    local y = (screenHeight - textHeight) / 2

    love.graphics.print(text, x, y)
    ISBRONZE=false
    else
        
    -- Draw the background image
    if backgroundImage then
        love.graphics.draw(backgroundImage, 0, 0, 0, love.graphics.getWidth() / backgroundImage:getWidth(), love.graphics.getHeight() / backgroundImage:getHeight())
    end

    --if not tilesData then return end 

    -- Calculate grid dimensions
    local gridWidth = gridSize * tileSize
    local gridHeight = gridSize * tileSize

    -- Calculate the offset to center the grid
    local offsetX = (love.graphics.getWidth() - gridWidth) / 2
    local offsetY = (love.graphics.getHeight() - gridHeight) / 2

    -- Draw the tiles grid
    for i = 0, gridSize - 1 do
        for j = 0, gridSize - 1 do
            local tile = tilesData[i][j]
            if tile then -- Check if tile exists
                -- Calculate the position of the tile
                local x = j * tileSize + offsetX
                local y = i * tileSize + offsetY

                if tile.revealed or tile.matched then
                    local asset = tileAssets[tile.type]
                    if asset then
                        -- Draw the image for the tile type
                        love.graphics.draw(asset, x, y, 0, tileSize / asset:getWidth(), tileSize / asset:getHeight())
                    else
                        -- Fallback to a placeholder rectangle
                        love.graphics.setColor(0.2, 0.8, 0.2) -- Green for revealed/matched tiles
                        love.graphics.rectangle("fill", x, y, tileSize, tileSize)
                    end
                else
                    -- Draw the hidden tile
                    love.graphics.setColor(0.8, 0.2, 0.2) -- Red for hidden tiles
                    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
                end
                
                love.graphics.setColor(1, 1, 1) -- Reset color for outlines
                love.graphics.rectangle("line", x, y, tileSize, tileSize)
            end
        end
    end
end
end

function tiles:mousepressed(x, y)
    print("Mouse clicked at:", x, y)

    if gameOver or flipBackTimer then return end -- Prevent clicks during flip-back

    -- Calculate grid dimensions
    local gridWidth = gridSize * tileSize
    local gridHeight = gridSize * tileSize

    -- Calculate the offset to center the grid
    local offsetX = (love.graphics.getWidth() - gridWidth) / 2
    local offsetY = (love.graphics.getHeight() - gridHeight) / 2

    -- Adjust the mouse click position to account for the offset
    local adjustedX = x - offsetX
    local adjustedY = y - offsetY

    -- Ensure the adjusted position is within the grid bounds
    if adjustedX < 0 or adjustedY < 0 or adjustedX >= gridWidth or adjustedY >= gridHeight then
        return -- Click is outside the grid
    end

    -- Calculate tile indices based on adjusted mouse position
    local j = math.floor(adjustedX / tileSize)
    local i = math.floor(adjustedY / tileSize)

    -- Ensure the calculated indices are within bounds
    if j >= 0 and j < gridSize and i >= 0 and i < gridSize then
        local selectedTile = tilesData[i][j]

        if selectedTile and not selectedTile.revealed and not selectedTile.matched then -- Check if selectedTile exists
            selectedTile.revealed = true
            
            table.insert(revealedTiles, selectedTile)

            if #revealedTiles == 2 then
                self:checkMatch()
            end
        end
    end
end


function tiles:checkMatch()
    if #revealedTiles == 2 then
        if revealedTiles[1].type == revealedTiles[2].type then
            revealedTiles[1].matched = true
            revealedTiles[2].matched = true
            matchesFound = matchesFound + 1
            revealedTiles = {} -- Clear the revealed list after a match
        else
            flipBackTimer = flipBackDelay -- Start the timer for flipping tiles back
        end
    end
end

function tiles:keypressed(key)
    if key == "escape" then
        
        return
    end
end 

return tiles
