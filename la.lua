-- default la functions
function run() end

function la_run()
  for pos = 1, la_bufsz do
    la_pos = pos
    set({0, 0})
    run()
    la_time = la_time + 1
  end
end

la_buf = {}
la_pos = 1
la_rate = 44100
la_inv_rate = 1 / la_rate
la_bufsz = 512
la_time = 0

-- math utils
pi = math.pi
tau = math.pi * 2.0
inv_pi = 1 / pi
inv_tau = 1 / tau
rand = math.random
sin = math.sin
floor = math.floor
abs = math.abs
pow = math.pow

function dup(n, v)
  local o = {}
  for i = 1, n do o[i] = v end
  return o
end

function fill(n, f)
  local o = {}
  for i = 1, n do o[i] = f(i) end
  return o
end

function apply(a, b, f)
  local o = {}

  if type(b) == "table" then
    for i in pairs(a) do o[i] = f(a[i], b[i]) end
  else
    for i in pairs(a) do o[i] = f(a[i], b) end
  end

  return o
end

function scale_(x, inlo, inhi, outlo, outhi)
  if inhi == inlo then
    return outlo
  else
    return (x - inlo) * (outhi - outlo) / (inhi - inlo) + outlo;
  end
end
function scale(x, inlo, inhi, outlo, outhi)
  if type(x) == table then
    local o = {}
    for i in pairs(x) do o[i] = scale_(x[i], inlo, inhi, outlo, outhi) end
    return o
  else
    return scale_(x, inlo, inhi, outlo, outhi)
  end
end

function scale_bi(x, outlo, outhi) return scale(x, -1, 1, outlo, outhi) end
function norm(x) return scale(x, -1, 1, 0, 1) end
function bi(x) return scale(x, 0, 1, -1, 1) end

function rrand(lo, hi) return rand() * (hi - lo) + lo end

function shuffle(a)
  local list = {}
  for i in pairs(a) do list[i] = a[i] end

  for i = #list, 2, -1 do
    local j = rand(i)
    list[i], list[j] = list[j], list[i]
  end

  a = list
  return a
end

function choose(a) return a[rand(1, #a)] end

function gate_(v)
  if v > 0.0 then
    return 1.0
  else
    return 0.0
  end
end
function gate(v) return apply(v, nil, gate_) end

function mul_(a, b) return a * b end
function mul(a, b) return apply(a, b, mul_) end

function add_(a, b) return a + b end
function add(a, b) return apply(a, b, add_) end

function pan(v, p) return {v * (1 - p), v * p} end

-- audio buffer utils
function set(v)
  local i = (la_pos - 1) * 2
  la_buf[i + 1] = v[1] or 0.0
  la_buf[i + 2] = v[2] or 0.0
end

function out(v)
  local i = (la_pos - 1) * 2
  la_buf[i + 1] = la_buf[i + 1] + (v[1] or 0.0)
  la_buf[i + 2] = la_buf[i + 2] + (v[2] or 0.0)
end

function get()
  local i = (la_pos - 1) * 2
  return {la_buf[i + 1], la_buf[i + 2]}
end

-- misc
function info(o) for k, v in pairs(o) do print(k, v) end end

-- requires
buffer = require(".lua.buffer")
oscil = require(".lua.oscil")
adsr = require(".lua.adsr")
sampler = require(".lua.sampler")
delay = require(".lua.delay")
sequence = require(".lua.sequence")
