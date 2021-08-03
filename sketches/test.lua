th = 0.0
fr = 220.0 * 2

function run()
  local o = 0
  for _=1,bufsz do smp = _
    o = sin_osc(th)
    th = inc_th(th,fr)
    set_mono(o * 0.5)
  end
end
