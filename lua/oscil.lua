local oscil = {}

function sin_wave(v) return math.sin(v * tau) end

function saw_wave(v) return v * 2.0 - 1.0 end

function pulse_wave(v, p)
  if v < p.width then
    return -1
  else
    return 1
  end
end

function oscil:new(freq, wave)
  self.__index = self

  local o = {}
  o.freq = freq or 440
  o.wave = wave or sin_wave
  o.phase = 0.0
  o.value = 0.0
  o.params = {width = 0.5}

  return setmetatable(o, self)
end

function oscil:update()
  self.value = self.wave(self.phase, self.params)
  self.phase = (self.phase + self.freq * la_inv_rate) % 1.0
  return self.value
end

function oscil:trigger() return not (self.value < 0) == (self:update() < 0) end

return oscil
