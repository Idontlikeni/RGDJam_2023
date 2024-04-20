Object = require 'libriares/classic/classic'
Input = require 'libriares/Input/Input'
Timer = require 'libriares/Timer'
Moses = require "libriares/moses/moses"
wf = require 'libriares/windfield'
require 'libriares/utf8'
--bf = require("libriares/breezefield")
--require 'objects/Test'
require 'utils'
require 'globals'
function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s
end

function gotoRoom(room_type, opts)
    local opts = opts or {}
    if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](opts)
end

function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function slow(amount, duration)
    slow_amount = amount
    timer:tween(duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function love.load()

    math.randomseed(os.time())

    explosion_sounds = {}
    start_sound = love.audio.newSource("sounds/start.wav", "static")
    death_sound = love.audio.newSource("sounds/death_sound.wav", "static")
    player_hit_sound = love.audio.newSource("sounds/hit_player.wav", "static")
    shoot_sound = love.audio.newSource("sounds/Laser_Shoot.wav", "static")
    picup_sound = love.audio.newSource("sounds/pickup.wav", "static")
    roll_sound = love.audio.newSource("sounds/roll.wav", "static")
    for i = 1, 4 do
        local sound = love.audio.newSource("sounds/Explosion"..i..'.wav', "static")
        table.insert(explosion_sounds, sound)
    end

    hit_sounds = {}
    for i = 1, 6 do
        local sound = love.audio.newSource("sounds/Hit_Hurt"..i..'.wav', "static")
        table.insert(hit_sounds, sound)
    end
    

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle('rough')
    local object_files = {}
    local room_files = {}
    recursiveEnumirate('objects', object_files)
    recursiveEnumirate('rooms', room_files)
    requireFiles(object_files)
    requireFiles(room_files)
    --local tst = Area(nil)
    resize(3)

    font = love.graphics.newFont('fonts/m5x7.ttf', 16)
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)

    current_room = nil
    slow_amount = 1

    timer = Timer()
    input = Input()
    input:bind('escape', 'menu')
    input:bind('mouse2', 'stage')
    input:bind('mouse1', 'l_click')
    input:bind('a', 'left')
    input:bind('d', 'right')
    input:bind('w', 'up')
    input:bind('s', 'down')
    input:bind('space', 'action')
    --input:bind('r', 'spawn')
    input:bind('f1', function()
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end)

    gotoRoom('Menu')
end

function love.update(dt)
    if current_room then current_room:update(dt) end
    if input:pressed('menu') then gotoRoom('Menu') end
    if input:pressed('stage') then gotoRoom('Stage') end
    --if input:pressed('spawn') then current_room.area:addGameObject('Rock') end
    timer:update(dt*slow_amount)
    -- if input:pressed('test') then print('pressed') end
    -- if input:released('test') then print('released') end
    -- if input:down('test') then print('down') end
    -- tst:update(dt)
end

function love.draw()
    if current_room then current_room:draw() end
end