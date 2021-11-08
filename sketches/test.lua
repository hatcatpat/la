buf = buffer:from("test_sample.flac")
buf2 = buffer:from("test_sample_2.flac")

smp = sampler:new(buf)

trig = oscil:new(4, pulse_wave)

recbuf = buffer:new(0.1, 2)
rec = recorder:new(recbuf)
rec.sampler.loop = true
rec.sampler.speed = 1
rec:trigger()

mode = 0

del = delay:new(1, 2)
del.feedback = 0.5
del.delay = 0.01
del.pan = rand()

function run()
  if trig:trigger() then
    if rand() < 0.5 then
      rec.record = not rec.record
      rec.sampler.speed = choose({2, 64}) * choose({-1, 1})
      del.delay = choose({1, 2.5, 5}) * 0.01
      del.pan = rand()
    end
    if rand() < 0.5 then mode = (mode + 1) % 2 end
    smp:trigger()
    smp:set(choose({buf, buf2}))
    smp.speed = choose({0.5, 1, 2})
  end
  if mode == 0 then
    out(smp())
  else
    out(rec(smp()))
  end
  out(pan(del(get()), del.pan))
end

