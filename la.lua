-- la
function run() end -- modify this!

function la_run()
  for pos = 1, la_bufsz do
    la_pos = pos
    set({0, 0})
    run()
  end
end

la_buf = {}
la_pos = 1
la_rate = 44100
la_inv_rate = 1 / la_rate
la_bufsz = 512
la_midi = {}

-- math utils
pi = math.pi
tau = math.pi * 2.0
inv_pi = 1 / pi
inv_tau = 1 / tau
rand = math.random
sin = math.sin
min = math.min
max = math.max
floor = math.floor
abs = math.abs
pow = math.pow
log = math.log

function clamp(v, lo, hi)
  if v < lo then
    return lo
  elseif v > hi then
    return hi
  else
    return v
  end
end

function midi2freq_(midi) return floor((440 / 32) * (2 ^ ((midi - 9) / 12))) end
for i = 0, 127 do la_midi[i] = midi2freq_(i) end
function midi2freq(midi) return la_midi[clamp(midi, 0, 127)] end

function freq2midi(freq) return 69 + log(freq / 440, 2) * 12 end

function is_nil(a) return a == nil end

function dup(n, v, arr)
  if is_nil(arr) then
    local o = {}
    for i = 1, n do o[i] = v end
    return o
  else
    for i = 1, n do arr[i] = v end
    return arr
  end
end

function fill(n, f)
  local o = {}
  for i = 1, n do o[i] = f(i) end
  return o
end

function apply(a, b, f)
  local o = {}

  if type(b) == 'table' then
    for i = 1, #a do o[i] = f(a[i], b[i]) end
  else
    for i = 1, #a do o[i] = f(a[i], b) end
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
  if type(x) == 'table' then
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

function chance(p) return rand() < p end

function range(lo, hi, step)
  local o = {}

  lo = min(lo, hi)
  hi = max(lo, hi)
  if is_nil(step) or step == 0 then step = 1 end

  v = lo
  i = 1
  while v <= hi do
    o[i] = v
    v = v + step
    i = i + 1
  end

  return o
end

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

function pan(v, p) return mul({1 - p, p}, v) end

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
recorder = require(".lua.recorder")
delay = require(".lua.delay")
sequence = require(".lua.sequence")
