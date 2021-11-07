buf = buffer:from("test_sample.flac")
buf2 = buffer:from("test_sample_2.flac")
buf3 = buffer:new(1, 2)

buf3:fill(function(i, j) return pulse_wave(i * la_inv_rate * 440) end)
buf3:fill(function(i, j) return rand() end)

smp = sampler:new(buf)
smp:set(buf3)
smp:set(buf)
smp.loop = false
smp:trigger()
smp.speed = 1

trig = oscil:new(4, pulse_wave)

seq = sequence:new({1, 2, 3, 4})

recbuf = buffer:new(0.1, 2)
rec = recorder:new(recbuf)
rec.sampler.loop = true
rec.sampler.speed = 1
rec:trigger()

mode = 0

del = delay:new(1, 2)
del.feedback = 0.8
del.delay = 0.1

function run()
  if trig:trigger() then
    if rand() < 0.5 then
      rec.record = not rec.record
      rec.sampler.speed = choose({0.5, 1, 2, 8, 64}) * choose({-1, 1})
      del.delay = choose({0.1, 0.2, 0.3, 1})
    end
    if rand() < 0.7 then mode = (mode + 1) % 2 end
    smp:trigger()
    smp:set(choose({buf, buf2, buf3}))
  end
  if mode == 0 then
    out(smp())
  else
    out(rec(smp()))
  end
end
