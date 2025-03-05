local gravity =  {}

local gravity_value = 700

function gravity.apply(object, dt)
    if not object.onGround then
        object.velocityY = object.velocityY + gravity_value * dt
    end
    object.y = object.y + object.velocityY * dt
end


return gravity

-- se apelaza la fiecare update si modifica variabila y a obiectului