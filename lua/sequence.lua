local sequence = {}

function sequence:new(list)
  self.__index = self

  local o = {}
  o.list = list
  o.time = 0
  o.value = list[1]

  return setmetatable(o, self)
end

function sequence:step(t)
  self.value = self.list[self.time + 1]

  t = t or 1
  self.time = (self.time + t) % #self.list

  return self.value
end

function sequence:shuffle() self.list = shuffle(self.list) end

function sequence:reset() self.time = 0 end

function sequence:jump(t) self.time = t % #self.list end

return sequence