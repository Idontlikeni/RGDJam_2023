Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)

    self.s = opts.s or 2.5 -- size
    self.v = opts.v or 200 -- velocity

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    self.collider:setCollisionClass('projectile')

    self.trail_color = ammo_color
    self.timer:every(0.01, function ()
        self.area:addGameObject('TrailParticle', self.x - self.s * math.cos(self.r), self.y - self.s * math.sin(self.r), 
            {color = self.trail_color, d = 0.1, r = love.math.random(1, 2), parent = self}
        )
    end)
    
end

function Projectile:update(dt)
    Projectile.super.update(self, dt)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    if (self.x < 0 or self.y < 0 or self.x > self.area.f_size.w or self.y > self.area.f_size.h) then self:die() end
    if self.collider:enter('enemy') then
        local collision_data = self.collider:getEnterCollisionData('enemy')
        collision_data.collider:getObject():hit(self.damage)
        hit_sounds[love.math.random(1, #hit_sounds)]:play()
        self:die()
    end
end

function Projectile:draw()
    love.graphics.setColor(default_color)
    love.graphics.circle('fill', self.x, self.y, self.s)
end

function Projectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.s})
end