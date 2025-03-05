local push =  {}

function push.apply(object, velocityX)
    object.velocityX = velocityX
end

function push.on_collision(object, cols, len)
    object.onGround = false  
    for i = 1, len do
        local col = cols[i]
        local collidedObj = col.other 
        if collidedObj.atributes["isRigid"] then
            if col.normal.y < 0 then
                object.onGround = true
                object.velocityY = 0  
            elseif collidedObj.atributes["isMovable"] or collidedObj.atributes["isCharacter"] then
                push.apply(collidedObj, object.velocityX)
            end
        end
    end
end


return push