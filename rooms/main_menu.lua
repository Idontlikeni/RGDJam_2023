Menu = Object:extend()

function Menu:new()
    self.area = Area(self)
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.m_pos = {0, 0}
    self.p_b = {x = gw/2 - 50, y = gh/2 - 10, width = 100, height = 20} -- play_button
    self.c_b = {x = gw/2 - 50, y = gh/2 - 10 + 50, width = 100, height = 20} -- controls_button

    self.font = love.graphics.newFont('fonts/m5x7.ttf', 32)
    self.font:setFilter("nearest", "nearest")
    love.graphics.setFont(self.font)
    self.title = love.graphics.newImage("title.png")
end

function Menu:update(dt)
    self.area:update(dt)
    self.m_pos = Moses.mapi({love.mouse.getPosition()}, function (v)
        return v / 3
    end) -- mouse position

    if input:pressed('l_click') then 
        if (self.m_pos[1] >= self.p_b.x and self.m_pos[1] <= self.p_b.x + self.p_b.width) and (self.m_pos[2] >= self.p_b.y and self.m_pos[2] <= self.p_b.y + self.p_b.height) then
            gotoRoom('Stage')
            start_sound:play()
        end
        if (self.m_pos[1] >= self.c_b.x and self.m_pos[1] <= self.c_b.x + self.c_b.width) and (self.m_pos[2] >= self.c_b.y and self.m_pos[2] <= self.c_b.y + self.c_b.height) then
            gotoRoom('Tutorial')
        end
    end
end

function Menu:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        love.graphics.rectangle('line', gw/2 - 50, gh/2 - 10, 100, 20)
        love.graphics.print('Start', gw/2 - 26, gh/2 - 16)
        love.graphics.rectangle('line', gw/2 - 50, gh/2 - 10 + 50, 100, 20)
        love.graphics.print('Tutorial', gw/2 - 40, gh/2 - 16 + 50)
        love.graphics.circle('fill', self.m_pos[1], self.m_pos[2], 5)
        love.graphics.draw(self.title, gw / 2 - self.title:getWidth() / 2, gh/2 - 80)
        self.area:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Menu:destroy()
    if self.area then 
        self.area:destroy()
        self.area = nil
    end
end