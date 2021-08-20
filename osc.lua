-- all these waves take a value from [0,1] and return a value from [-1,1]
function sin_wv(v)
  return math.sin(v * tau)
end

function saw_wv(v)
  return v * 2.0 - 1.0
end

function pul_wv(v)
  if v < 0.5 then
    return -1
  else
    return 1
  end
end

local osc = {th = 0.0, fr = 440, wv = sin_wv}

function osc:new(fr,wv)
   self.__index = self

   local o = {}
   o.fr = fr
   o.th = 0.0
   o.wv = wv
   o.val = 0.0

   return setmetatable(o, self)
end

function osc:print()
  print("fr",self.fr)
  print("th",self.th)
  print("val",self.val)
end

function osc:upd()
  self.val = self.wv(self.th)
  self.th = (self.th + self.fr / rate) % 1.0
  return self.val
end

return osc
