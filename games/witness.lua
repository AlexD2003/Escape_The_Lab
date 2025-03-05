local Class = require 'lib.classic'
local Grid = Class:extend()

function Grid:new()
    self.font = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 32)
   
    self.width = 15
    self.height = 15
    self.cellSize = 70
    self.playerX = 3
    self.playerY = 12
    self.gameOver = false
    self.deletable = ""
    self.totalCoords = ""
    self.visitedCells = {}
    self.wallpaper = love.graphics.newImage('assets/images/wallpaperWitness.png')

    -- x = 11 y = 7
    self.cells = {}
    for y = 1, self.height do
        self.cells[y] = {}
        for x = 1, self.width do
            self.cells[y][x] = { state = 0 }
        end
    end

    -- Set border cells
    for y = 1, self.width do
        self.cells[1][y].state = 1
        self.cells[self.height][y].state = 1
    end
    for x = 1, self.height do
        self.cells[x][1].state = 1
        self.cells[x][self.width].state = 1
    end

    -- Define special cells
    local squaresToChange = {
        {4, 12}, {5, 12}, {6, 12}, {7, 12}, {8, 12},
        {8, 11}, {8, 10}, {8, 9}, {9, 9}, {10, 9},
        {10, 8}, {11, 8}, {11, 7}, {11, 6}, {11, 5},
        {11, 4}, {11, 3}, {12, 3}, {7, 9}, {5, 9},
        {6, 9}, {4, 9}, {4, 8}, {4, 7}, {4, 6},
        {4, 5}, {4, 4}, {4, 3}, {5, 3}, {6, 3},
        {8, 3}, {7, 3}, {8, 3}, {9, 3}, {10, 3},
        {5, 6}, {6, 6}, {7, 6}, {7, 5}, {7, 4},
        {9, 12}, {10, 12}, {11, 12}, {13, 12}, {12, 12},
        {13, 11}, {13, 10}, {13, 9}, {13, 7}, {13, 8},
        {12, 7}, {8, 6}, {9, 6}, {10, 6}
    }

    for _, square in ipairs(squaresToChange) do
        local x, y = square[1], square[2]
        if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
            self.cells[y][x].state = 2
            self.cells[y][x].color = { r = 0.290, g = 0.208, b = 0.047 }
        end
    end

    -- Special starting cell
    local specialSquareX, specialSquareY = 3, 12
    if specialSquareX >= 1 and specialSquareX <= self.width and specialSquareY >= 1 and specialSquareY <= self.height then
        self.cells[specialSquareY][specialSquareX] = {
            state = 4,
            color = { r = 252 / 255, g = 235 / 255, b = 83 / 255 }
        }
    end

    -- Load data from file
    local file = io.open("witness.txt", "r")
    local fileContent = ""
    if file then
        fileContent = file:read("*all")
        file:close()
    end

    self.totalCoords = fileContent
    if fileContent == "" then
        print("No hay contenido")
    else
        local array = {}
        for elem in fileContent:gmatch("%d+") do
            array[#array + 1] = tonumber(elem)
        end
        for i = 1, #array - 2, 2 do
            self.cells[array[i + 1]][array[i]].state = 4
            self.cells[array[i + 1]][array[i]].color = { r = 0.988, g = 0.922, b = 0.327 }
        end
        self.playerY = array[#array]
        self.playerX = array[#array - 1]
        self.cells[self.playerY][self.playerX].state = 4
        self.cells[self.playerY][self.playerX].color = { r = 0.988, g = 0.922, b = 0.327 }
    end
end

function Grid:draw()
    if ISSILVER==false then
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
        local text = "silver key not achieved"
    love.graphics.setFont(self.font) -- Ensure the font is applied
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local textWidth = self.font:getWidth(text)
    local textHeight = self.font:getHeight()

    -- Calculate the position to center the text
    local x = (screenWidth - textWidth) / 2
    local y = (screenHeight - textHeight) / 2

    love.graphics.print(text, x, y)
    else
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
    local startX = (love.graphics.getWidth() - (self.width * self.cellSize)) / 2
    local startY = (love.graphics.getHeight() - (self.height * self.cellSize)) / 2

    for y = 1, self.height do
        for x = 1, self.width do
            local cellX = startX + (x - 1) * self.cellSize
            local cellY = startY + (y - 1) * self.cellSize

            if self.cells[y][x].state == 1 then
                love.graphics.setColor(0.224, 0.259, 0.263)
            elseif self.cells[y][x].state == 2 then
                love.graphics.setColor(self.cells[y][x].color.r, self.cells[y][x].color.g, self.cells[y][x].color.b)
            elseif self.cells[y][x].state == 4 then
                love.graphics.setColor(self.cells[y][x].color.r, self.cells[y][x].color.g, self.cells[y][x].color.b)
            else
                love.graphics.setColor(0.976, 0.710, 0.004)
            end

            love.graphics.polygon("fill", {
                cellX, cellY,
                cellX + self.cellSize, cellY,
                cellX + self.cellSize, cellY + self.cellSize,
                cellX, cellY + self.cellSize,
            })

            if x == 3 and y == 12 then
                love.graphics.setColor(0.976, 0.710, 0.004)
                love.graphics.rectangle("fill", cellX, cellY, self.cellSize, self.cellSize)
                love.graphics.setColor(252 / 255, 235 / 255, 83 / 255)
                love.graphics.arc("fill", cellX + self.cellSize, cellY + self.cellSize / 2, self.cellSize / 2, math.pi / 2, math.pi * 3 / 2)
            end

            if x == 13 and y == 3 then
                love.graphics.setColor(0.976, 0.710, 0.004)
                love.graphics.rectangle("fill", cellX, cellY, self.cellSize, self.cellSize)
                love.graphics.setColor(0.286, 0.208, 0.043)
                love.graphics.arc("fill", cellX, cellY + self.cellSize / 2, self.cellSize / 2, -math.pi / 2, math.pi / 2)

                if self.playerX == 13 and self.playerY == 3 then
                    love.graphics.setColor(252 / 255, 235 / 255, 83 / 255)
                    love.graphics.arc("fill", cellX, cellY + self.cellSize / 2, self.cellSize / 2, -math.pi / 2, math.pi / 2)
                end
            end

            if x == 1 and y == 1 then
                local radius = 10
                love.graphics.arc("fill", cellX + radius, cellY + radius, radius, math.pi, math.pi * 1.5)
            end
        end
    end

    if self.gameOver then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
end
end

function Grid:keypressed(key)
    if key == "escape" then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        love.graphics.clear()
        return
    end

    local moveDirection = {
        up = {dx = 0, dy = -1},
        down = {dx = 0, dy = 1},
        left = {dx = -1, dy = 0},
        right = {dx = 1, dy = 0}
    }

    if moveDirection[key] then
        local newX = self.playerX + moveDirection[key].dx
        local newY = self.playerY + moveDirection[key].dy

        if newX >= 1 and newX <= self.width and newY >= 1 and newY <= self.height then
            if newX == 13 and newY == 3 then
                self.cells[newY][newX].state = 2
                self.cells[newY][newX].color = {r = 0.988, g = 0.922, b = 0.327}
                self.gameOver = true
            end

            if self.cells[newY] and self.cells[newY][newX] then
                if self.cells[newY][newX].state == 4 then
                    self.cells[self.playerY][self.playerX].color = {r = 73 / 255, g = 53 / 255, b = 11 / 255}
                    self.cells[self.playerY][self.playerX].state = 2
                    self.deletable = self.deletable .. self.playerX .. " " .. self.playerY .. "\n"
                    self.playerX, self.playerY = newX, newY
                elseif self.cells[newY][newX].state ~= 0 and self.cells[newY][newX].state ~= 4 then
                    self.playerX, self.playerY = newX, newY
                    self.cells[newY][newX] = {
                        state = 4,
                        color = {r = 252 / 255, g = 235 / 255, b = 83 / 255}
                    }
                    self.totalCoords = self.totalCoords .. newX .. " " .. newY .. "\n"
                end
            else
                print("Error: Attempted to access a non-existent cell at", newX, newY)
            end
        end
    end

    if self.gameOver then
        print("-------total:")
        print(self.totalCoords)
        print("-------to del:")
        print(self.deletable)
        print("---------final:")
        print(self:removeDeletableCoords(self.totalCoords, self.deletable))
        local filew = io.open("witness.txt", "w")
        if filew then
            filew:write(self:removeDeletableCoords(self.totalCoords, self.deletable))
            filew:close()
        else
            print("Error: Could not open witness.txt for writing!")
        end
        local filewritecase = io.open("case.txt", "w")
        local filesearch = io.open("witness.txt", "r")
        local case1="11 7"
        local case2="5 6"
        local case3="8 3"
        local found=false
        if filesearch then
           for line in filesearch:lines() do
                if line == case1 then
                    filewritecase:write("1")
                    found=true
                    break
                end
                if line == case2 then
                    filewritecase:write("2")
                    found=true
                    break
                end
                if line == case3 then
                    filewritecase:write("3")
                    found=true
                    break
                end
              end
              if not found then
                filewritecase:write("0")
              end
        else
            print("Error: Could not open witness.txt for reading!")
        end

        filesearch:close()
        filewritecase:close()
        return
    end
end

function Grid:update(dt)
    if self.gameOver then
        return
    end
end

function Grid:mousepressed(x, y, button)
    if button == 1 then
        local startX = (love.graphics.getWidth() - (self.width * self.cellSize)) / 2
        local startY = (love.graphics.getHeight() - (self.height * self.cellSize)) / 2

        local gridX = math.floor((x - startX) / self.cellSize) + 1
        local gridY = math.floor((y - startY) / self.cellSize) + 1

        if gridX >= 1 and gridX <= self.width and gridY >= 1 and gridY <= self.height then
            print("Cell clicked at", gridX, gridY)
        end
    end
end

function Grid:removeDeletableCoords(content, deletable)
    local coords = {}
    for x, y in deletable:gmatch("(%d+) (%d+)") do
        coords[tonumber(x) .. " " .. tonumber(y)] = true
    end

    local result = {}
    for x, y in content:gmatch("(%d+) (%d+)") do
        if not coords[x .. " " .. y] then
            result[#result + 1] = x .. " " .. y
        end
    end

    return table.concat(result, "\n") .. "\n"
end

return Grid
