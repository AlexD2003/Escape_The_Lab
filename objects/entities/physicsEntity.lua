local Entity = require 'objects.entities.entity'

local PhysicsEntity = Entity:extend()


function PhysicsEntity:new(id, x, y, width, height, atributes, game, image_name)
    PhysicsEntity.super.new(self, id, x, y, width, height, atributes, game, image_name)
    self.velocityX = 0
    self.velocityY = 0
    self.speed = 100
    self.onGround = false
    self.friction = 0.8
end

function PhysicsEntity:update(dt)
    self.x = self.x + self.velocityX * dt
end

return PhysicsEntity
