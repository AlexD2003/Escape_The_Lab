local interactivity =  {}

key_img = love.graphics.newImage("assets/images/e_key.png")
key_img:setFilter("nearest","nearest")
local in_range_obj = {}

function interactivity.apply(object)
    table.insert(in_range_obj, object)
end

function interactivity.unapply(object)
    
end

function interactivity.draw()
    for index, object in ipairs(in_range_obj) do
        if object.isVisible then
            love.graphics.draw(key_img, object.x , object.y - 21)
        end
    end
    in_range_obj = {}
end

function interactivity.get_closest_object(player)
    local min = 101
    local closest_object = nil
    for index, object in ipairs(in_range_obj) do
        local distance = interactivity.get_distance(player, object)
        if distance < min then
            min = distance
            closest_object = object
        end
    end
    return closest_object
end


function interactivity.check_e(player)
    if love.keyboard.isDown("e")  and #in_range_obj > 0 then
        local obj = interactivity.get_closest_object(player)
        if obj.isVisible then
            GameState.push(require("scenes.puzzle"), obj)
        end
    end
end

function interactivity.get_distance(player, object)
    return math.sqrt((player.x - object.x)^2 + (player.y - object.y)^2)
end



return interactivity
