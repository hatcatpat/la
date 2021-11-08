buf = buffer:file("test_sample.flac")
buf2 = buffer:file("test_sample_2.flac")
buf3 = buffer:file("drum_120.wav")

smp = sampler:new(buf3)
smp.loop = true

trig = oscil:new(2, pulse_wave)

lfo = oscil:new(0.1, sin_wave)

smp.pan = rand()

dels = {}
for i = 1, 8 do dels[i] = delay:new(1, 2) end

for i = 1, #dels do
  dels[i].pan = rand()
  dels[i].feedback = 0.6
  dels[i].delay = (i / #dels) * 0.3
end

function run()
  local l = lfo()
  if trig:trigger() then
    smp:set_buffer(choose({buf, buf2, buf3}))
    if smp.buffer == buf3 then
      smp:breakbeat(choose({0.25, 0.5, 0.125, 0.125 / 2}))
    else
      smp:reset_range()
    end
    smp.speed = choose({0.5, 1, 2, 4, 16})
    smp.pan = rand()
    smp:trigger()
    for i = 1, #dels do dels[i].pan = rand() end
  end
  out(pan(smp(), smp.pan))
  local v = get()
  for i = #dels, 1, -1 do
    v = pan(dels[i](v), dels[i].pan)
    dels[i].delay = (i / #dels) * norm(l)
    out(v)
  end
end

