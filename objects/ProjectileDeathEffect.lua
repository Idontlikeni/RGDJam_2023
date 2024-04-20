ProjectileDeathEffect = GameObject:extend()

function ProjectileDeathEffect:new(area, x, y, opts)
    ProjectileDeathEffect.super.new(self, area, x, y, opts)
    self.stage = 1
    self.timer:after(0.1, function ()
        self.stage = 2
        self.timer:after(0.15, function ()
            self.dead = true
        end)
    end)
end

function ProjectileDeathEffect:draw()
    if self.stage == 1 then love.graphics.setColor(default_color)
    elseif self.stage == 2 then love.graphics.setColor(self.color) end
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
end