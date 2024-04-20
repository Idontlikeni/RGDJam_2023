StaticAsteroid = GameObject:extend()

function StaticAsteroid:new(area, x, y, opts)
    StaticAsteroid.super.new(self, area, x, y, opts)
    self.size = 30
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.size)
    self.collider:setObject(self)
    self.collider:setCollisionClass('enemy')
    self.collider:setType('static')
end

function StaticAsteroid:draw()
    love.graphics.setColor(hp_color)
    love.graphics.circle("line", self.x, self.y, self.size)
end

function StaticAsteroid:hit()

end

function StaticAsteroid:die()
    if self.collider then self.collider:destroy() end
    self.collider = nil
    self.dead = true
    self = nil
end