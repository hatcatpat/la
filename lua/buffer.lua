local buffer = {}

function buffer:new(secs, chans)
  self.__index = self

  local o = {}
  o.secs = secs or 1
  o.chans = chans or 1
  o.length = floor(secs * la_rate)
  o.data = {}
  for i = 1, o.length do
    o.data[i] = {}
    for c = 1, o.chans do o.data[i][c] = 0.0 end
  end

  return setmetatable(o, self)
end

function buffer:read(index, chan)
  if chan == nil then
    return self.data[index]
  else
    return self.data[index][chan]
  end
end

function buffer:write(value, index, chan)
  if chan == nil then
    self.data[index] = value
  else
    self.data[index][chan] = value
  end
end

return buffer
