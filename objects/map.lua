
local Class = require 'lib.classic'
local sti = require 'lib.sti'
local Entity = require "objects.entities.entity"
local PhysicsEntity = require "objects.entities.physicsEntity"

local Map = Class:extend()


function Map:new(counter)
    self.tWidth = 16
    self.tHeight = 16
    self.width = 20
    self.height = 30
    self.current_map = nil
    self.counter = counter
end

function Map:loadMap(map_name)
    self.current_map = sti(map_name)
    self.tWidth =self.current_map.tilewidth
    self.tHeight = self.current_map.tileheight
    self.width = self.current_map.height
    self.height =  self.current_map.height
end


function Map:getGroundTiles(world)
    local groundTiles = {}
    for _, layer in ipairs(self.current_map.layers) do
        if layer.name == "ground" then
            for x = 1, layer.width do
                for y = 1, layer.height do 
                    local tile = layer.data[y][x] 
                    if tile ~= nil then
                        local x_pos = (x - 1) * self.tWidth
                        local y_pos = (y - 1) * self.tHeight
                        local obj = Entity(20, x_pos, y_pos, self.tWidth, self.tHeight, "isRigid")
                        world:add(obj, obj.x, obj.y, obj.width, obj.height)
                        table.insert(groundTiles, obj)
                    end
                end
            end
        end
    end
    return groundTiles
end

function Map:get_start()
    objectLayer = self.current_map.layers["start_cat"]
    for _, object in pairs(objectLayer.objects) do
        local x, y, width, height = math.floor(object.x + 0.5), math.floor(object.y + 0.5), math.floor(object.width + 0.5), math.floor(object.height + 0.5)
        return {x,y}
    end
end

function Map:get_portal()
    objectLayer = self.current_map.layers["portal"]
    for _, object in pairs(objectLayer.objects) do
        local x, y, width, height = math.floor(object.x + 0.5), math.floor(object.y + 0.5), math.floor(object.width + 0.5), math.floor(object.height + 0.5)
        local image = object.properties.image
        local atributes = object.properties.atributes
        local game = object.properties.game

        local isVisible = object.properties.isVisible
        local entity = Entity(1, x, y, width, height, atributes, game, image, isVisible)
        print(entity.atributes.isInteractive)
        print(entity.game)
        print(entity.image)
        return entity
    end
end

function Map:get_from_layer(objectLayer, objects, world)
    for _, object in pairs(objectLayer.objects) do
        local x, y, width, height = math.floor(object.x + 0.5), math.floor(object.y + 0.5), math.floor(object.width + 0.5), math.floor(object.height + 0.5)
        local atributes = object.properties.atributes
        local game = object.properties.game
        local image = object.properties.image
        if game == nil then
            game = "-"
        end
        if atributes == nil then
            atributes = "-"
        end
        local pentity = PhysicsEntity(1, x, y, width, height, atributes, game, image)
        if pentity.atributes["isRigid"] == true then
            world:add(pentity, pentity.x, pentity.y, pentity.width, pentity.height)
        end
        table.insert(objects, pentity)
    end
end

function Map:get_objects(world)
    local objects = {}
    self:get_from_layer(self.current_map.layers["rigid_objects"] ,objects, world)
    self:get_from_layer(self.current_map.layers["movable_objects"] ,objects, world)

    return objects
end

function Map:get_keys()
    local keys ={}
    local objectLayer = self.current_map.layers["keys"]
    for _, object in pairs(objectLayer.objects) do
        local x, y, width, height = math.floor(object.x + 0.5), math.floor(object.y + 0.5), math.floor(object.width + 0.5), math.floor(object.height + 0.5)
        local image = object.properties.image
        local isVisible = object.properties.isVisible
        local entity = Entity(1, x, y, width, height, "", "", image, isVisible)
        print(entity.isVisible)
        table.insert(keys, entity)
    end
    
    return keys
end

function Map:update(dt)
    self.current_map:update(dt)
end

function Map:draw(tx, ty, camera_scale, camera_scale)
    self.current_map:draw(tx, ty, camera_scale, camera_scale)
end

return Map

