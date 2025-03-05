local Class = require 'lib.classic'


local Entity = Class:extend()

function Entity:new(id,x,y,width,height, atributes, game, image_name,isVisible)
    self.id=id
    self.x = x or 0
    self.y = y or 0
    self.width = width or 0
    self.height = height or 0
    self.image_name = image_name
    if isVisible ~= nil then
        self.isVisible = isVisible
    else
        self.isVisible = true
    end

    self.game = game
    -- atribute posibile
    self.atributes={}
    self.atributes["hasGravity"] = false
    self.atributes["isMovable"] = false
    self.atributes["isRigid"] = false
    self.atributes["isInteractive"] = false
    self.atributes["isCharacter"] = false
    self.atributes["hasFriction"] = false
    if atributes then
        self:find_atributes(atributes)
    end
    if self.image_name ~= nil then
        self:load_image()
    else
        print("Invalid image path: " .. tostring(self.image_name))
    end
end

function Entity:load_image()
    print(self.image_name)
    self.image = love.graphics.newImage(self.image_name)
    self.image:setFilter("nearest","nearest")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Entity:find_atributes(atributes)
    
    if string.find(atributes, "hasGravity") then
        self.atributes["hasGravity"] = true
    end
    if string.find(atributes, "isMovable") then
        self.atributes["isMovable"] = true
    end
    if string.find(atributes, "isRigid") then
        self.atributes["isRigid"] = true
    end
    if string.find(atributes, "isInteractive") then
        self.atributes["isInteractive"] = true
    end
    if string.find(atributes, "isCharacter") then
        self.atributes["isCharacter"] = true
    end
    if string.find(atributes, "hasFriction") then
        self.atributes["hasFriction"] = true
    end
end

function Entity:draw()
    if self.image_name ~= nil then
        if self.isVisible then
            love.graphics.draw(self.image, self.x, self.y)
        end
    else
        -- love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
        -- for tests
    end
end


return Entity

