local Class = require 'lib.classic'

local StoryTextArea = Class:extend()

-- Initializes the StoryTextArea object with position, dimensions, and properties
function StoryTextArea:new(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.currentText = ""
    self.targetText = ""
    self.enterCount = 0
    self.enterbound = 1
    self.typingSpeed = 0.05
    self.timeSinceLastChar = 1
    self.typingComplete = true
    self.backgroundImage = love.graphics.newImage('assets/maps/papirus (1).png')
    self.backgroundImage:setFilter("nearest","nearest")
    self.lines = {}
    self.currentLine = 1
    self.showTextArea = true 
end

-- Sets the target text and prepares the text area for typing animation
function StoryTextArea:setText(text)
    self.targetText = text
    self.currentText = ""
    self.typingComplete = false
    self.timeSinceLastChar = 0
    self.lines = {}
    for line in text:gmatch("[^\n/]+") do
        table.insert(self.lines, line)
    end
end

-- Updates the typing animation based on the elapsed time (dt)
function StoryTextArea:update(dt)
    if not self.typingComplete then
        self.timeSinceLastChar = self.timeSinceLastChar + dt

        if self.timeSinceLastChar >= self.typingSpeed then
            if #self.currentText < #self.lines[self.currentLine] then
                self.currentText = self.lines[self.currentLine]:sub(1, #self.currentText + 1)
            else
                self.typingComplete = true
            end
            self.timeSinceLastChar = 0
        end
    end
end

-- Handles keypress events to navigate through the text or toggle visibility
function StoryTextArea:keypressed(key)
    if key == 'return'  then
        if self.currentLine < #self.lines then
            self.currentLine = self.currentLine + 1
            self.currentText = ""
            self.enterCount = self.enterCount + 1
            self.typingComplete = false
        end
    elseif key == 'x' then
        self.showTextArea = not self.showTextArea  
    end
end

-- Increments the enterbound variable, potentially for tracking user input
function StoryTextArea:addNewInfo()
    self.enterbound = self.enterbound + 1
end 

-- Draws the text area and its content on the screen
function StoryTextArea:draw()
    if self.showTextArea then  
        love.graphics.draw(self.backgroundImage, self.x + 1000, self.y, 0, self.width / (self.backgroundImage:getWidth() / 0.5), self.height / (self.backgroundImage:getHeight() / 1.5))

        local currentFont = love.graphics.getFont()
        local textFont = love.graphics.newFont(13)
        love.graphics.setFont(textFont)

        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.currentText, self.x + 1050, self.y + 40, self.width - 500)

        love.graphics.setColor(1, 0, 0)
        love.graphics.printf('X', self.x + 1050, self.y + 20, self.width - 80)

        love.graphics.setColor(1, 1, 1, 1)

        local nextText = "Press Enter to continue."
        local nextTextFont = love.graphics.newFont(10)
        love.graphics.setFont(nextTextFont)

        love.graphics.printf(nextText, self.x + 920, self.y + 100, self.width - 80, "center")

        love.graphics.setFont(currentFont)
    end
end

return StoryTextArea
