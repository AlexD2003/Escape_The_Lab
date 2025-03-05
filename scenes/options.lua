local options = {}
local Config = require 'objects.config'
local screen = require 'scenes.screen'
local main_menu = require 'scenes.menu'

-- List of possible resolutions
local resolutions = {
    "800x600", "1024x768", "1280x720", "1920x1080", "2560x1440"
}
local currentResolutionIndex = 4 -- Default to "1280x720"

-- Mute state
local isMuted = false

local selectedOption = 1


local muteButton = {
    x = 0, y = 0,
    width = 200, height = 50,
    text = "Mute",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local muteCheckbox = {
    x = 0, y = 0,
    size = 30,
    color = {0.5, 0.5, 0.5},
    checkedColor = {0.3, 0.8, 0.3},
    hoverColor = {0.7, 0.7, 0.7},
}


function options:init()
    Config.load()
    self.fontButton = love.graphics.newFont("assets/fonts/mainmenufont.ttf", 32)
    love.graphics.setFont(self.fontButton)
    self.background = love.graphics.newImage("assets/images/defaultmenu.jpg")
    
    -- Initialize button dimensions
    self:updateButtonPosition()

    -- Set the volume based on the mute state from the config
    if Config.isMuted then
        love.audio.setVolume(0)  -- Mute the audio if the config says so
        muteButton.text = "Unmute"
    else
        love.audio.setVolume(1)  -- Set the volume back to 100% if not muted
        muteButton.text = "Mute"
    end
end

function options:leave()
    -- Update screen dimensions and button positions before leaving options menu
    screen:updateDimensions()
    self:updateButtonPosition()
    main_menu:updateButtonPositions()
end


local resolutionButton = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
    text = "Resolution"
}

