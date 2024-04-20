Rock = GameObject:extend()

function Rock:new(area, x, y, opts)
    Rock.super.new(self, area, x, y, opts)

    local dir = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

    local directon = dir[love.math.random( #dir )]

    if directon[1] ~= 0 then
        self.x = self.area.f_size.w/2 + directon[1]*(self.area.f_size.w/2)
        self.y = love.math.random(16, self.area.f_size.h - 16)
    else
        self.x = love.math.random(16, self.area.f_size.w - 16)
        self.y = self.area.f_size.h/2 + directon[2]*(self.area.f_size.h/2)
    end
    --print(self.x, self.y)

    self.color = hp_color

    self.w, self.h = 8, 8
    self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(8))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('enemy')
    self.collider:setFixedRotation(false)
    self.vx = -directon[1]*love.math.random(20, 40)
    self.vy = -directon[2]*love.math.random(20, 40)
    self.collider:setLinearVelocity(self.vx * self.spd, self.vy * self.spd)
    self.collider:applyAngularImpulse(love.math.random(-50, 50))

    self.hit_flash = false
    self.max_hp = self.max_hp or 100
    self.hp = self.max_hp
end

function Rock:hit(damage)
    local damage = damage or 100
    self.hp = self.hp - damage
    if self.hp <= 0 then self:die()
    else 
        self.hit_flash = true
        self.timer:after(0.2, function ()
            self.hit_flash = false
        end)
    end
end

function Rock:update(dt)
    Rock.super.update(self, dt)
    if (self.x < 0 or self.y < 0 or self.x > self.area.f_size.w or self.y > self.area.f_size.h) then self.dead = true end
end

function Rock:draw()
    --love.graphics.circle('line', self.area.f_size.w / 2, self.area.f_size.h / 2, self.w)
    if self.hit_flash then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(self.color)
    end
    
    --love.graphics.line(self.area.f_size.w / 2, self.area.f_size.h / 2, self.x, self.y)
    --print(self.x, self.y, self.area.f_size.w/2 + self.direction*(self.area.f_size.w/2 + 48), love.math.random(16, self.area.f_size.h - 16))
    --love.graphics.circle('line', self.x, self.y, self.w)
    local points = {self.collider:getWorldPoints(self.collider.shape:getPoints())}
    love.graphics.polygon('line', points)
    love.graphics.setColor(default_color)
end

function Rock:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {w = self.w * 1.5, color = self.color})
    self.area:addGameObject('Ammo', self.x, self.y)
    explosion_sounds[love.math.random(1, 4)]:play()
end