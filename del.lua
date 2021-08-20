local del = {}

local buf = require "buf"

function del:new(dur, chans)
  self.__index = self

  local o = {}
  o.buf = buf:new(dur, chans)
  o.r = 0.0
  o.w = 0.0
  o.fr = 1.0
  o.val = {}
  for i=1, chans do
    o.val[i] = 0.0
  end

  return setmetatable(o, self)
end

function del:set_r(r)
  self.r = (r * rate) % self.buf.sz
end

function del:upd(v)
  if v and #v == self.buf.chans then
    self.buf:write(v, floor(self.w) + 1)
  end

  self.val = self.buf:read(floor(self.w + self.r) % self.buf.sz + 1)
  self.w = (self.w + self.fr) % self.buf.sz

  return self.val
end

return del
