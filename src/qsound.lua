local qs = {}

function qs.new(init)
  init = init or {}
  local self = {}

  self.queue = {}
  self.enqueue = qs.enqueue
  self.update = qs.update

  self.playdt = 0
  self.playt = 0.5

  return self
end

function qs:enqueue(audio)
  table.insert(self.queue,audio)
end

function qs:update(dt)
  if self.current_sound == nil and #self.queue > 0 then
    self.current_sound = table.remove(self.queue,1)
    self.current_sound:play()
  end
  if self.current_sound and self.current_sound:isPlaying() then
    self.playdt = self.playdt + dt
    if self.playdt >= self.playt then
      self.playdt = self.playdt - self.playt
      self.current_sound:stop()
      self.current_sound = nil
    end
  end
end

return qs
