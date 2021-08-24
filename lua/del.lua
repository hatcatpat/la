local del = {fr = 1.0, fb = 0.5}

function del:new(dur, chans)
  self.__index = self

  local o = {}
  o.arr = arr:new(dur, chans)
  o.r = 0.0
  o.w = 0.0
  o.fr = 1.0
  o.fb = 0.5
  o.val = {}
  for i = 1, chans do o.val[i] = 0.0 end

  return setmetatable(o, self)
end

function del:set_r(r) self.r = (r * rate_) % self.arr.sz end

function del:upd(v)
  self.val = self.arr:read(floor(self.w + self.r) % self.arr.sz + 1)

  local v = add2(mul(v, 1.0 - self.fb), mul(self.val, self.fb))

  self.arr:write(v, floor(self.w) + 1)

  self.w = (self.w + self.fr) % self.arr.sz

  return self.val
end

return del
