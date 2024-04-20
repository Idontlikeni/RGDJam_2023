StatWindow = Object:extend()

function StatWindow:new(stage, x, y, opts)
    self.stage = stage
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.x, self.y = x, y
    self.w = self.stage.interface.width - 20
    self.h = 20
    self.dead = true

    self.dice_slot = {x = self.x + 2, y = self.y + 2, w = self.h - 4, h = self.h - 4}
    self.face = 1
    self.points = {
        [1] = {{6, 6}},
        [2] = {{3, 3}, {9, 9}},
        [3] = {{3, 3}, {6, 6}, {9, 9}},
        [4] = {{3, 3}, {3, 9}, {9, 3}, {9, 9}},
        [5] = {{3, 3}, {3, 9}, {9, 3}, {6, 6}, {9, 9}},
        [6] = {{3, 3}, {3, 6}, {3, 9}, {9, 3}, {9, 6}, {9, 9}}
    }
    -- self.dice = Dice(self.dice_slot.x + 1, self.dice_slot.y + 1, {face = 1})
end

function StatWindow:changed(change)
    self.face = change
    if self.stat == 'dmg' then
        self.stage.player.damage = self.stage.player.base_damage * (1 + change / 5)
    elseif self.stat == 'spd' then
        self.stage.player.base_max_v = self.stage.player.Bbase_max_v * (1 + change / 10)
    elseif self.stat == 'mnvr' then
        self.stage.player.rv = self.stage.player.base_rv * (1 + change / 10)
    elseif self.stat == 'shld' then
        self.stage.player.shield = change
    elseif self.stat == 'Edmg' then
        self.stage.rock_dmg = math.ceil(self.stage.base_rock_dmg * (1 + change / 9))
    elseif self.stat == 'Espd' then
        self.stage.rock_spd = self.stage.base_rock_spd * (1 + change / 5)
    elseif self.stat == 'hlth' then
        self.stage.rock_HP = math.ceil(self.stage.base_rock_HP * (1 + change / 10))
    end
end

function StatWindow:update(dt)
    
end

function StatWindow:draw()
    love.graphics.setColor(self.color)
    --print('asdffffffffffff')
    love.graphics.rectangle('line', self.dice_slot.x, self.dice_slot.y, self.dice_slot.w, self.dice_slot.h)
    love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    for i = 1, #self.points[self.face] do
        love.graphics.circle('fill', self.dice_slot.x + 1 + self.points[self.face][i][1], self.dice_slot.y + 1 + self.points[self.face][i][2], 1)
    end
    love.graphics.print(self.stat, self.dice_slot.x + self.dice_slot.w + 40, self.dice_slot.y )
end

function StatWindow:die()
    self.dead = false
end

function StatWindow:destroy()
    self = nil
end