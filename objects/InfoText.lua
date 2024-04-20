InfoText = Object:extend()

function InfoText:new(interface, x, y, opts)
    self.interface = interface or nil
    self.x = x or 0
    self.y = y or 0
    if opts then for k, v in pairs(opts) do self[k] = v end end
    --self.font = love.graphics.newFont('fonts/m5x7.ttf', self.size)
    --self.font:setFilter("nearest", "nearest")
end

function InfoText:draw(relative)
    local relative = relative or false
    
    love.graphics.setColor(self.color)
    if relative then
        love.graphics.print(self.text, self.x + self.interface.x, self.y + self.interface.y)
    else
        love.graphics.print(self.text, self.x, self.y)
    end
end

function InfoText:update(dt)
    
end