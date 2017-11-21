width = 128
height = 128
scale = 5
debug_mode = false
contrast = 31
darkness = 15

contextmenulib = require"contextmenu"

function color(index)
  local i = index-1
  local bit0 = i%2==1
  local bit1 = math.floor(i/2)%2==1
  local bit2 = math.floor(i/4)%2==1
  return {
    (bit0 and (255-contrast) or contrast)-darkness,
    (bit1 and (255-contrast) or contrast)-darkness,
    (bit2 and (255-contrast) or contrast)-darkness,
  }
end

function context_menu_data()
  local data = {}

  for i = 0,7 do
    table.insert(data,{
      color=color(i),
      exe=function() end,
    })
  end

  table.insert(data,{label="---"})

  table.insert(data,{
    label="save & run",
    exe=function() end,
  })

  return data
end

clock = 0

load_program = {}
function load_program:update(dt)
  if self.dt == nil then
    self.dt,self.x,self.y = 0,1,1
  end
  if self.done ~= true then
    self.dt = self.dt + dt
    data[self.x][self.y] = 0
    self.x = self.x + 1
    if self.x > width then
      self.x = 1
      self.y = self.y + 1
      if self.y > height then
        self.done = true
      end
    end
    if self.dt > 0.01 then
      self.dt = self.dt - 0.01
    end
  end
end

function love.load()
  set_res()
  data = {}
  for x = 1,width do
    data[x] = {}
    for y = 1,height do
      data[x][y] = math.random(0,7)
    end
  end
end

function love.draw()
  if debug_mode then
    love.graphics.print(scale)
  end
  for x = 1,width do
    for y = 1,height do
      local value = data[x][y]
      if selected and x == selected.x and y == selected.y and (clock*4)%1>0.5 then
        love.graphics.setColor(color(value))
      else
        love.graphics.setColor(color(value+1))
      end
      love.graphics.rectangle("fill",(x-1)*scale,(y-1)*scale,scale,scale)
    end
  end
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

function love.update(dt)
  clock = clock + dt
  load_program:update(dt)
  if selected then
    if selected.cm:update(dt) then
      selected = nil
    end
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
end

function love.mousepressed(x,y,button)
  if not selected then
    selected = {
      x=math.floor(x/scale+1),
      y=math.floor(y/scale+1),
      cm=contextmenulib.new{
        data=context_menu_data(),
        padding=scale,
      },
    }
  end
end

function set_res()
  love.window.setMode(width*scale,height*scale)
end
