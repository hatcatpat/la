s = smp:new("test_sample.flac")
s2 = smp:new("test_sample_2.flac")

d = del:new(1, 2)
d:set_r(0.6)
d.fb = 0.9
d_r_osc = osc:new(0.05, sin_wv)
d_fb_osc = osc:new(0.05, sin_wv)
dv1 = 1.0

p_osc = osc:new(0.2, sin_wv)

d2 = del:new(1, 2)
d2:set_r(0.2)
d2.fb = 0.7
dv2 = 1.0

a = adsr:new(0.0, 0.2)

a.func = function()
  s.r = 0
  if random() < 0.5 then
    -- s.fr = random() * 4
    a:set_r(random() * 0.7)
    d2:set_r(random())
    d2.fb = random()
  end
end

b = adsr:new(0.0, 0.5)

b.func = function()
  s2.r = 0
  if random() < 0.5 then
    b:set_r(random() * 0.7)
    if random() < 0.5 then
      dv1 = 0
    else
      dv1 = 1.0
    end
    if random() < 0.5 then
      dv2 = 0
    else
      dv2 = 1.0
    end
  end
  trig_t = (trig_t + 1) % #trigs
end

b:set_r(0.1)

a_trig = osc:new(8, pul_wv)
b_trig = osc:new(8, pul_wv)

trig_t = 0
trigs = {1, 2, 1, 0, 1, 2, 1, 1, 0, 1, 2, 0, 1, 0, 1, 1}
frs = {1, 1, 4, 2, 1, 1, 8, 2, 1, 1, 0.5, 0.5}

function run()
  a:trig(gate(a_trig:upd()))
  b:trig(gate(b_trig:upd()))
  d:set_r(norm(d_r_osc:upd()) * 0.4)
  if random() < 0.5 then
    d.fb = scale_bi(d_r_osc:upd(), 0.5, 1.0)
    s2.fr = scale_bi(d_r_osc.val, 0.5, 1)
  end
  s.fr = frs[trig_t % #frs + 1]
  s2.fr = frs[trig_t % #frs + 1]
  local p = p_osc:upd()
  local sv = mul(s:upd(), a:upd() * (1 - trigs[trig_t + 1]))
  local sv2 = mul(s2:upd(), b:upd() * trigs[trig_t + 1])
  local v = mul2(add2(sv, sv2), {1.0 - p, p})
  out(v)
  out(mul(d:upd(v), 0.7 * dv1))
  out(mul(d2:upd(d.val), 0.7 * dv2))
end