local arrowLeft = {
    x = 0, y = 0, width = 40, height = 40,
    text = "<",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local arrowRight = {
    x = 0, y = 0, width = 40, height = 40,
    text = ">",
    color = {0.5, 0.5, 0.5},
    hoverColor = {0.7, 0.7, 0.7},
}

local doneButton = {
    x = 0, y = 0, width = 150, height = 50,
    text = "Done",
    color = {0.3, 0.8, 0.3},
    hoverColor = {0.5, 0.9, 0.5},
}

function drawButtonSettings(button, isHovered, font)
    local color = button.color
    if isHovered then
        color = button.hoverColor
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    
    love.graphics.setColor(1, 1, 1)
    
    -- Check if font is loaded before using it
    if font then
        love.graphics.setFont(font)
        love.graphics.print(button.text, button.x + (button.width - font:getWidth(button.text)) / 2, button.y + (button.height - font:getHeight()) / 2)
    else
        print("Font is nil!")
    end
end 

function options:update(dt)
    self:updateButtonPosition()
end

function options:updateButtonPosition()
    local buttonWidth = screen:getWidth() * 0.2
    local buttonHeight = screen:getHeight() * 0.1

    resolutionButton.width = buttonWidth
    resolutionButton.height = buttonHeight
    
    -- Center the resolution button
    resolutionButton.x = (screen:getWidth() - resolutionButton.width) / 2
    resolutionButton.y = (screen:getHeight() - resolutionButton.height) / 2

    -- Position arrows to the left and right of the resolution button
    arrowLeft.x = resolutionButton.x - arrowLeft.width - 10
    arrowLeft.y = resolutionButton.y + (resolutionButton.height - arrowLeft.height) / 2

    arrowRight.x = resolutionButton.x + resolutionButton.width + 10
    arrowRight.y = resolutionButton.y + (resolutionButton.height - arrowRight.height) / 2

    -- Increase the space between the resolution button and the mute button
    local verticalSpacing = 60  -- Increase this value for more space between buttons
    muteButton.width = buttonWidth  -- Make sure mute button width matches others
    muteButton.x = (screen:getWidth() - muteButton.width) / 2
    muteButton.y = resolutionButton.y + resolutionButton.height + verticalSpacing

    -- Position the mute checkbox next to the mute button
    muteCheckbox.x = muteButton.x + muteButton.width + 10
    muteCheckbox.y = muteButton.y + (muteButton.height - muteCheckbox.size) / 2

    -- Position the Done button below the mute button
    doneButton.x = (screen:getWidth() - doneButton.width) / 2
    doneButton.y = muteButton.y + muteButton.height + verticalSpacing
end

function options:draw()
    if not self.fontButton then
        self:load()
    end
    
    -- Draw background and buttons
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.background, 0, 0, 0, screen:getWidth() / self.background:getWidth(), screen:getHeight() / self.background:getHeight())

    local mouseX, mouseY = love.mouse.getPosition()

    -- Draw the resolution button
    local isHovered = mouseX > resolutionButton.x and mouseX < (resolutionButton.x + resolutionButton.width) and 
                      mouseY > resolutionButton.y and mouseY < (resolutionButton.y + resolutionButton.height)
    drawButtonSettings(resolutionButton, isHovered, self.fontButton)

    -- Draw arrows
    local isHoveredLeft = mouseX > arrowLeft.x and mouseX < (arrowLeft.x + arrowLeft.width) and 
                          mouseY > arrowLeft.y and mouseY < (arrowLeft.y + arrowLeft.height)
    drawButtonSettings(arrowLeft, isHoveredLeft, self.fontButton)

    local isHoveredRight = mouseX > arrowRight.x and mouseX < (arrowRight.x + arrowRight.width) and 
                           mouseY > arrowRight.y and mouseY < (arrowRight.y + arrowRight.height)
    drawButtonSettings(arrowRight, isHoveredRight, self.fontButton)

    -- Draw current resolution text
    love.graphics.setFont(self.fontButton)
    love.graphics.print(resolutions[currentResolutionIndex], resolutionButton.x + (resolutionButton.width - self.fontButton:getWidth(resolutions[currentResolutionIndex])) / 2, resolutionButton.y + resolutionButton.height + 10)

    -- Draw the Done button
    local isHoveredDone = mouseX > doneButton.x and mouseX < (doneButton.x + doneButton.width) and 
                          mouseY > doneButton.y and mouseY < (doneButton.y + doneButton.height)
    drawButtonSettings(doneButton, isHoveredDone, self.fontButton)

    -- Draw the Mute button
    local isHoveredMute = mouseX > muteButton.x and mouseX < (muteButton.x + muteButton.width) and 
                          mouseY > muteButton.y and mouseY < (muteButton.y + muteButton.height)
    drawButtonSettings(muteButton, isHoveredMute, self.fontButton)

    -- Draw the mute checkbox
    local checkboxColor = isMuted and muteCheckbox.checkedColor or muteCheckbox.color
    if mouseX > muteCheckbox.x and mouseX < (muteCheckbox.x + muteCheckbox.size) and 
       mouseY > muteCheckbox.y and mouseY < (muteCheckbox.y + muteCheckbox.size) then
        checkboxColor = muteCheckbox.hoverColor
    end
    love.graphics.setColor(checkboxColor)
    love.graphics.rectangle("fill", muteCheckbox.x, muteCheckbox.y, muteCheckbox.size, muteCheckbox.size)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", muteCheckbox.x, muteCheckbox.y, muteCheckbox.size, muteCheckbox.size)

    -- Highlight the selected option (use the same hoverColor as in the main menu)
    if selectedOption == 1 then
        love.graphics.setColor(resolutionButton.hoverColor)
        love.graphics.rectangle("line", resolutionButton.x, resolutionButton.y, resolutionButton.width, resolutionButton.height)
    elseif selectedOption == 2 then
        love.graphics.setColor(muteButton.hoverColor)
        love.graphics.rectangle("line", muteButton.x, muteButton.y, muteButton.width, muteButton.height)
    elseif selectedOption == 3 then
        love.graphics.setColor(doneButton.hoverColor)
        love.graphics.rectangle("line", doneButton.x, doneButton.y, doneButton.width, doneButton.height)
    end
