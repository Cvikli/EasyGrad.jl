using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad
using Flux

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
using EasyGrad

lnR(a) = σ.(a)

my_ast = :(begin

  end
  )
@easygrad function cell_pro(t, state, x, extras)
  # @show "ok"
  prms, g = extras
  inp1 = x[:,1:1]
  inp2 = x[:,2:2]
  inp3 = x[:,3:3]
  inp4 = x[:,4:4]
  inp5 = x[:,5:5]
  # w = get_prms!(prms, prms_counter, init_fn)

  n201=prms[4]
  n203=prms[5]
  n205=prms[6]

  w1101=prms[7]
  w1105=prms[8]
 
  n1201 = prms[9]
  n1205 = prms[10]

  w1901=prms[11]
  w1905=prms[12]

  w2101=prms[13]
  w2105=prms[14]

  n2201 = prms[15]
  n2205 = prms[16]
  
  n101 = inp1 .* prms[1]
  n103 = inp3 .* prms[2]
  n105 = inp5 .* prms[3]
  
  r1001=state[1]
  r1005=state[2]
  r2001=state[3]
  r2005=state[4]

  # @time begin
  n301 = lnR(n101 .+ n201)
  n303 = lnR(n103 .+ n203)
  n305 = lnR(n105 .+ n205)
# end

  n1001 = inp1
  n1005 = inp5

  n1301 = lnR(n1201 .+ r1001)
  n1305 = lnR(n1205 .+ r1005)

  n1901 = inp1
  n1905 = inp5

  n2001 = n1901
  n2005 = n1905
  
  n2101 = n2001
  n2105 = n2005

  n2511 = inp1
  n2515 = inp5

  n2301 = lnR(n2515 .+ n2101 .+ n2201)
  n2305 = lnR(n2515 .+ n2105 .+ n2205)

  # out1 = n301 .+ n303 .+ n2301 .+ n2305 .+ n1301 .+ n1305
  # out2 = n303 .+ n305 .+ n2301 .+ n1301
  # out3 = n305 .+ n301 .+ n2301 .+ n2305 .+ n1301 .+ n1305

  out1 = n920 = n301 .+ n303 .+ n1301 .+ n1305 .+ n2301 .+ n2305
  out2 = n921 = n305 .+ n301 .+ n1301 .+ n2301
  out3 = n922 = n303 .+ n305 .+ n1301 .+ n1305 .+ n2301 .+ n2305
  # v1 = inp1 + inp2 * inp1 * w
  # out = v1 + state[1]
  # next_state = [v1, state[2]]
  next_state = [n1001, n1005, n2001, n2005]
  out = [out1, out2, out3]
  # out, next_state
  output = sum(out1)
  output
end

using Zygote
cell_all(T, state, feature, extra) = begin
  # for t in 1:T
  for t in 1:T
    # _, state = cell_pro(t, state, feature[t,:,:], extra)
    grad = gradient(p -> cell_pro(t, state, feature[t,:,:], p), extra)
    # @show grad = pb_cell_pro_man(t, state, feature[t,:,:], extra)[2]
    # grad = d_cell_pro(t, state, feature[t,:,:], extra)
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

  extra = prms, nothing
  @btime cell_all($T, $state, $feature, $extra)
  # cell_all(T, state, feature, extra)
  # @code_warntype cell_all(T, state, feature, extra)
end
test()

