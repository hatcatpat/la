local buffer = {}

function buffer:new(secs, chans)
  self.__index = self

  local o = {}
  o.secs = secs or 1
  o.chans = chans or 1
  o.length = floor(secs * la_rate)
  o.data = {}
  for i = 1, o.length * o.chans do o.data[i] = 0.0 end

  return setmetatable(o, self)
end

function buffer:from(name)
  self.__index = self

  local o = {}
  o.length, o.chans, o.data = load_sample(name)
  o.secs = o.length * la_inv_rate

  return setmetatable(o, self)
end

function buffer:fill(f)
  if type(f) == 'function' then
    for i = 1, self.length do
      for j = 1, self.chans do self:write(f(i, j) or 0.0, i, j) end
    end
  else
    for i = 1, self.length do
      for j = 1, self.chans do self:write(f, i, j) end
    end
  end
end

function buffer:read(index, chan)
  index = index - 1
  if chan == nil then
    local o = {}
    for i = 1, self.chans do o[i] = self.data[index * self.chans + i] end
    return o
  else
    return self.data[index * self.chans + chan]
  end
end

function buffer:write(value, index, chan)
  index = index - 1
  if chan == nil then
    for i = 1, self.chans do self.data[index * self.chans + i] = value[i] end
  else
    self.data[index * self.chans + chan] = value
  end
end

return buffer
