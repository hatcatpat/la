local arr = {dur = 0, chans = 0, sz = 0, data = {}}

function arr:new(dur, chans)
  self.__index = self

  local o = {}
  o.dur = dur
  o.chans = chans
  o.data = {}
  o.sz = floor(dur * rate_)
  for i = 1, o.sz do
    o.data[i] = {}
    for j = 1, o.chans do o.data[i][j] = 0.0 end
  end

  return setmetatable(o, self)
end

function arr:check_pos(pos, chan)
  if 1 <= pos and pos <= self.sz then
    if chan then
      return 1 <= chan and chan <= self.chans
    else
      return true
    end
  else
    return false
  end
end

function arr:write1(val, pos, chan)
  if val then if self:check_pos(pos, chan) then self.data[pos][chan] = val end end
end

function arr:write(val, pos)
  if val and #val == self.chans then
    if self:check_pos(pos) then self.data[pos] = val end
  end
end

function arr:read1(pos, chan)
  if self:check_pos(pos, chan) then
    return self.data[pos][chan]
  else
    return 0.0
  end
end

function arr:read(pos)
  if self:check_pos(pos) then
    return self.data[pos]
  else
    local o = {}
    for i = 1, self.chans do o[i] = 0.0 end
    return o
  end
end

return arr
