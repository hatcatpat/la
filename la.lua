-- default la functions
function run() end

function run_impl()
  for _=1,bufsz do smp = _
    set1(0)
    run()
  end
end
smp = 1
rate = 44100
bufsz = 512

-- math utils
pi = math.pi
tau = math.pi * 2.0
random = math.random
sin = math.sin
floor = math.floor
abs = math.abs
pow = math.pow

function scale(x, inlo, inhi, outlo, outhi)
  if inhi == inlo then
    return outlo
  else
    return (x - inlo) * (outhi - outlo) / (inhi - inlo) + outlo;
  end
end

function scale_bi(x,outlo,outhi) return scale(x,-1,1,outlo,outhi) end

function gate(v)
 if v > 0.0 then
   return 1.0
 else
   return 0.0
 end
end

-- audio buffer utils
function set(v)
  v = v or {0.0,0.0}
  buf[smp*2-1] = v[1] or 0.0
  buf[smp*2] = v[2] or 0.0
end

function set1(v)
  v = v or 0.0
  buf[smp*2-1] = v
  buf[smp*2] = v
end

function out(v)
  v = v or {0.0,0.0}
  buf[smp*2-1] = buf[smp*2-1] + (v[1] or 0.0)
  buf[smp*2] = buf[smp*2] + (v[2] or 0.0)
end

function out1(v)
  v = v or 0.0
  buf[smp*2-1] = buf[smp*2-1] + v
  buf[smp*2] = buf[smp*2] + v
end

function pan1(v,p)
  v = v or 0.0
  return {v * (1.0-p), v * p}
end

function pan(v,p)
  v = v or {0.0,0.0}
  return {(v[1] or 0.0) * (1.0 - p), (v[2] or 0.0)}
end

function mul1(v,a)
  v = v or 0.0
  return v * a
end

function mul(v,x)
  v = v or {0.0,0.0}
  return {(v[1] or 0.0) * x, (v[2] or 0.0) * x}
end

function mul_(v1,v2)
  v1 = v1 or {0.0,0.0}
  v2 = v2 or {0.0,0.0}
  return {(v1[1] or 0.0) * (v2[1] or 0.0), (v1[2] or 0.0) * (v2[2] or 0.0)}
end

function add1(v,a)
  v = v or 0.0
  return v + a
end

function add(v,a)
  v = v or {0.0,0.0}
  return {(v[1] or 0.0) + a, (v[2] or 0.0) + a}
end

buf = require "buf"
del = require "del"
osc = require "osc"
adsr = require "adsr"

-- buf
function gen_buf(dur, chans)
  local buf = {}
  local sz = floor(dur * rate)
  for i=1, sz do
    buf[i] = {}
    for j=1,chans do
      buf[i][j] = 0.0
    end
  end
  return buf
end

-- delay
function gen_del(max_del, chans)
  local del = {}
  del.sz = floor(max_del * rate)
  del.w = 0
  del.d = 0.5
  del.r = floor(del.d * del.sz)
  del.b = gen_buf(max_del, chans)
  return del
end

function upd_del(del,input)
  del.b[del.w + 1] = input
  local o = del.b[del.r + 1]
  del.w = (del.w + 1) % del.sz
  del.r = (del.w + floor(del.d * del.sz)) % del.sz
  return o
end

function upd_del1(del,input)
  del.b[del.w + 1][1] = input
  local o = del.b[del.r + 1][1]
  del.w = (del.w + 1) % del.sz
  del.r = (del.w + floor(del.d * del.sz)) % del.sz
  return o
end

