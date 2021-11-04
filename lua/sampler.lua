local sampler = {}

function sampler:new(name)
  self.__index = self

  local o = {}
  o.read = 0.0
  o.speed = 1.0
  o.length, o.chans, o.data = load_sample(name)
  o.value = {}
  o.loop = false
  o.cut = true
  o.active = false
  for i = 1, o.chans do o.value[i] = 0.0 end

  return setmetatable(o, self)
end

function sampler:update()
  if self.active then
    local index = floor(self.read) * self.chans

    for i = 1, self.chans do self.value[i] = self.data[index + i] end

    self.read = self.read + self.speed

    if abs(self.read) > self.length then
      if self.loop then
        self.read = self.read % self.length
      else
        self.read = 0.0
        self.active = false
        for i = 1, self.chans do self.value[i] = 0.0 end
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