end



function options:mousepressed(x, y, button)
    if button == 1 then
        -- Handle resolution change using arrow buttons
        if x > arrowLeft.x and x < arrowLeft.x + arrowLeft.width and y > arrowLeft.y and y < arrowLeft.y + arrowLeft.height then
            -- Decrement the resolution index with wrap-around
            currentResolutionIndex = (currentResolutionIndex - 1) % #resolutions
            if currentResolutionIndex == 0 then
                currentResolutionIndex = #resolutions
            end
        elseif x > arrowRight.x and x < arrowRight.x + arrowRight.width and y > arrowRight.y and y < arrowRight.y + arrowRight.height then
            -- Increment the resolution index with wrap-around
            currentResolutionIndex = (currentResolutionIndex + 1) % #resolutions
            if currentResolutionIndex == 0 then
                currentResolutionIndex = 1
            end
        end

        -- Handle mute checkbox toggle
        if x > muteCheckbox.x and x < (muteCheckbox.x + muteCheckbox.size) and 
           y > muteCheckbox.y and y < (muteCheckbox.y + muteCheckbox.size) then
            isMuted = not isMuted
            Config.isMuted = isMuted
            
            -- Mute or unmute the audio
            if isMuted then
                love.audio.setVolume(0)  -- Mute audio
                muteButton.text = "Unmute"  -- Change button text to "Unmute"
            else
                love.audio.setVolume(1)  -- Restore volume to 100%
                muteButton.text = "Mute"  -- Change button text to "Mute"
            end
        end

        -- Handle "Done" button
        if x > doneButton.x and x < doneButton.x + doneButton.width and y > doneButton.y and y < doneButton.y + doneButton.height then
            local resolution = resolutions[currentResolutionIndex]
            local width, height = resolution:match("(%d+)x(%d+)")
            love.window.setMode(tonumber(width), tonumber(height))
            screen:updateDimensions()
            self:updateButtonPosition()
            self:leave()
            GameState.pop()
        end
    end
end


function options:keypressed(key)
    if key == "escape" then
        self:leave()
        GameState.pop()
    elseif key == "up" then
        -- Navigate up through the options
        selectedOption = math.max(1, selectedOption - 1)
    elseif key == "down" then
        -- Navigate down through the options
        selectedOption = math.min(3, selectedOption + 1)
    elseif key == "left" then
        -- Decrease resolution index when the left arrow key is pressed
        currentResolutionIndex = (currentResolutionIndex - 1) % #resolutions
        if currentResolutionIndex == 0 then
            currentResolutionIndex = #resolutions
        end
    elseif key == "right" then
        -- Increase resolution index when the right arrow key is pressed
        currentResolutionIndex = (currentResolutionIndex + 1) % #resolutions
        if currentResolutionIndex == 0 then
            currentResolutionIndex = 1
        end
    elseif key == "return" then
        if selectedOption == 2 then  -- Toggle mute if mute is selected
            isMuted = not isMuted
            Config.isMuted = isMuted

            if isMuted then
                love.audio.setVolume(0)  -- Mute audio
                muteButton.text = "Unmute"  -- Change button text to "Unmute"
            else
                love.audio.setVolume(1)  -- Restore volume to 100%
                muteButton.text = "Mute"  -- Change button text to "Mute"
            end
        elseif selectedOption == 3 then  -- Handle Done button
            local resolution = resolutions[currentResolutionIndex]
            local width, height = resolution:match("(%d+)x(%d+)")
            love.window.setMode(tonumber(width), tonumber(height))
            screen:updateDimensions()
            self:updateButtonPosition()
            self:leave()
            GameState.pop()
        end
    end
end


function love.resize(w, h)
    screen:updateDimensions()
    main_menu:updateButtonPositions()
    options:updateButtonPosition()
    main_menu:init()
end

return options
