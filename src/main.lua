io.stdout:setvbuf("no")

git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

width = 64
height = 64
scale = 8
debug_mode = false
contrast = 31
darkness = 15
clock_speed = 0.25

bits = 4

font = love.graphics.newImageFont("font.png",
  " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`_*#=[]'{}",
  0)
love.graphics.setFont(font)

contextmenulib = require"contextmenu"
databaselib = require"database"
require"hsvtorgb"
qsoundlib = require"qsound"

sounds_raw = {
  [0] = "rest",
  [1] = "A",
  [2] = "As",
  [3] = "B",
  [4] = "C",
  [5] = "Cs",
  [6] = "D",
  [7] = "Ds",
  [8] = "E",
  [9] = "F",
  [10] = "Fs",
  [11] = "G",
  [12] = "Gs",
  [13] = "alt1",
  [14] = "alt2",
  [15] = "alt3",
}

sounds = {}
for i,v in pairs(sounds_raw) do
  sounds[i] = love.audio.newSource("sound/"..v..".wav","static")
end

ops = {}

table.insert(ops,{
  label = "NOP", -- No Operation
  exe = function(self)
  end,
  arg = 0,
})

table.insert(ops,{
  label = "INC", -- Increment
  exe = function(self)
    local newval = self.registers[self.args[1]] + 1
    if newval > 2^bits-1 then
      newval = 0
    end
    self.registers[self.args[1]] = newval
  end,
  arg = 1,
})

table.insert(ops,{
  label = "DEC", -- Decrement
  exe = function(self)
    local newval = self.registers[self.args[1]] - 1
    if newval < 0 then
      newval = 2^bits-1
    end
    self.registers[self.args[1]] = newval
  end,
  arg = 1,
})

table.insert(ops,{
  label = "QSOUND", -- Queue Sound
  exe = function(self)
    self.qsound:enqueue(sounds[self.registers[self.args[1]]])
  end,
  arg = 1,
})

table.insert(ops,{
  label = "JUMP", -- Jump
  exe = function(self)
    local x = (self.args[1])*16 + self.args[2]
    local y = (self.args[3])*16 + self.args[4]
    self.pc = (y*width+x-1)%(width*height)
  end,
  arg = 4,
})

table.insert(ops,{
  label = "RJUMP", -- Relative Jump
  exe = function(self)
    self.pc = (self.pc + self.args[1] + 1)%(width*height)
  end,
  arg = 1,
})

table.insert(ops,{
  label = "CRSZ", -- Compare Register Skip Zero
  exe = function(self)
    if self.registers[ self.args[1] ] == 0 then
      self.pc = (self.pc + 1) % (width*height)
    end
  end,
  arg = 1,
})

for i = #ops,16 do
  table.insert(ops,{
    label="N/A",
    arg=0,
  })
end

function color(index)
  local i = index-1
  if i == 0 then
    return {hsvtorgb(0,0,0.125,1)}
  elseif index == 16 then
    return {hsvtorgb(0,0,0.875,1)}
  else
    local h = (i-1)%14/14
    local s = 1
    local v = 1
    return {hsvtorgb(h,s,v,1)}
  end
end

function context_menu_data(nx,ny)

  local cdata = {}

  if current_mode == mode_color then

    for i = 0,2^bits-1 do
      table.insert(cdata,{
        color=color(i+1),
        label_left=i,
        label_right=ops[i+1].label,
        exe=function()
          database:setMap(selected.x,selected.y,i)
        end,
      })
    end

  end

  local ni = ny*width+nx

  table.insert(cdata,{label=nx..","..ny.." - "..ni})

  table.insert(cdata,{
    label="Save",
    exe=function()
      local image = love.image.newImageData(width,height)
      for x = 1,width do
        for y = 1,height do
          image:setPixel(x-1,y-1,unpack(color(database:getMap(x,y)+1)))
        end
      end
      image:encode("png","output.png")
    end,
  })

  table.insert(cdata,{
    label="Load",
    exe=function()
      load_program:reset()

      if love.filesystem.isFile("input.png") then

        local file = love.image.newImageData("input.png")

        load_program.data = function(self,x,y)
          local r,g,b = file:getPixel(x-1,y-1)
          local best_index = 0
          local best = math.huge
          for i = 0,bits^2 do
            local nr,ng,nb = unpack(color(i+1))
            local distance = math.sqrt( (r-nr)^2 + (g-ng)^2 + (b-nb)^2 )
            if distance < best then
              best_index,best = i,distance
            end
          end
          return best_index
        end

      else

        load_program.data = function(self,x,y) return math.random(0,2^bits) end

      end
    end,
  })

  table.insert(cdata,{
    label="Show",
    exe=function()
      love.filesystem.write("config.ini","") -- todo: add scale etc
      love.system.openURL("file://"..love.filesystem.getSaveDirectory())
    end,
  })

  return cdata
