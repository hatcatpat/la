local smp = {}

function smp:new(name)
  self.__index = self

  local o = {}
  o.r = 0
  o.fr = 1.0
  o.dur, o.chans, o.data = load_smp(name)
  o.val = {}
  for i = 1, o.chans do o.val[i] = 0.0 end

  return setmetatable(o, self)
end

function smp:upd()
  for i = 1, self.chans do
    self.val[i] = self.data[(floor(self.r) + 1) * self.chans + i - 2]
  end
  self.r = (self.r + self.fr) % self.dur
  return self.val
end

return smp
