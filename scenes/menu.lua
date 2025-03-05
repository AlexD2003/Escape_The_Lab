local Config = require 'objects.config'
local screen = require 'scenes.screen'
local main_menu = {}
local game = require "scenes.game"

-- Button definitions
local buttonStart = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    text = "Start Game",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local buttonOptions = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    text = "Options",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local buttonExit = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    text = "Exit",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local selectedButton = 1 -- Track selected button

function love.resize(w, h)
    screen:updateDimensions()
    main_menu:updateButtonPositions()
end

function main_menu:init()
    Config.load()

    -- Set font sizes
    self.fontTitle = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 48) -- Title font size
    self.fontButton = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 32) -- Button font size

    love.graphics.setFont(self.fontButton) -- Set default font to button font

    self:updateButtonPositions() -- Initialize button positions
end

function main_menu:updateButtonPositions()
    -- Use dynamic screen dimensions
    local buttonWidth = screen:getWidth() * 0.2
    local buttonHeight = screen:getHeight() * 0.1

    -- Update button sizes and positions
    buttonStart.width, buttonStart.height = buttonWidth, buttonHeight
    buttonOptions.width, buttonOptions.height = buttonWidth, buttonHeight
    buttonExit.width, buttonExit.height = buttonWidth, buttonHeight

    local offsetY = 76 -- Offset for vertical positioning of buttons

    buttonStart.x = (screen:getWidth() - buttonStart.width) / 2
    buttonStart.y = (screen:getHeight() * 0.5) - offsetY

    buttonOptions.x = (screen:getWidth() - buttonOptions.width) / 2
    buttonOptions.y = buttonStart.y + buttonStart.height + 20

    buttonExit.x = (screen:getWidth() - buttonExit.width) / 2
    buttonExit.y = buttonOptions.y + buttonOptions.height + 20
end

function drawTitle()
    love.graphics.setFont(main_menu.fontTitle)
    
    local titleText = "Escape the Lab"
    local titleWidth = main_menu.fontTitle:getWidth(titleText)
    
    -- Center the title using the current screen width
    local titleX = (screen:getWidth() - titleWidth) / 2
    local titleY = screen:getHeight() * 0.2
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(titleText, titleX, titleY)
end

function main_menu:update(dt)
    -- Update selected button based on mouse hover
    local mouseX, mouseY = love.mouse.getPosition()
    if mouseOverButton(buttonStart) then 
        selectedButton = 1
    elseif mouseOverButton(buttonOptions) then 
        selectedButton = 2
    elseif mouseOverButton(buttonExit) then 
        selectedButton = 3
    end
end

function main_menu:draw()
    -- Draw background image
    love.graphics.draw(self.backgroundImage or love.graphics.newImage("assets/images/defaultmenu.jpg"), 0, 0)

    -- Draw dynamic title and buttons with hover effect
    drawTitle()
    drawButton(buttonStart, selectedButton == 1)
    drawButton(buttonOptions, selectedButton == 2)
    drawButton(buttonExit, selectedButton == 3)
end

function main_menu:keypressed(key)
    if key == "up" then 
        selectedButton = selectedButton - 1 
        if selectedButton < 1 then selectedButton = 3 end 
    elseif key == "down" then 
        selectedButton = selectedButton + 1 
        if selectedButton > 3 then selectedButton = 1 end 
    elseif key == "return" then 
        if selectedButton == 1 then 
            GameState.push(require("scenes.game"))
        elseif selectedButton == 2 then 
            GameState.push(require("scenes.options"))
        elseif selectedButton == 3 then 
            local wfile = io.open("witness.txt", "w")
            local bfile = io.open("case.txt", "w")
            wfile:write("")
            bfile:write("")
            wfile:close()
            bfile:close()
            love.event.quit()
        end 
    end 
end 

function main_menu:mousepressed(x, y, buttonKey, istouch, presses)
    if buttonKey == 1 then -- Left mouse click
        if mouseOverButton(buttonStart) then 
            GameState.push(require("scenes.game"))
        elseif mouseOverButton(buttonOptions) then
            GameState.push(require("scenes.options"))
        elseif mouseOverButton(buttonExit)  then
            local wfile = io.open("witness.txt", "w")
            local bfile = io.open("case.txt", "w")
            wfile:write("")
            bfile:write("")
            wfile:close()
            bfile:close()
            love.event.quit()
        end
    end
end

function mouseOverButton(button)
    local mouseX, mouseY = love.mouse.getPosition()
    return mouseX > button.x and mouseX < (button.x + button.width) and mouseY > button.y and mouseY < (button.y + button.height)
end

function drawButton(button, isSelected)
    local currentColor = button.color
    
    if isSelected then currentColor = button.hoverColor end
    
    love.graphics.setColor(currentColor)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    love.graphics.setFont(main_menu.fontButton) -- Ensure we use the correct font for buttons
    love.graphics.setColor(1, 1, 1) -- Set text color to white
    love.graphics.print(button.text, button.x + (button.width - main_menu.fontButton:getWidth(button.text)) / 2, button.y + (button.height - main_menu.fontButton:getHeight()) / 2)
end

return main_menu
