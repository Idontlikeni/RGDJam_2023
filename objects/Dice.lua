Dice = Object:extend()

function Dice:new(x, y, opts)
    if opts then for k, v in pairs(opts) do self[k] = v end end
    --self.interface = interface
    self.x, self.y = x, y
    self.negative = self.negative or false
    self.face = self.face or love.math.random(1, 6)
    self.w = 13
    self.p = 1
    self.grabbed = false
    self.pickable = true
    self.relative_pos = {0, 0}
    self.orig_pos = {x = self.x,y = self.y}
    self.points = {
        [1] = {{6, 6}},
        [2] = {{3, 3}, {9, 9}},
        [3] = {{3, 3}, {6, 6}, {9, 9}},
        [4] = {{3, 3}, {3, 9}, {9, 3}, {9, 9}},
        [5] = {{3, 3}, {3, 9}, {9, 3}, {6, 6}, {9, 9}},
        [6] = {{3, 3}, {3, 6}, {3, 9}, {9, 3}, {9, 6}, {9, 9}}
    }
    self.timer = Timer()
    self.parent = nil
end

function Dice:goToOld()
   self.x = self.orig_pos.x
   self.y = self.orig_pos.y 
end

function Dice:checkPos(pos)
    if (pos.x >= self.x and pos.x <= self.x + self.w) 
        and (pos.y >= self.y and pos.y <= self.y + self.w) then
        return true
    else
        return false
    end
end

function Dice:throw()
    self.face = love.math.random(1, 6)
end

function Dice:getFace()
    return self.face
end

function Dice:update(dt)
    self.timer:update(dt)
end

function Dice:draw()
    if self.negative then
        love.graphics.setColor(hp_color)
    else
        love.graphics.setColor(background_color)
    end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.w)
    love.graphics.setColor(default_color)
    love.graphics.rectangle('line', self.x, self.y, self.w, self.w)
    if self.negative then
        love.graphics.setColor(background_color)
    else
        love.graphics.setColor(default_color)
    end
    for i = 1, #self.points[self.face] do
        love.graphics.circle('fill', self.x + self.points[self.face][i][1], self.y + self.points[self.face][i][2], self.p)
    end


end

function Dice:destroy()
    self = nil
end

function Dice:die()
    print('ALO BLYAT')
    self.dead = true
    self:destroy()
end