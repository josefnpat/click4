io.stdout:setvbuf("no")

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

ops = {}
for i = 1,16 do
  table.insert(ops,{
    label = "NOP",
    exe = function(self)
      print("NOP"..i)
    end,
    arg = 0,
  })
end

function color(index)
  local i = index-1
  local bit0 = i%2==1
  local bit1 = math.floor(i/2)%2==1
  local bit2 = math.floor(i/4)%2==1
  local bit3 = math.floor(i/8)%2==1
  local r = (bit0 and (255-contrast) or contrast)-darkness
  local g = (bit1 and (255-contrast) or contrast)-darkness
  local b = (bit2 and (255-contrast) or contrast)-darkness
  return {
    math.floor(r/(bit3 and 2 or 1)),
    math.floor(g/(bit3 and 2 or 1)),
    math.floor(b/(bit3 and 2 or 1)),
  }
end

function context_menu_data()

  local cdata = {}

  if current_mode == mode_color then

    for i = 1,2^bits do
      table.insert(cdata,{
        color=color(i),
        exe=function()
          database:setMap(selected.x,selected.y,i-1)
        end,
      })
    end

  end

  table.insert(cdata,{label="---"})

  table.insert(cdata,{
    label="Save",
  })

  table.insert(cdata,{
    label="Load",
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
function load_program:update(count)
  if self.dt == nil then
    self.dt,self.x,self.y = 0,1,1
  end
  if self.done ~= true then
    for i = 1,count do
      database:setMap(self.x,self.y,0)
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

mode_code = {}
mode_code.label = "Code"
function mode_code:draw()
  love.graphics.setColor(255,255,255)
  love.graphics.print("code!",32,32)
end

table.insert(modes,mode_code)

mode_run = {}
mode_run.label = "Run"
function mode_run:enter()
  self.buffer = databaselib.new{width=width}
  self.dt = 0
  self.pc = 0
  self.registers = {}
  for i = 0,2^bits do
    self.registers[i] = 0 -- to test
  end
  self.args = {}
end
function mode_run:draw()
  self.buffer:draw()
end
function mode_run:update(dt)
  self.dt = self.dt + dt
  if self.dt > clock_speed then
    self.dt = self.dt - clock_speed
    if not self.op then
      self.op = ops[database:get(self.pc)+1]
    end
    if self.op.arg == #self.args then
      self.op.exe(self)
      self.op = nil
      self.args = {}
    else
      table.insert(self.args,database:get(self.pc)) -- to test
    end
    self.pc = self.pc + 1
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
  love.window.setTitle("Mode: "..current_mode.label)
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
end

function love.mousepressed(x,y,button)
  if selected and not selected.cm:mouseInArea() then
    selected = nil
  end
  if not selected then
    selected = {
      x=math.floor(x/scale+1),
      y=math.floor(y/scale+1),
      cm=contextmenulib.new{
        data=context_menu_data(),
      },
    }
  end
end

function set_res()
  love.window.setMode(width*scale,height*scale)
end
