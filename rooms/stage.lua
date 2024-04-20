Stage = Object:extend()

function Stage:new(opts)
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.interface = Interface(self)
    self.f_size = {w = gw - self.interface.width, h = gh}
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass('player')
    self.area.world:addCollisionClass('projectile')
    self.area.world:addCollisionClass('enemy', {ignores = {'projectile'}})
    self.area.world:addCollisionClass('collectable', {ignores = {'collectable', 'projectile', 'player', 'enemy'}})
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.player = self.area:addGameObject('Player', self.f_size.w/2, self.f_size.h/2)
    self.m_pos = {x = 0, y = 0}
    self.dice = nil
    self.neg_dice = nil
    self.active_dice = nil
    self.base_rock_dmg = 10
    self.rock_dmg = 10
    self.base_rock_spd = 1
    self.rock_spd = 1
    self.base_rock_HP = 120
    self.rock_HP = 120

    self.points = {
        [1] = {{6, 6}},
        [2] = {{3, 3}, {9, 9}},
        [3] = {{3, 3}, {6, 6}, {9, 9}},
        [4] = {{3, 3}, {3, 9}, {9, 3}, {9, 9}},
        [5] = {{3, 3}, {3, 9}, {9, 3}, {6, 6}, {9, 9}},
        [6] = {{3, 3}, {3, 6}, {3, 9}, {9, 3}, {9, 6}, {9, 9}}
    }

    self.static = {}

    self.timer = Timer()
    self.can_be_generated = true
    self.timer:every(0.5, function ()
        if love.math.random(1, 10) > 6 then
            self.area:addGameObject('Rock', 0, 0, {damage = self.rock_dmg, max_hp = self.rock_HP, spd = self.rock_spd})
        end
    end)

    --self.sts = StaticAsteroid(self.area, self.f_size.w / 2, self.f_size.h / 2)

    --self.interface:addObject('Dice', 100, 100)
    -- input:bind('p', function() 
    --     self.area:addGameObject('Ammo', love.math.random(0, gw), love.math.random(0, gh)) 
    -- end)
    self.director = Director(self)

    self.good_stats = {
        dmg = StatWindow(self, self.interface.x + 10, 10, {stat = 'dmg', color = default_color}),
        spd = StatWindow(self, self.interface.x + 10, 40, {stat = 'spd', color = default_color}),
        mnvr = StatWindow(self, self.interface.x + 10, 70, {stat = 'mnvr', color = default_color}),
        shld = StatWindow(self, self.interface.x + 10, 100, {stat = 'shld', color = default_color})
    }

    self.bad_stats = {
        dmg = StatWindow(self, self.interface.x + 10, 140, {stat = 'Edmg', color = hp_color}),
        spd = StatWindow(self, self.interface.x + 10, 170, {stat = 'Espd', color = hp_color}),
        hlth = StatWindow(self, self.interface.x + 10, 200, {stat = 'hlth', color = hp_color}),
    }

    love.graphics.setFont(font)
end
function Stage:finish()
    timer:after(1, function ()
        gotoRoom('Stage')
    end)
end

function Stage:roll()
    if self.can_be_generated then
        roll_sound:play()
        self.can_be_generated = false
        self.player:addAmmo(-15)
        self.player:addHP(10)
        self.interface:changeAmmo(self.player)
        self.interface:changeHP(self.player)
        self.dice = Dice(self.interface.x + 20, gh - 40)
        self.neg_dice = Dice(self.interface.x + 80, gh - 40, {negative = true, face = self.dice.face})

        if #self.static > 0 then
            for i = 1, #self.static do
                local st = self.static[i]
                st:die()
            end
        end

        self.static = {}

        for i = 1, #self.points[self.dice.face] do
            local atr = StaticAsteroid(self.area, (self.points[self.dice.face][i][1] / 3 - 1) * ((self.f_size.w - 60) / 2) + 30,
                                        (self.points[self.dice.face][i][2] / 3 - 1) * ((self.f_size.h - 60) / 2) + 30)
            table.insert(self.static, atr)
        end
    end
