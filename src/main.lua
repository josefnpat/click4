io.stdout:setvbuf("no")

git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

width = 64
height = 64
scale = 8
debug_mode = false
contrast = 31
darkness = 15
clock_speed = 1/122880 -- 4096 * 30

bits = 4
show_info = 0

font = love.graphics.newImageFont("font.png",
  " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`_*#=[]'{}",
  0)
love.graphics.setFont(font)

mouse_image = love.graphics.newImage("mouse.png")

contextmenulib = require"contextmenu"
databaselib = require"database"
require"color"
qsoundlib = require"qsound"
moonshine = require"moonshine"
sounds_raw = require"sound"

sounds = {}
for i,v in pairs(sounds_raw) do
  sounds[i] = love.audio.newSource("sound/"..(v.f)..".wav","static")
end

love.mouse.setVisible(false)

ops = require"ops"

autoload = false
cart_filename = "cart.png"

for i,arg in pairs(arg) do
  if arg == "--autoload" then
    autoload = true
  end
end

function load_cart_from_image(cart)
  if love.filesystem.isFile(cart) then
    local file = love.image.newImageData(cart)
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
end

function context_menu_data(nx,ny)

  local cdata = {}

  local ni = (ny-1)*width+nx-1

  local data = database:getMap(nx,ny)

  table.insert(cdata,{
    --color=color(data+1),
    label_left="",
    label_right="VAL="..data,
  })
  table.insert(cdata,{
    label_left=(nx-1)..","..(ny-1),
    label_right=ni,
  })

  if current_mode == mode_color then

    for i = 0,2^bits-1 do
      table.insert(cdata,{
        color=color(i+1),
        label_left=i,
        label_right=ops[i+1].label,
        tooltip=(ops[i+1].info or "").." ("..ops[i+1].short..")\n"..
          "Argument Count: "..ops[i+1].arg.."\n"..
          "Sound: "..sounds_raw[i].i,
        exe=function()
          database:setMap(selected.x,selected.y,i)
        end,
      })
    end

  end

  table.insert(cdata,{
    label="Save",
    exe=function()
      local image = love.image.newImageData(width,height)
      for x = 1,width do
        for y = 1,height do
          image:setPixel(x-1,y-1,unpack(color(database:getMap(x,y)+1)))
        end
      end
      image:encode("png",cart_filename)
    end,
  })


  table.insert(cdata,{
    label="Load",
    exe=function()
      load_program:reset()
      load_cart_from_image(cart_filename)
    end,
  })

  table.insert(cdata,{
    label="Reset",
    exe=function()
      load_program:reset()
      load_program.data = function()
        return 0
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
  load_cart_from_image(autoload and cart_filename or "default.png")
end

function love.draw()
  effect(love_draw)
end

function love_draw()
  if debug_mode then
    love.graphics.print(scale)
  end
  current_mode:draw()
  if show_info > 0 then
    local f = love.graphics.getFont()
    local s = "PC:"..(mode_run.pc or "nil").."\n"
    local maxw = 0
    for i = 0,2^bits-1 do
      local ts = "R["..(i<10 and " " or "")..i.."]: " ..
        (mode_run.registers and mode_run.registers[i] or "nil") .. "\n"
      maxw = math.max(maxw,f:getWidth(ts))
      s = s .. ts
    end
    love.graphics.setColor(255,255,255)
    local rx = show_info == 1 and 32 or (love.graphics.getWidth()-maxw-32)
    local ry = 32
    local rw,rh = maxw,(2^bits+1)*f:getHeight()
    love.graphics.rectangle("fill",rx-2,ry-2,rw+4,rh+4)
    love.graphics.setColor(0,0,0)
    love.graphics.printf(s,rx,ry,rw,"left")
  end
  if current_mode.mouse then
    local mx,my = love.mouse.getPosition()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(mouse_image,mx,my)
  end
end

modes = {}

mode_color = {}
mode_color.label = "Color"
mode_color.mouse = true
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
  if debug_mode then
    print("RUN")
  end
  self.buffer = databaselib.new{width=width}
  self.dt = 0
  self.pc = 0
  self.registers = {}
  self.qsound = qsoundlib.new()
  for i = 0,2^bits-1 do
    self.registers[i] = 0
  end
  self.args = {}
  self.op = nil
end
function mode_run:draw()
  self.buffer:draw()
end
function mode_run:update(dt)
  self.dt = self.dt + dt
  self.qsound:update(dt)
  local opsc = 0
  while self.dt > clock_speed do
    opsc = opsc + 1
    self.dt = self.dt - clock_speed
    if not self.op then
      self.op = ops[database:get(self.pc)+1]
    end
    if self.op.arg == #self.args then
      if debug_mode then
        print(self.pc..":"..self.op.label..
          "[" .. table.concat(self.args,",") .. "]")
      end
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
  if debug_mode then
    print("performed "..opsc.." ops in this frame.")
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
  love.window.setTitle("Click4 (v"..git_count.."#"..git_hash..") "..
    "[Mode: "..current_mode.label.."]")
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
  if key == "r" then
    show_info = (show_info + 1)%3
  end
end

function love.mousepressed(x,y,button)
  if selected and not selected.cm:mouseInArea() then
    selected = nil
  end
  if not selected then
    local nx,ny = math.floor(x/scale+1),math.floor(y/scale+1)
    selected = {
      x=nx,
      y=ny,
      cm=contextmenulib.new{
        data=context_menu_data(nx,ny),
      },
    }
  end
end

function set_res()
  love.window.setMode(width*scale,height*scale)
  local ce
  ce = moonshine.chain(moonshine.effects.scanlines)
  ce = ce.chain(moonshine.effects.crt)
  ce.parameters = {
    scanlines = {
      thickness=0.125,
      opacity=0.25,
    },
    crt = {
      distortionFactor = {1.03, 1.03}
    },
  }

  effect = ce

end
