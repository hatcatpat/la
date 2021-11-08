local recorder = {}

function recorder:new(buffer)
  self.__index = self

  local o = {}
  o.write = 0
  o.record = true
  o.buffer = buffer
  o.sampler = sampler:new(buffer)

  return setmetatable(o, self)
end

function recorder:set(buffer)
  self.buffer = buffer
  if is_nil(self.buffer) then self.record = false end
  self.sampler:set(buffer)
end

function recorder:__call(input)
  if self.record then
    self.buffer:write(input, self.write + 1)
    self.write = (self.write + 1) % self.buffer.length
  end

  return self.sampler()
end

function recorder:trigger() self.sampler:trigger() end

function recorder:reset() self.write = 0 end

return recorder
