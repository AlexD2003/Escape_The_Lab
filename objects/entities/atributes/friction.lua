local friction =  {}



function friction.apply(object, dt)
    if object.velocityX < 10 and object.velocityX > 10 then
        object.velocityX = 0
    end
    object.velocityX = object.velocityX * object.friction
end


return friction
 