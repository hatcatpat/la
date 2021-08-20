a = osc:new(440,sin_wv)
b = osc:new(0.43,pul_wv)
c = osc:new(0.1,sin_wv)
d = osc:new(0.01,saw_wv)
e = adsr:new(0,0.2)

a.wv = saw_wv
a.wv = pul_wv
a.wv = sin_wv

c.fr = 1.1
b.fr = 8

dels = {}
for i=1, 8 do
  dels[i] = del:new(1.0,2)
  dels[i]:set_r(i/8)
end

e:set_r(0.2)

t = 0.0
T = 0
seq = {1,0,1,0, 1,0,1,1}
pan = 0.0
a.fr = 880
function run()
  --c.fr = scale_bi(d:upd(),0.1,0.5)
  --b.fr = scale_bi(c:upd(),0.5,16)
  a.fr = scale_bi(b:upd(),220,220 * 4)
  local v = pan1(a:upd() * e:upd(), pan)
  out(v)

  --local last = v
  --for _,d in ipairs(dels) do
    --d.fr = scale_bi(c.val,0.1,2.0)
    --last = mul(d:upd(last), 0.5)
    --out(last)
  --end

  t = t + 8.0/rate
  if t > 1.0 then
    if random(0,100) < 50 then
      if random(0,100) < 50 then
	a.wv = saw_wv
      else
	a.wv = pul_wv
      end
    else
      a.wv = sin_wv
    end
    if seq[T] then
      e.a = random(0,rate/8)
      e.r = random(0,rate/8)
      e:trig()
    end
    pan = scale(random(0,100),0,100,0.0,1.0)
    t = 0.0
    T = (T + 1) % #seq
  end
end