end

clock = 0

load_program = {}
load_program.data = function()
  return 0
end
function load_program:reset()
  self.dt,self.x,self.y,self.done = nil,nil,nil,nil
end
function load_program:update(count)
  if self.dt == nil then
    self.dt,self.x,self.y = 0,1,1
  end
  if self.done ~= true then
    for i = 1,count do
      database:setMap(self.x,self.y,self:data(self.x,self.y))
      self.x = self.x + 1
      if self.x > width then
        self.x = 1
        self.y = self.y + 1
        if self.y > height then
          self.done = true
        end
      end
    end
  end
end

database = databaselib.new{width=width}

function love.load()
  set_res()
  for x = 1,width do
    for y = 1,height do
      database:setMap(x,y,math.random(0,2^bits))
    end
  end
end

function love.draw()
  if debug_mode then
    love.graphics.print(scale)
  end
  current_mode:draw()
end

modes = {}

mode_color = {}
mode_color.label = "Color"
function mode_color:draw()
  database:draw()
  if selected then
    local sx,sy = (selected.x+1)*scale,(selected.y+1)*scale
    if sx+selected.cm:getWidth() > love.graphics.getWidth() then
      sx = (selected.x-2)*scale-selected.cm:getWidth()
    end
    if sy+selected.cm:getHeight() > love.graphics.getHeight() then
      sy = (selected.y-2)*scale-selected.cm:getHeight()
    end
    selected.cm:draw(sx,sy)
  end
end

table.insert(modes,mode_color)

mode_run = {}
mode_run.label = "Run"
function mode_run:enter()
  print("RUN")
  self.buffer = databaselib.new{width=width}
  self.dt = 0
  self.pc = 0
  self.registers = {}
  self.qsound = qsoundlib.new()
  for i = 0,2^bits-1 do
    self.registers[i] = 0
  end
  self.args = {}
end
function mode_run:draw()
  self.buffer:draw()
end
function mode_run:update(dt)
  self.dt = self.dt + dt
  self.qsound:update(dt)
  if self.dt > clock_speed then
    self.dt = self.dt - clock_speed
    if not self.op then
      self.op = ops[database:get(self.pc)+1]
    end
    if self.op.arg == #self.args then
      print(self.pc..":"..self.op.label.."[" .. table.concat(self.args,",") .. "]")
      if self.op.exe then
        self.op.exe(self)
      end
      self.op = nil
      self.args = {}
    else
      local val = database:get(self.pc+1)
      table.insert(self.args,val)
    end
    self.pc = (self.pc + 1)%(width*height)
  end
end

table.insert(modes,mode_run)

function set_mode(index)
  current_mode_index = index
  current_mode = modes[current_mode_index]
  if not current_mode then
    current_mode_index = 1
    current_mode = modes[current_mode_index]
  end
  if current_mode.enter then
    current_mode:enter()
  end
  love.window.setTitle("Click4 (v"..git_count.."#"..git_hash..") [Mode: "..current_mode.label.."]")
end

function get_mode()
  return current_mode_index or 1
end

set_mode(1)

function next_mode()
  set_mode(get_mode()+1)
end

function love.update(dt)
  clock = clock + dt
  load_program:update(width)
  if selected then
    if selected.cm:update(dt) then
      selected = nil
    end
  end
  if current_mode.update then
    current_mode:update(dt)
  end
end

function love.keypressed(key)
  if key == "-" or key == "_" then
    scale = math.max(1,scale - 1)
    set_res()
  elseif key == "=" or key == "+" then
    scale = scale + 1
    set_res()
  end
  if key == "escape" then
    selected = nil
  end
  if key == "tab" then
    selected = nil
    next_mode()
  end
  if key == "r" and mode_run.registers then
    local s = "R: "
    for i = 0,2^bits-1 do
      s = s .. mode_run.registers[i] .. ","
    end
    print(s)
  end
end

function love.mousepressed(x,y,button)
  if selected and not selected.cm:mouseInArea() then
    selected = nil
  end
  if not selected then
    local nx,ny = math.floor(x/scale+1),math.floor(y/scale+1)
    selected = {
      x=nx,--math.floor(x/scale+1),
      y=ny,--math.floor(y/scale+1),
      cm=contextmenulib.new{
        data=context_menu_data(nx-1,ny-1),
      },
    }
  end
end

function set_res()
  love.window.setMode(width*scale,height*scale)
end
