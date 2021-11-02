lfo2 = oscil:new(128)
lfo = oscil:new(0.1)

b = oscil:new(110, pulse_wave)
b_env = adsr:new(0.2, 0.0)
b_pan = 0
b_pitch = {lo = 110, hi = 440}

a = oscil:new(440)
a_env = adsr:new(0.0, 0.1)

trig = oscil:new(175 / 60, pulse_wave)

seq = sequence:new({1, 0, 0, 1, 1, 0, 1, 1})

del = delay:new(2, 2)
del.feedback = 0.9
del.delay = 0.5

smp = sampler:new("test_sample.flac")
smp2 = sampler:new("test_sample_2.flac")

a = {1, 2, 3, 4}

a = shuffle(a)
info(a)

function bang()
  a_env:trigger()
  lfo2.freq = scale(rand(0, 100), 0, 100, 128, 256)
  a.release = rand() * 0.2
  smp2:reset()
  smp2:trigger()
  smp.speed = (rand() + 1) * 8
end

function run()
  lfo:update()
  lfo2:update()

  a.freq = scale(lfo2.value, -1, 1, 220, 880)
  b.freq = scale(lfo2.value, -1, 1, b_pitch.lo, b_pitch.hi)

  if trig:trigger() then
    if seq:step() == 1 or rand() < 0.1 then bang() end
    if seq.time == 0 then
      b_env:trigger()
      smp:trigger()
      b_pan = rand()
    end
  end

  out(pan(a:update() * a_env:update(), norm(lfo.value)))
  out(pan(b:update() * b_env:update() * 0.7, b_pan))

  out(del:update(get()))

  out(mul(smp:update(), 0.4))
  out(mul(smp2:update(), 0.5))
end
