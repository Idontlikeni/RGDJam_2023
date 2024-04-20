Ammo = GameObject:extend()

function Ammo:new(area, x, y, opts)
    Ammo.super.new(self, area, x, y, opts)
    self.w, self.h = 8, 8
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setFixedRotation(false)
    self.collider:setCollisionClass('collectable')
    self.r = love.math.random(0, 2 * math.pi)
    self.v = love.math.random(10, 20)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    self.collider:applyAngularImpulse(love.math.random(-12, 12))
end

function Ammo:draw()
    love.graphics.setColor(ammo_color)
    pushRotate(self.x, self.y, self.collider:getAngle())
    love.graphics.rectangle("line", self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function Ammo:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = ammo_color, w = self.w})
    for i = 1, love.math.random(4, 8) do 
    	self.area:addGameObject('ExplodeParticle', self.x, self.y, {s = 3, color = ammo_color}) 
    end
end