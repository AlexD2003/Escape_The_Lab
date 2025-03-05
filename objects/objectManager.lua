local Class = require 'lib.classic'
local bump = require 'lib.bump'
local Camera = require "lib.camera"

local gravity = require 'objects.entities.atributes.gravity'
local rigidity = require 'objects.entities.atributes.rigidity'
local friction = require 'objects.entities.atributes.friction'
local interactivity = require 'objects.entities.atributes.interactivity'
local push = require 'objects.entities.atributes.push'

local PhysicsEntity = require 'objects.entities.physicsEntity'
local Map = require 'objects.map'
local StoryTextArea = require 'objects.StoryTextArea'
local Character = require "objects.entities.character"
local IDCounter = require "objects.IDCounter"

ISBRONZE = false
ISSILVER = false
ISGOLD = false  


local ObjectManager = Class:extend()

-- Constructor for ObjectManager, initializing world, map, and player
function ObjectManager:new()
    self.id_counter = IDCounter()  -- Initializes ID counter
    self.world = bump.newWorld()  -- Creates a new bump world for collision detection
    self.map = Map(self.id_counter)  -- Loads the map with an ID counter
    self.storyTextArea = StoryTextArea(-20, 312, 780, 100)  -- Creates a story text area on the screen
    self.storyTextArea:setText("Intr un taram indepartat era o pisica tare zdravana")  -- Sets initial story text
    self.map:loadMap("assets/maps/test_map.lua")  -- Loads the first test map
    local story = "Welcome to the lab! ..."  -- Initializes a story and formats it
    self.storyTextArea:setText(story)  -- Sets the formatted story text
    self.map:loadMap("assets/maps/final_map.lua")  -- Loads the final map
    self.groundObjects = self.map:getGroundTiles(self.world)  -- Retrieves ground tiles
    self.object_list = {}  -- Initializes the object list
    self.object_list = self.map:get_objects(self.world)  -- Populates object list from map
    self.portal = self.map:get_portal()  -- Gets the portal object
    self.portal.isVisible = false  -- Hides the portal initially
    local positions = self.map:get_start()  -- Retrieves the starting position
    self.player = Character(self.id_counter:get_ID(), positions[1], positions[2], "isRigid hasGravity isCharacter")  -- Initializes the player
    self.camera = Camera(self.player.x, self.player.y)  -- Sets up the camera to follow the player
    self.camera.scale = 2  -- Sets camera scale
    self.keys = self.map:get_keys()  -- Retrieves key objects from the map
    self:add_to_world(self.player)  -- Adds the player to the world for collision detection
end

-- Creates a new entity and adds it to the world and object list
function ObjectManager:create_entity(x, y, widht, height, atributes, game, image_name)
    local object = PhysicsEntity(self.id_counter:get_ID(), x, y, widht, height, atributes, game, image_name)  -- Creates a physics entity
    self:add_to_world(object)  -- Adds the object to the world
    table.insert(self.object_list, object)  -- Adds the object to the object list
end

-- Adds an object to the world for collision detection
function ObjectManager:add_to_world(object)
    self.world:add(object, object.x, object.y, object.width, object.height)  -- Adds the object to the world
end

-- Handles key press events for the story text area
function ObjectManager:keypressed(key)
    if self.storyTextArea then
        self.storyTextArea:keypressed(key)  -- Passes the key press to the story text area
    end
end

-- Applies forces such as gravity and friction to the player and other objects
function ObjectManager:applyForces(dt)
    gravity.apply(self.player, dt)  -- Applies gravity to the player
    for index, object in ipairs(self.object_list) do
        if object.atributes["hasGravity"] then
            gravity.apply(object, dt)  -- Applies gravity to objects with gravity attribute
        end
        if object.atributes["hasFriction"] then
            friction.apply(object, dt)  -- Applies friction to objects with friction attribute
        end
    end
end

-- Updates the state of the map, player, and objects
function ObjectManager:update(dt)
    self.map:update()  -- Updates the map state
    self:applyForces(dt)  -- Applies forces to objects
    self.player:update(dt, self.world, self.map.current_map.height * self.map.tHeight)  -- Updates the player state
    local new_x, new_y, cols, len = self.world:check(self.player, self.player.x, self.player.y)  -- Checks collisions for the player
    self.storyTextArea:update(dt)  -- Updates the story text area
    for index, object in ipairs(self.object_list) do
        if object.atributes["isMovable"] then
            object:update(dt)  -- Updates movable objects
            local obj_new_x, obj_new_y, obj_cols, obj_len = self.world:check(object, object.x, object.y)  -- Checks collisions for objects
            push.on_collision(object, obj_cols, obj_len)  -- Applies push effect on collision
            rigidity.update_collision_coord(object, obj_new_x, obj_new_y)  -- Updates collision coordinates
            self.world:move(object, object.x, object.y)  -- Moves the object in the world
        end
        if object.atributes["isInteractive"] then
            if interactivity.get_distance(self.player, object) < self.player.interact_range then
                interactivity.apply(object)  -- Applies interaction if in range
            end
        end
    end
    if interactivity.get_distance(self.player, self.portal) < self.player.interact_range then
        interactivity.apply(self.portal)  -- Applies interaction for the portal if in range
    end
    rigidity.update_collision_coord(self.player, new_x, new_y)  -- Updates collision coordinates for the player
    self.player:onCollision(cols, len, new_x, new_y)  -- Handles collision for the player
    self.world:move(self.player, self.player.x, self.player.y)  -- Moves the player in the world
    interactivity.check_e(self.player)  -- Checks interactions for the player
    local dx, dy = self.player.x - self.camera.x, self.player.y - self.camera.y  -- Calculates camera movement
    self.camera:move(dx, dy)  -- Moves the camera to follow the player
    -- Makes keys and portal visible based on conditions
    if ISBRONZE then
        self.keys[1].isVisible = true
    end
    if ISSILVER then
        self.keys[2].isVisible = true
    end
    if ISGOLD then
        self.keys[3].isVisible = true
        self.portal.isVisible = true
    end
end

-- Draws all the objects, map, player, and UI elements on the screen
function ObjectManager:draw()
    local tx = self.player.x - love.graphics.getWidth() / 4
    local ty = self.player.y - love.graphics.getHeight() / 4
    self.map:draw(-tx, -ty, self.camera.scale, self.camera.scale)  -- Draws the map
    self.camera:attach()  -- Attaches the camera to the view
    for index, object in ipairs(self.object_list) do
        object:draw()  -- Draws each object in the object list
    end
    for index, key in ipairs(self.keys) do
        key:draw()  -- Draws each key object
    end
    self.portal:draw()  -- Draws the portal
    interactivity.draw()  -- Draws interactive elements
    self.player:draw(self.map.current_map.height * self.map.tHeight)  -- Draws the player
    self.camera:detach()  -- Detaches the camera after drawing
    self.storyTextArea:draw()  -- Draws the story text area
end

return ObjectManager  -- Returns the ObjectManager class
