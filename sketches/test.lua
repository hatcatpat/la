a = gen_osc(330, saw_wv)
a2 = gen_osc(220, pul_wv)
b = gen_osc(0.5)
c = gen_osc(3, pul_wv)
c2 = gen_osc(6, pul_wv)

d = gen_del(0.1,2)
d.d = 0.3

d2 = gen_del(0.1,2)
d2.d = 0.5

d3 = gen_del(0.1,2)
d3.d = 0.9

function run()
  local lfo = upd_osc(b)
  c.fr = floor(scale_bi(lfo,1,4))
  c2.fr = (floor(scale_bi(lfo,1,4)) + 2) % 16
  a.fr = c.fr * 110
  a2.fr = c2.fr * 110
  d.d = scale_bi(lfo,0.0,1.0)
  local o = upd_osc(a) * (upd_osc(c) > 0 and 1 or 0)
  local o2 = upd_osc(a2) * (upd_osc(c2) > 0 and 1 or 0)
  local oo = upd_del1(d,(o+o2) * 0.5)
  local ooo = upd_del1(d2,oo * 0.5)
  local oooo = upd_del1(d3,ooo * 0.5)
  out1(o)
  out1(o2)
  out1(oo)
  out1(ooo)
  out1(oooo)
end
