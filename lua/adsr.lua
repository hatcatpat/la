local adsr = {}

function adsr:new(attack, release)
  self.__index = self

  local o = {}
  o.attack = attack or 0
  o.release = release or 0
  o.time = 0
  o.active = false
  o.value = 0

  return setmetatable(o, self)
end

function adsr:__call()
  if self.active then
    if self.time < self.attack + self.release then
      if self.time < self.attack then
        self.value = self.time / self.attack
      else
        self.value = 1 - (self.time - self.attack) / self.release
      end
      self.time = self.time + la_inv_rate
    else
      self.active = false
      self.value = 0
      self.time = 0
    end
  end

  return self.value
end

function adsr:trigger() self.active = true end

return adsr
