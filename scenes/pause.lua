-- scenes/pause.lua
local pause = {}

-- Pause menu buttons
local buttonResume = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    text = "Resume",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local buttonExit = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    text = "Exit to Menu",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local selectedButton = 1 -- Track selected button

function pause:init()
    -- Set font sizes for the pause menu
    self.fontTitle = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 48)
    self.fontButton = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 32)
    love.graphics.setFont(self.fontButton)

    -- Initialize button positions
    self:updateButtonPositions()
end

function pause:updateButtonPositions()
    -- Use dynamic screen dimensions
    local buttonWidth = love.graphics.getWidth() * 0.2
    local buttonHeight = love.graphics.getHeight() * 0.1

    -- Update button sizes and positions
    buttonResume.width, buttonResume.height = buttonWidth, buttonHeight
    buttonExit.width, buttonExit.height = buttonWidth, buttonHeight

    local offsetY = 76 -- Vertical offset for buttons
    buttonResume.x = (love.graphics.getWidth() - buttonResume.width) / 2
    buttonResume.y = (love.graphics.getHeight() * 0.5) - offsetY

    buttonExit.x = (love.graphics.getWidth() - buttonExit.width) / 2
    buttonExit.y = buttonResume.y + buttonResume.height + 20
end

function pause:draw()
    -- Draw a simple background color for pause (can be customized)
    love.graphics.setColor(0, 0, 0, 0.5)  -- semi-transparent black background
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title
    self:drawTitle()

    -- Draw buttons with hover effect
    self:drawButton(buttonResume, selectedButton == 1)
    self:drawButton(buttonExit, selectedButton == 2)
end

function pause:drawTitle()
    love.graphics.setFont(self.fontTitle)
    
    local titleText = "Paused"
    local titleWidth = self.fontTitle:getWidth(titleText)
    local titleX = (love.graphics.getWidth() - titleWidth) / 2
    local titleY = love.graphics.getHeight() * 0.2

    love.graphics.setColor(1, 1, 1) -- White color for title
    love.graphics.print(titleText, titleX, titleY)
end

function pause:drawButton(button, isSelected)
    local currentColor = button.color
    if isSelected then
        currentColor = button.hoverColor
    end

    -- Draw button rectangle
    love.graphics.setColor(currentColor)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    -- Draw button text
    love.graphics.setFont(self.fontButton)
    love.graphics.setColor(1, 1, 1)  -- White text color
    love.graphics.print(button.text, button.x + (button.width - self.fontButton:getWidth(button.text)) / 2,
                        button.y + (button.height - self.fontButton:getHeight()) / 2)
end

function pause:keypressed(key)
    if key == "up" then
        selectedButton = selectedButton - 1
        if selectedButton < 1 then selectedButton = 2 end
    elseif key == "down" then
        selectedButton = selectedButton + 1
        if selectedButton > 2 then selectedButton = 1 end
    elseif key == "return" then
        if selectedButton == 1 then
            -- Resume the game
            GameState.pop()  -- Pops the current game state and returns to the game
        elseif selectedButton == 2 then
            -- Exit to the main menu
            GameState.switch(require("scenes.menu"))
        end
    end
end

function pause:mousepressed(x, y, buttonKey, istouch, presses)
    if buttonKey == 1 then -- Left mouse click
        if self:mouseOverButton(buttonResume) then
            GameState.pop()  -- Resume the game
        elseif self:mouseOverButton(buttonExit) then
            GameState.switch(require("scenes.menu"))  -- Switch to the main menu
        end
    end
end

function pause:mouseOverButton(button)
    local mouseX, mouseY = love.mouse.getPosition()
    return mouseX > button.x and mouseX < (button.x + button.width) and mouseY > button.y and mouseY < (button.y + button.height)
end

return pause
