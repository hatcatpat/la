local adsr = {a = 0.0, r = 0.1, func = nil}

function adsr:new(a, r)
  self.__index = self

  local o = {}
  o.a = a * rate_
  o.r = r * rate_
  o.prev = -1.0
  o.val = 1.0
  o.th = 0.0
  o.act = false
  o.func = nil

  return setmetatable(o, self)
end

function adsr:set_a(a) self.a = a * rate_ end
function adsr:set_r(r) self.r = r * rate_ end

function adsr:upd(v)
  if v then self:trig(v) end

  if not self.act then return 0.0 end

  if self.th < self.a then
    self.val = self.th / self.a
  elseif self.th < self.a + self.r then
    self.val = 1.0 - (self.th - self.a) / self.r
  else
    self.act = false
  end

  self.th = self.th + 1.0

  return self.val
end

function adsr:trig(v)
  if self.prev <= 0.0 and v > 0.0 then
    self.act = true
    self.th = 0.0

    if self.func then self.func(self) end
  end

  self.prev = v
end

return adsr
