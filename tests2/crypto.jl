using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad


using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
using EasyGrad



lnR(a) = a
function cell_pro(t, state, x, extras)
  # @show "ok"
  prms = extras
  inp1 = x[:,1:1]
  inp2 = x[:,2:2]
  inp3 = x[:,3:3]
  inp4 = x[:,4:4]
  inp5 = x[:,5:5]
  # w = get_prms!(prms, prms_counter, init_fn)
  p1=prms[1]
  p2=prms[2]
  p3=prms[3]

  p4=prms[4]
  p5=prms[5]

  p6=prms[6]
  p7=prms[7]

  w1=prms[7+1]
  w2=prms[7+2]
  w3=prms[7+3]
  w4=prms[7+4]
  w5=prms[7+5]
  w6=prms[7+6]
  w7=prms[7+7]
  w8=prms[7+8]
  w9=prms[7+9]
  w10=prms[7+10]
  w11=prms[7+11]

  nr1 = inp1
  nr2 = inp5
  nr3 = inp1 .* w4
  nr4 = inp5 .* w5
  r1=state[1]
  r2=state[2]
  r3=state[3]
  r4=state[4]

  # @time begin
  n301 = lnR(inp1 .* w1 .+ p1)
  n303 = lnR(inp3 .* w2 .+ p2)
  n305 = lnR(inp5 .* w3 .+ p3)
# end

  n1301 = lnR(p4 .+ r1)
  n1305 = lnR(p5 .+ r1)

  n2301 = lnR(inp1 .* w8 .+ w6 .* r3 .+ p6)
  n2305 = lnR(inp5 .* w9 .+ w7 .* r4 .+ p7)

  out1 = n301 .+ n303 .+ n2301 .+ n2305 .+ n1301 .+ n1305
  out2 = n303 .+ n305 .+ n2301 .+ n1301
  out3 = n305 .+ n301 .+ n2301 .+ n2305 .+ n1301 .+ n1305

  # v1 = inp1 + inp2 * inp1 * w
  # out = v1 + state[1]
  # next_state = [v1, state[2]]
  next_state = [nr1, nr2, nr3, nr4]
  out = sum(out1.+out2.+ out3)
  out, next_state
end

cell_all(T, state, feature, extra) = begin
  for t in 1:T
    _, state = cell_pro(t, state, feature[t,:,:], extra)
  end
end
test() = begin
  T = 60
  B = 90
  P = 18
  S = 4
  state = [randn(Float32, 1, 1) for s in 1:S]
  feature = randn(Float32, T, B, 5)
  prms=[randn(Float32,1,1) for p in 1:P]

  extra = prms
  @btime cell_all($T, $state, $feature, $extra)
  # cell_all(T, state, feature, extra)
  # @code_warntype cell_all(T, state, feature, extra)
end
test()