end

function Stage:update(dt)
    self.timer:update(dt)
    self.director:update(dt)
    self.area:update(dt)
    self.interface:update(dt)
    if input:pressed('l_click') then
        --('click')
        if self.interface.throw_button.clicked ~= true and (self.dice or self.neg_dice) then
            self.m_pos.x, self.m_pos.y = love.mouse.getPosition()
            self.m_pos.x, self.m_pos.y = self.m_pos.x / sx, self.m_pos.y / sy
            if self.dice and self.dice:checkPos(self.m_pos) then
                self.dice.grabbed = true
                self.active_dice = self.dice
                self.active_dice.relative_pos = {x = self.m_pos.x - self.active_dice.x, y = self.m_pos.y - self.active_dice.y}
            elseif self.neg_dice and self.neg_dice:checkPos(self.m_pos) then
                self.neg_dice.grabbed = true
                self.active_dice = self.neg_dice
                self.active_dice.relative_pos = {x = self.m_pos.x - self.active_dice.x, y = self.m_pos.y - self.active_dice.y}
            end
            
        end
    end

    if input:down('l_click') and self.active_dice then
        --print('down')
        self.m_pos.x, self.m_pos.y = love.mouse.getPosition()
        self.m_pos.x, self.m_pos.y = self.m_pos.x / sx, self.m_pos.y / sy
        self.active_dice.x = self.m_pos.x - self.active_dice.relative_pos.x
        self.active_dice.y = self.m_pos.y - self.active_dice.relative_pos.y
    end

    if input:released('l_click') and self.active_dice then -- Can be improved dramasticly
        --print('up')
        local flag = true
        self.active_dice.grabbed = false
        if self.active_dice.negative then
            for v, k in pairs(self.bad_stats) do
                if distance(self.active_dice.x + self.active_dice.w / 2,
                            self.active_dice.y + self.active_dice.w / 2,
                            k.dice_slot.x + k.dice_slot.w / 2,
                            k.dice_slot.y + k.dice_slot.h / 2) <= 10 then
                                k:changed(self.active_dice:getFace())
                                --self.active_dice:die()
                                self.active_dice = nil
                                self.neg_dice = nil
                                flag = false
                                break
                end
            end
            
        else
            for v, k in pairs(self.good_stats) do
                if distance(self.active_dice.x + self.active_dice.w / 2,
                            self.active_dice.y + self.active_dice.w / 2,
                            k.dice_slot.x + k.dice_slot.w / 2,
                            k.dice_slot.y + k.dice_slot.h / 2) <= 10 then
                                k:changed(self.active_dice:getFace())
                                self.active_dice = nil
                                self.dice = nil
                                flag = false
                                break
                end
            end
        end
        if flag then
            self.active_dice:goToOld()
        end
        print(self.active_dice)
        if not self.dice and not self.neg_dice then self.can_be_generated = true end
    end
    --print(self.active_dice)
    if(self.active_dice)then
        self.active_dice:update(dt)
    end

end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        --love.graphics.circle('line', gw/2, gh/2, 50)
        self.area:draw()
        if #self.static > 0 then
            for i = 1, #self.static do
                local st = self.static[i]
                st:draw()
            end
        end
        --self.sts:draw()
        self.interface:draw()
        for v, k in pairs(self.good_stats) do
            k:draw()
        end
        for v, k in pairs(self.bad_stats) do
            k:draw()
        end
        if self.dice then
            self.dice:draw()
        end
        if self.neg_dice then
            self.neg_dice:draw()
        end
        --self.area.world:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Stage:destroy()
    if self.area then 
        self.area:destroy()
        self.area = nil
    end
    if self.interface then
        self.interface:destroy()
        self.interface = nil
    end
end