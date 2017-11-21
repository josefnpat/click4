local databaselib = {}

function databaselib.new(init)
  init = init or {}
  local self = {}

  self.width = init.width or 128 -- wat
  self.data = {}

  self.getMap = databaselib.getMap
  self.setMap = databaselib.setMap
  self.get = databaselib.get
  self.set = databaselib.set
  self.draw = databaselib.draw

  return self
end

function databaselib:getMap(x,y)
  return self.data[(y-1)*self.width+(x-1)] or 0
end

function databaselib:setMap(x,y,val)
  self.data[(y-1)*self.width+(x-1)]=val
end

function databaselib:get(i)
  return self.data[i] or 0
end

function databaselib:set(i,v)
  self.data[i] = v
end

function databaselib:draw()
  for x = 1,width do
    for y = 1,height do
      local value = self:getMap(x,y)
      if current_mode == mode_color and selected and
        x == selected.x and y == selected.y and (clock*4)%1>0.5 then
        love.graphics.setColor(color(value))
      else
        love.graphics.setColor(color(value+1))
      end
      love.graphics.rectangle("fill",(x-1)*scale,(y-1)*scale,scale,scale)
    end
  end
end

return databaselib
