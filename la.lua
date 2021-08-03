-- default la functions
function run() end
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
function set_impl(val,chan)
  buf[smp*2-1+chan] = val
end

function set_bi(left,right)
  set_impl(left,0)
  set_impl(right,1)
end

function set_mono(val)
  set_bi(val,val)
end

function set_mono_pan(i,val,pan)
  set_bi(val * (1-pan), val * pan)
end


-- delay
function gen_del(max_del, chans)
  local del = {}
  for i=1, chans do
    del[i] = {}
  end
  del.r = 0
  del.w = 0
  for i=1,floor(rate * max_del) do
    del[1][i] = 0
    del[2][i] = 0
  end
  return del
end

function inc_del(del)
end


-- all these waves take a value from [0,1] and return a value from [-1,1]
function inc_th(th,fr)
  return (th + fr / rate) % 1.0
end

function sin_osc(v)
  return math.sin(v * tau)
end

function saw_osc(v)
  return v * 2.0 - 1.0
end

function pul_osc(v)
  if v < 0.5 then
    return -1
  else
    return 1
  end
end
