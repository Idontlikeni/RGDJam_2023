Test = GameObject:extend()

function Test:update(dt)
    Test.super.update(self, dt)
    self.x = self.x + 100*dt
end

function Test:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end