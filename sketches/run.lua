th = 0.0
fr = 440.0 * 2
th2 = 0.0
fr2 = 0.3 * 1
del = {{},{}}
for i=1,RATE do
  del[1][i] = 0
  del[2][i] = 0
end

delr = math.floor(RATE/4)

delw = 0
v = 0
t = 0
p = 0

rel = 0.9999

flo = 220
fhi = 880

tr = 1

wav = saw

tr = 2

function RUN()
  for i=1,BUFSIZE do
    local o = wav(th) * v
    local l = o * (1-p)
    local r = o * p
    del[1][delw+1] = l
    del[2][delw+1] = r
    l = l + del[2][delr+1] * 0.9
    r = r + del[1][delr+1] * 0.9
    p = scale_bi(sin(th2),0,1)
    set_bi(i,l,r)
    fr = scale_bi(sin(th2),flo,fhi)
    th = th + fr / RATE
    if th > 1.0 then
      th = th - 1.0
    end
    th2 = th2 + fr2 / RATE
    if th2 > 1.0 then
      th2 = th2 - 1.0
    end
    if v > 0.0 then
      v = v * rel
    end
    t = t + tr / RATE
    if t > 1.0 then
      v = 1.0
      rel = scale(math.random(),0,1,0.999,0.9999)
      fr2 = scale(math.random(),0,1,0.01,8)
      flo = scale(math.random(),0,1,1,1) * 220
      fhi = scale(math.random(),0,1,1,8) * 220
      if math.random() < 0.5 then
	wav = saw
      else
	wav = pul
      end
      t = t - 1.0
    end
    delw = (delw + 1) % RATE
    delr = (delr + 1) % RATE
  end
end
