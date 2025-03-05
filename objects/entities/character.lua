local PhysicsEntity = require 'objects.entities.physicsEntity'
local push = require 'objects.entities.atributes.push'
local anim8 = require 'lib.anim8'

local Character = PhysicsEntity:extend()

-- Character constructor, sets up images, animations, and other character attributes
function Character:new(id, x, y, atributes)
    self.IdleSheet = love.graphics.newImage('assets/images/IdleAnimation.png')
    self.RunSheet = love.graphics.newImage('assets/images/RunAnimation.png')
    self.JumpSheet = love.graphics.newImage('assets/images/JumpAnimation.png')
    self.FallSheet = love.graphics.newImage('assets/images/FallAnimation.png')
    self.IdleSheet:setFilter("nearest","nearest")
    self.RunSheet:setFilter("nearest","nearest")
    self.JumpSheet:setFilter("nearest","nearest")
    self.FallSheet:setFilter("nearest","nearest")
    self.gridIdle = anim8.newGrid(13,18,self.IdleSheet:getWidth(),self.IdleSheet:getHeight())
    self.gridRun = anim8.newGrid(16,15,self.RunSheet:getWidth(),self.RunSheet:getHeight())
    self.gridJump = anim8.newGrid(11,17,self.JumpSheet:getWidth(),self.JumpSheet:getHeight())
    self.gridFall = anim8.newGrid(11,18,self.FallSheet:getWidth(),self.FallSheet:getHeight())

    self.animations = {
        Idle = anim8.newAnimation(self.gridIdle('1-8', 1) , 0.09),
        Run = anim8.newAnimation(self.gridRun('1-10', 1) , 0.09),
        Jump = anim8.newAnimation(self.gridJump('1-4', 1) , 0.09),
        Fall = anim8.newAnimation(self.gridFall('1-4', 1) , 0.09),
    }
    self.animationSheets = {
        Idle = self.IdleSheet,
        Run = self.RunSheet,
        Jump = self.JumpSheet,
        Fall = self.FallSheet,
    }
    self.animationGrid = {
        Idle = self.gridIdle,
        Run = self.gridRun,
        Jump = self.gridJump,
        Fall = self.gridFall,
    }
    self.anim = self.animations.Idle
    self.width = 13
    self.height = 18
    Character.super.new(self, id, x, y, self.width, self.height, atributes)
    self.jumpStrength = -300
    self.onGround = false
    self.interact_range = 100
    self.debug = 0
    self.moving = false
    self.tpCD = 1
    self.lastTP = 0
end

-- Character jump function, checks if on ground and applies jump force
function Character:jump()
    if self.onGround then
        self.velocityY = self.jumpStrength 
        self.onGround = false 
    end
end

-- Validates if the character can occupy a space without collision
function Character:validSpot(world,x,y)
    local items, len = world:queryRect(x, y, self.width, self.height)
    return len == 0
end

-- Teleports the character based on a cooldown, ensures no collisions at new location
function Character:teleport(world,mapHeight)
    local currentTime = love.timer.getTime()
    if currentTime - self.lastTP > self.tpCD then
        local screenHeight = love.graphics.getHeight()
        
        if self.y < mapHeight / 2 then
            newY = self.y + 2 * math.abs(mapHeight/2 - self.y)
        else
            newY = self.y - 2 * math.abs(mapHeight/2 - self.y)
        end

        if self:validSpot(world ,self.x ,newY) then 
            world:update(self, self.x, newY)
            self.y = newY
            self.lastTP = currentTime
        end
    end
end

-- Handles collision checks for the character with other objects
function Character:onCollision(cols, len)
    self.onGround = false
    for i = 1, len do
        local col = cols[i]
        if col.other.atributes["isRigid"] == true then
            if col.normal.y == -1 then
                self.onGround = true
                self.velocityY = 0  
            elseif col.normal.y == 1 then
                self.velocityY = 0
            end
            if col.other.atributes["isMovable"] == true then 
                if col.normal.x == 1 or col.normal.x == -1 then
                    push.apply(col.other, self.velocityX)
                end
            end
        end
    end
end

-- Updates the character's movement and handles animation transitions
function Character:update(dt,world,mapHeight)
    if love.keyboard.isDown("right") then
        self.velocityX = self.speed
    elseif love.keyboard.isDown("left") then
        self.velocityX = -self.speed
    else
        self.velocityX = 0   -- If no movement, set velocity to 0
    end
    if love.keyboard.isDown("up") then
        self:jump()
    end
    if love.keyboard.isDown("w") then
        self:teleport(world,mapHeight)
    end
    self.x = self.x + self.velocityX * dt

    -- Handling animations based on state (falling, jumping, idle, running)
    if self.onGround == false and (self.velocityY >= 5 or self.velocityY <= -5) then
        if self.velocityY < 0 then
            self.anim = self.animations.Jump
        else
            self.anim = self.animations.Fall
        end
    else
        if self.velocityX == 0 then
            self.anim = self.animations.Idle
        else 
            self.anim = self.animations.Run
        end
    end
    
    self.anim:update(dt)
end

-- Draws the character with appropriate animation and shader effects
function Character:draw(mapHeight)
    local invertShaderCode = [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords); // Get the current pixel color
            pixel.rgb = vec3(1.0) - pixel.rgb;           // Invert the RGB channels
            return pixel * color;                       // Apply the color modifier
        }
    ]]
    invertShader = love.graphics.newShader(invertShaderCode)
    if self.y < mapHeight / 2 then
        love.graphics.setShader()
    else
        love.graphics.setShader(invertShader)
    end
    for name, anim in pairs(self.animations) do
        if self.anim == anim then
            local sheet = self.animationSheets[name]
            local frameW = self.animationGrid[name].frameWidth
            local scaleX = self.velocityX < 0 and -1 or 1
            local scaleY = (name == "Run") and 1.2 or 1
            if scaleX == -1 then
                love.graphics.push()
                love.graphics.translate(frameW, 0)
                self.anim:draw(sheet, self.x, self.y, nil, scaleX, scaleY)
                love.graphics.pop()
            else
                self.anim:draw(sheet, self.x, self.y, nil, scaleX, scaleY)
            end
            break
        end
    end
    love.graphics.setShader()
end

return Character
