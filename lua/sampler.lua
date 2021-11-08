local sampler = {}

function sampler:new(buffer)
  self.__index = self

  local o = {}
  o.read = 0.0
  o.speed = 1.0
  o.range = {lo = 0.0, hi = 1.0}
  o.loop = false
  o.cut = true
  o.active = false
  o.value = {}
  if not is_nil(buffer) then self:set_buffer(buffer) end

  return setmetatable(o, self)
end

function sampler:set_buffer(buffer)
  self.buffer = buffer

  if self.buffer == nil then
    self.active = false
  else
    self.value = dup(self.buffer.chans, 0.0, self.value)
  end
end

function sampler:__call()
  if self.active then
    local chans = self.buffer.chans
    local length = self.buffer.length
    local index = floor(self.read) % length + 1
    for i = 1, chans do self.value[i] = self.buffer:read(index, i) end

    self.read = self.read + self.speed

    local abs_read = abs(self.read)
    local lo = self.range.lo * length
    local hi = self.range.hi * length

    if abs_read < lo or abs_read > hi then
      if self.loop then
        if abs_read < lo then
          self.read = hi
        elseif abs_read > hi then
          self.read = lo
        end
      else
        self.read = lo
        self.active = false
        dup(chans, 0.0, self.value)
      end
    end
  end

  return self.value
end

function sampler:trigger()
  self.active = true
  if self.cut then self:reset() end
end

function sampler:reset() self.read = self.range.lo * self.buffer.length end

function sampler:set_range(pos, len)
  self.range.lo = clamp(pos, 0.0, 1.0)
  self.range.hi = clamp(self.range.lo + len, 0.0, 1.0)
end

function sampler:breakbeat(len) self:set_range(floor(rand() / len) * len, len) end

function sampler:reset_range() self.range = {lo = 0.0, hi = 1.0} end

return sampler
