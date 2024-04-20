Tutorial = Object:extend()

function Tutorial:new()
    self.area = Area(self)
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.title = love.graphics.newImage("tutorial.png")
end

function Tutorial:update(dt)
    self.area:update(dt)
    self.m_pos = Moses.mapi({love.mouse.getPosition()}, function (v)
        return v / 3
    end) -- mouse position
end

function Tutorial:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    love.graphics.draw(self.title, gw / 2 - self.title:getWidth() / 2, gh/2 - self.title:getHeight() / 2)
        self.area:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Tutorial:destroy()
    if self.area then 
        self.area:destroy()
        self.area = nil
    end
end