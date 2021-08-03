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
rand = math.random
sin = math.sin
floor = math.floor
abs = math.abs

function scale(x, inlo, inhi, outlo, outhi)
  if inhi == inlo then
    return outlo
  else
    return (x - inlo) * (outhi - outlo) / (inhi - inlo) + outlo;
  end
end

function scale_bi(x,outlo,outhi)
  return scale(x,-1,1,outlo,outhi)
end


-- audio buffer utils
function set(v)
  buf[smp*2-1] = v[1]
  buf[smp*2] = v[2]
end

function set1(v)
  buf[smp*2-1] = v
  buf[smp*2] = v
end

function out(v)
  buf[smp*2-1] = buf[smp*2-1] + v[1]
  buf[smp*2] = buf[smp*2] + v[2]
end

function out1(v)
  buf[smp*2-1] = buf[smp*2-1] + v
  buf[smp*2] = buf[smp*2] + v
end

function pan(v,p)
  return {v * (1-p), v}
end

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

-- all these waves take a value from [0,1] and return a value from [-1,1]
function sin_wv(v)
  return math.sin(v * tau)
end

function saw_wv(v)
  return v * 2.0 - 1.0
end

function pul_wv(v)
  if v < 0.5 then
    return -1
  else
    return 1
  end
end

-- osc {th (theta), fr (freq), wv (waveform)}
function gen_osc(fr,wv)
  fr = fr or 440
  wv = wv or sin_wv
  local osc = {}
  osc.th = 0
  osc.fr = fr
  osc.wv = wv
  return osc
end

function upd_osc(osc)
  local o = osc.wv(osc.th)
  osc.th = (osc.th + osc.fr / rate) % 1.0
  return o
end
