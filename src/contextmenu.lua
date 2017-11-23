local cm = {}

function cm.new(init)
  init = init or {}
  local self = {}

  self.draw = cm.draw
  self.update = cm.update
  self.getHeight = cm.getHeight
  self.getWidth = cm.getWidth
  self.getEntryArea = cm.getEntryArea
  self.mouseInArea = cm.mouseInArea
  self.data = init.data or {}
  self.color_off = init.color_off or {0,0,0}
  self.color_on = init.color_on or {255,255,255}
  self.color_disabled = init.color_disabled or {127,127,127}
  self.padding = init.padding or 2
  self.elementpadding = init.elementpadding or 2
  self.selectpadding = init.selectpadding or 1
  self.x,self.y,self.w,self.h = 0,0,0,0

  return self
end

function cm:draw(x,y)
  self.x,self.y,self.w,self.h = x,y,self:getWidth(),self:getHeight()
  local w,h = self.w,self.h
  love.graphics.setColor(self.color_on)
  love.graphics.rectangle("fill",x-self.padding,y-self.padding,
    w+self.padding*2,h+self.padding*2)
  local f = love.graphics.getFont()
  for i,v in pairs(self.data) do
    local vx,vy,vw,vh = self:getEntryArea(i)
    if v.hover then
      love.graphics.setColor(self.color_off)
      love.graphics.rectangle("fill",
        vx-self.selectpadding,vy-self.selectpadding,
        vw+self.selectpadding*2,vh+self.selectpadding*2)
    end
    if v.color then
      love.graphics.setColor(v.color)
      love.graphics.rectangle("fill",vx,vy,vw,vh)
    end
    if v.label or v.label_left or v.label_right then
      if v.hover then
        love.graphics.setColor(self.color_on)
      else
        love.graphics.setColor(v.exe and self.color_off or self.color_disabled)
      end
      if v.label_left then
        love.graphics.printf(v.label_left,vx,vy,vw,"left")
      end
      if v.label then
        love.graphics.printf(v.label,vx,vy,vw,"center")
      end
      if v.label_right then
        love.graphics.printf(v.label_right,vx,vy,vw,"right")
      end
      if v.tooltip and v.hover and v.hover > 0.25 then
        local ttx,tty = vx+vw+self.padding*3,vy
        local ttw = 100
        local f = love.graphics.getFont()
        local ttw,wrappedtext = f:getWrap(v.tooltip,ttw)
        local tth = #wrappedtext * f:getHeight()

        love.graphics.setColor(self.color_on)
        love.graphics.rectangle("fill",
          ttx-self.padding,tty-self.padding,
          ttw+self.padding*2,tth+self.padding*2)
        love.graphics.setColor(self.color_off)
        love.graphics.printf(v.tooltip,ttx,tty,ttw)

      end
    end
  end
end

function cm:getEntryArea(index)
  local f = love.graphics.getFont()
  return self.x,self.y+(index-1)*(f:getHeight()+self.elementpadding),
    self.w,f:getHeight()
end

function cm:mouseInArea()
  local mx,my = love.mouse.getPosition()
  return mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h
end

function cm:update(dt)
  local mx,my = love.mouse.getPosition()
  local click = love.mouse.isDown(1,2,3)
  for i,v in pairs(self.data) do
    local x,y,w,h = self:getEntryArea(i)
    if mx >= x and mx <= x+w and my >= y and my <= y+h then
      v.hover = (v.hover or 0) + dt
      if click then
        if v.exe then
          v.exe()
        end
        return true
      end
    else
      v.hover = nil
    end
  end
  return false
end

function cm:getHeight()
  local f = love.graphics.getFont()
  return #self.data*(f:getHeight()+self.elementpadding)-self.elementpadding
end

function cm:getWidth()
  local f = love.graphics.getFont()
  local width = f:getHeight()
  for _,v in pairs(self.data) do
    width = math.max(width,
      f:getWidth(v.label_left or "") +
      f:getWidth(v.label or "") +
      f:getWidth(v.label_right or "") +
      (v.label == nil and 8 or 0)
    )
  end
  return width
end

return cm
