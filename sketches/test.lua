lfo2 = oscil:new(128, saw_wave)
lfo = oscil:new(0.5)

b = oscil:new(110, pulse_wave)
b_env = adsr:new(0.0, 0.0)
b_pan = 0
b_pitch = {lo = 110, hi = 440}

a = oscil:new(440)
a_env = adsr:new(0.0, 0.1)

trig = oscil:new(200 / 60, pulse_wave)

seq = sequence:new({1, 0, 0, 1, 1, 0, 1, 1})

del = delay:new(2, 2)
del.feedback = 0.5
del.delay = 0.1
del_use = true

smp = sampler:new("test_sample.flac")
smp.speed = 4
smp_seq = sequence:new({1, 0, 0, 0, 1, 0, 1, 0})

smp_seq:set({1, 0, 1, 0, 1, 1, 0, 0})
seq:set({1, 0, 1, 0, 1, 0, 0, 1})

smp2 = sampler:new("test_sample_2.flac")

seq:reset()
smp_seq:reset()

mode = 1

function bang()
  a_env:trigger()
  a.release = rand()
end

function run()
  lfo:update()
  lfo2:update()
  if mode == 1 then
    a.freq = scale(lfo2.value, -1, 1, 220, 220 * 8)
    b.freq = scale(lfo2.value, -1, 1, b_pitch.lo, b_pitch.hi) * b_env.value
  else
    del.delay = scale(lfo.value, -1, 1, 0.01, 2)
  end
  if trig:trigger() then
    if mode == 1 then
      if seq:step() == 1 or rand() < 0.2 then bang() end
      if seq.time == 0 then
        lfo2.freq = choose({110, 220, 330, 440, 880, 1100})
        b_env.attack = rand()
        b_env:trigger()
        b_pan = rand()
        del_use = rand() < 0.8
        b_pitch.lo = choose({32, 64, 128})
        b_pitch.hi = b_pitch.lo + choose({16, 32, 64, 128}) * 4
        del.delay = choose({0.1, 0.2, 0.3, 0.4, 0.5})
        if rand() < 0.5 then mode = 2 end
      end
      if smp_seq:step() == 1 then
        smp:trigger()
      else
        smp2:trigger()
      end
    elseif mode == 2 then
      if seq.time == 0 then
        if rand() < 0.5 then mode = 1 end
        if smp_seq:step() == 1 then
          smp:trigger()
          smp2:trigger()
        else
          a_env:trigger()
          b_env:trigger()
        end
      end
    end
  end
  out(pan(a:update() * a_env:update(), norm(lfo.value)))
  out(pan(b:update() * b_env:update() * 0.7, b_pan))
  out(mul(smp:update(), mul({b_pan, 1 - b_pan}, 0.7)))
  out(mul(smp2:update(), 0.4))
  if mode == 1 then out(del:update(get())) end
end
