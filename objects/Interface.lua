Interface = Object:extend()

function Interface:new(stage)
    self.stage = stage
    self.m_pos = {x = 0, y = 0}
    self.width, self.height = gw / 4, gh
    self.x, self.y = gw - self.width, 1
    self.objects = {}
    self.hp_info = InfoText(self, 10, 10, {color = hp_color, text = '0 hp', size = 16})
    self.ammo_info = InfoText(self, self.x - 65, 10, {color = ammo_color, text = '0 points', size = 16})
    self.throw_button = {x = 10, y = self.height - 25, w = self.width - 20, h = 15, clicked = false}
    self.timer = Timer()
    --self.button_clicked = false
    --table.insert(self.objects, hp_info)
end

function Interface:update(dt)
    self.timer:update(dt)
    for i = #self.objects, 1, -1 do
        local object = self.objects[i]
        object:update(dt)
        if object.dead then 
            object:destroy()
            table.remove(self.objects, i) 
        end
    end
    if input:pressed('l_click') then
        self.m_pos.x, self.m_pos.y = love.mouse.getPosition()
        self.m_pos.x, self.m_pos.y = self.m_pos.x / sx, self.m_pos.y / sy
        if (self.m_pos.x >= self.throw_button.x + self.x and self.m_pos.x <= self.throw_button.x + self.throw_button.w + self.x) 
        and (self.m_pos.y >= self.throw_button.y + self.y and self.m_pos.y <= self.throw_button.y + self.throw_button.h + self.y) then
            self.throw_button.clicked = true
            self.timer:after(0.1, function ()
                self.throw_button.clicked = false
            end)
            if self.stage.area.player.ammo >= 15 then
                self:roll()
            end
        end
    end
end

function Interface:addObject(object_type, x, y, opts)
    local opts = opts or {}
    local object = _G[object_type](self, x or 0, y or 0, opts)
    table.insert(self.objects, object)
    return object
end

function Interface:changeHP(player)
    self.hp_info.text = player.hp .. '/' .. player.max_hp .. " HP"
end

function Interface:changeAmmo(player)
    self.ammo_info.text = player.ammo .. '/' .. player.max_ammo .. " Pts"
end

function Interface:roll()
    --print('aaaaaaaaa')
    self.stage:roll()
end

function Interface:draw()
    love.graphics.setColor(background_color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(default_color)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    self.hp_info:draw()
    self.ammo_info:draw()
    --print(#self.objects)
    for i = #self.objects, 1, -1 do
        local object = self.objects[i]
        object:draw()
    end
    if self.throw_button.clicked then
        love.graphics.setColor(boost_color)
        love.graphics.rectangle('fill', self.x + self.throw_button.x, self.y + self.throw_button.y, self.throw_button.w, self.throw_button.h)
        love.graphics.setColor(background_color)
        love.graphics.print('roll the dice', self.x + self.throw_button.x + 16, self.y + self.throw_button.y - 1)
    else
        love.graphics.setColor(boost_color)
        love.graphics.rectangle('line', self.x + self.throw_button.x, self.y + self.throw_button.y, self.throw_button.w, self.throw_button.h)
        love.graphics.print('roll the dice', self.x + self.throw_button.x + 16, self.y + self.throw_button.y - 1)
    end
    
end

function Interface:destroy()
    for i = #self.objects, 1, -1 do
        local object = self.objects[i]
        object:destroy()
        table.remove(self.objects, i)
    end
    self.objects = {}
end