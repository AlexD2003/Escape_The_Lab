local Class = require 'lib.classic'


local IDCounter = Class:extend()

function IDCounter:new()
    self.count = 0
end

function IDCounter:get_ID()
    self.count =  self.count + 1
    return self.count
end

return IDCounter

