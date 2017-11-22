local qs = {}

function qs.new(init)
  init = init or {}
  local self = {}
  self.queue = {}
  self.enqueue = qs.enqueue
  self.update = qs.update
  return self
end

function qs:enqueue(audio)
  table.insert(self.queue,audio)
end

function qs:update(dt)
  if self.last_sound and not self.last_sound:isPlaying() then
    self.last_sound = nil
  end
  if #self.queue > 0 and not self.last_sound then
    self.last_sound = table.remove(self.queue)
    self.last_sound:play()
  end
end

return qs
