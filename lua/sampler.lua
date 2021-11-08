local sampler = {}

function sampler:new(buffer)
  self.__index = self

  local o = {}
  o.read = 0.0
  o.speed = 1.0
  o.loop = false
  o.range = {0.0, 1.0}
  o.cut = true
  o.active = false
  o.value = {}
  if not is_nil(buffer) then self:set(buffer) end

  return setmetatable(o, self)
end

function sampler:set(buffer)
  self.buffer = buffer

  if self.buffer == nil then
    self.active = false
  else
    self.value = dup(self.buffer.chans, 0.0, self.value)
  end
end

function sampler:__call()
  if self.active then
    for i = 1, self.buffer.chans do
      self.value[i] = self.buffer:read(floor(self.read) + 1, i)
    end

    self.read = self.read + self.speed

    if abs(self.read) > self.buffer.length then
      if self.loop then
        self.read = self.read % self.buffer.length
      else
        self.read = 0.0
        self.active = false
        dup(self.buffer.chans, 0.0, self.value)
      end
    end
  end

  return self.value
end

function sampler:trigger()
  self.active = true
  if self.cut then self:reset() end
end

function sampler:reset() self.read = 0.0 end

return sampler
