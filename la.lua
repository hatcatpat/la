-- default la functions
function run() end

function run_()
  for _ = 1, bufsz_ do
    pos_ = _
    set1(0)
    run()
  end
end
pos_ = 1
rate_ = 44100
bufsz_ = 512

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

function scale_bi(x, outlo, outhi) return scale(x, -1, 1, outlo, outhi) end
function norm(x) return scale(x, -1, 1, 0, 1) end
function bi(x) return scale(x, 0, 1, -1, 1) end

function gate(v)
  if v > 0.0 then
    return 1.0
  else
    return 0.0
  end
end

-- audio buf_fer utils
function set(v)
  buf_[pos_ * 2 - 1] = v[1] or 0.0
  buf_[pos_ * 2] = v[2] or 0.0
end

function set1(v)
  v = v or 0.0
  buf_[pos_ * 2 - 1] = v
  buf_[pos_ * 2] = v
end

function out(v)
  buf_[pos_ * 2 - 1] = buf_[pos_ * 2 - 1] + (v[1] or 0.0)
  buf_[pos_ * 2] = buf_[pos_ * 2] + (v[2] or 0.0)
end

function out1(v)
  v = v or 0.0
  buf_[pos_ * 2 - 1] = buf_[pos_ * 2 - 1] + v
  buf_[pos_ * 2] = buf_[pos_ * 2] + v
end

function mul1(v, a)
  v = v or 0.0
  return v * a
end

function mul(v, a) return {(v[1] or 0.0) * a, (v[2] or 0.0) * a} end

function mul2(v1, v2)
  return {(v1[1] or 0.0) * (v2[1] or 0.0), (v1[2] or 0.0) * (v2[2] or 0.0)}
end

function add1(v, a)
  v = v or 0.0
  return v + a
end

function add(v, a) return {(v[1] or 0.0) + a, (v[2] or 0.0) + a} end

function add2(v1, v2)
  return {(v1[1] or 0.0) + (v2[1] or 0.0), (v1[2] or 0.0) + (v2[2] or 0.0)}
end

function pan1(v, p)
  v = v or 0.0
  return {v * (1.0 - p), v * p}
end

function pan(v, p) return mul(v, {1.0 - p, p}) end

function info(o) for k, v in pairs(o) do print(k, v) end end

-- requires
arr = require(".lua.arr")
del = require(".lua.del")
osc = require(".lua.osc")
adsr = require(".lua.adsr")
smp = require(".lua.smp")
