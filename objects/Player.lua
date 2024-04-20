Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)
    self.w, self.h = 9, 9
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w - 2, self)
    self.collider:setType("dynamic")
    self.collider:setObject(self)
    self.collider:setCollisionClass('player')
    self.trail_color = skill_point_color
    self.r = -math.pi/2 
    self.rv = 1 * math.pi -- rv
    self.base_rv = self.rv
    self.v = 0
    self.base_max_v = 80 -- max_v
    self.Bbase_max_v = self.base_max_v
    self.max_v = self.base_max_v
    self.a = 100
    self.attack_speed = 3
    self.invincible = false
    self.invisible = false
    self.damage = 50 -- damage
    self.base_damage = self.damage
    self.shield = 0 -- shield
    self.base_shield = 0
    self.max_boost = 100
    self.boost = self.max_boost
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2
    self.boosting = 0
    self.max_hp = 50
    self.hp = self.max_hp
    self.area.player = self
    self.max_ammo = 15
    self.ammo = 5

    self.points = {
        self.w, 0,
        -self.w, -self.w,
        -self.w / 2, 0,
        -self.w, self.w
    }
    
    self.area.interface:changeHP(self)
    self.area.interface:changeAmmo(self)
    -- self.timer:every(5, function() self.attack_speed = love.math.random(1, 2) end)
    -- self.timer:after(1 / self.attack_speed, function(func) self:shoot() self.timer:after(1 / self.attack_speed, func) end)
    self.timer:every(1 / self.attack_speed, function ()
        self:shoot()
        
    end)
    self.timer:every(0.01, function ()
        self.area:addGameObject('TrailParticle', self.x - self.w * math.cos(self.r), self.y - self.h * math.sin(self.r), 
            {color = self.trail_color, d = love.math.random(0.15, 0.16), r = love.math.random(2, 4), parent = self}
        )
    end)
    input:bind('f4', function() self:die() end)
end

function Player:addHP(amount)
    self.hp = math.min(self.hp + amount, self.max_hp)
end

function Player:addAmmo(amount)
    self.ammo = math.min(self.ammo + amount, self.max_ammo)
end

function Player:shoot()
    local d = 1.5 * self.w
    
    self.area:addGameObject('ShootEffect', self.x + d * math.cos(self.r), self.y + d * math.sin(self.r), {player = self, d = d})
    self.area:addGameObject('Projectile',  self.x + d * math.cos(self.r), self.y + d * math.sin(self.r), {r = self.r, s = 3, v = 300, damage = self.damage})
    --self.area:addGameObject('Projectile',  self.x + d * math.cos(self.r - math.pi / 4), self.y + d * math.sin(self.r - math.pi / 4), {r = self.r - math.pi / 4})
    --self.area:addGameObject('Projectile',  self.x + d * math.cos(self.r + math.pi / 4), self.y + d * math.sin(self.r + math.pi / 4), {r = self.r + math.pi / 4})
end

function Player:hit(damage)
    local damage = damage or 10
    if not self.invincible then
        self:addHP(-(damage - self.shield))
        self.area.interface:changeHP(self)
        self.invincible = true
        for i = 1, love.math.random(4, 8) do
            self.area:addGameObject('ExplodeParticle', self.x, self.y)
        end
        self.timer:after(2, function ()
            self.invincible = false
        end)
        self.timer:every(0.1, function ()
            self.invisible = not self.invisible
        end, 12)
    end
    if self.hp <= 0 then self:die() end
end

function Player:update(dt)
    Player.super.update(self, dt)

    if input:down('left') then self.r = self.r - self.rv*dt end
    if input:down('right') then self.r = self.r + self.rv*dt end
    self.max_v = self.base_max_v

    self.boost = math.min(self.boost + 10*dt, self.max_boost)
    self.boost_timer = self.boost_timer + dt
    if self.boost_timer > self.boost_cooldown then self.can_boost = true end
    self.boosting = 0
    
    if input:down('up') and self.boost > 1 and self.can_boost then 
        self.max_v = 1.5 * self.base_max_v 
        self.boosting = 1
        self.boost = self.boost - 50*dt
        if self.boost <= 1 then
            self.boosting = 0
            self.can_boost = false
            self.boost_timer = 0
        end
    end
    if input:down('down') and self.boost > 1 and self.can_boost then
        self.max_v = 0.5 * self.base_max_v 
        self.boosting = 2
        self.boost = self.boost - 50*dt
        if self.boost <= 1 then
            self.boosting = 0
            self.can_boost = false
            self.boost_timer = 0
        end
    end
    if self.boosting == 0 then
        self.trail_color = skill_point_color
    elseif self.boosting == 1 then
        self.trail_color = boost_color
    else
        self.trail_color = hp_color
    end
    self.v = math.min(self.v + self.a * dt, self.max_v)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    if (self.x < 0 or self.y < 0 or self.x > self.area.f_size.w or self.y > self.area.f_size.h) then self:die() end

    if self.collider:enter('collectable') then
        local collision_data = self.collider:getEnterCollisionData('collectable')
        local object = collision_data.collider:getObject()
        if object:is(Ammo) then
            picup_sound:play()
            object:die()
            self:addAmmo(5)
            self.area.interface:changeAmmo(self)
        end
    end

    if self.collider:enter('enemy') then
        local collision_data = self.collider:getEnterCollisionData('enemy')
        local object = collision_data.collider:getObject()
        print(object)
        if object then self:hit(object.damage) player_hit_sound:play() end
    end
    --print("Player's angle:" .. self.r)
end

function Player:draw()
    --print('HP', self.hp)
    if not self.invisible then
        love.graphics.setColor(default_color)
        pushRotate(self.x, self.y, self.r)
        local result_points = Moses.map(self.points, function (v, k)
            if k % 2 == 1 then
                
                return self.x + v
            else
                return self.y + v
            end
        end)
        love.graphics.polygon('line', result_points) -- {self.x + self.w, self.y, self.x + -self.w / 2, self.y + -self.w / 2, self.x + -self.w / 2, self.y + self.w / 2}
        love.graphics.pop()
    end
    --love.graphics.circle('line', self.x, self.y, self.w - 2)
    -- love.graphics.line(self.x, self.y, self.x + 2 * math.cos(self.r) * self.w, self.y + 2 * math.sin(self.r) * self.w)
end

function Player:destroy()
    self.super.destroy(self)
end

function Player:die()
    death_sound:play()
    self.dead = true
    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
    current_room:finish()
end