local delay = {}

function delay:new(max_delay, chans)
  self.__index = self

  local o = {}
  o.chans = chans or 1
  o.buffer = buffer:new(max_delay, chans)
  o.read = 0
  o.write = 0
  o.delay = max_delay * 0.5
  o.feedback = 0.5
  o.value = {}
  for i = 1, chans do o.value[i] = 0 end

  return setmetatable(o, self)
end

function delay:update(input)
  self.value = self.buffer:read(self.read + 1)

  self.buffer:write(add(mul(self.value, self.feedback),
                        mul(input, 1 - self.feedback)), self.write + 1)

  self.write = (self.write + 1) % self.buffer.length
  self.read = (self.write - floor(self.delay * la_rate)) % self.buffer.length

  return self.value
end

return delay
