using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad

  
model(
  prms::Union{Dict{Int64, M}, Vector{M}},
  graph::Real,
  data,
  train::Symbol = :OK,
) where M = begin
  
end


fw_fn, bw_fn = @easygrad model(prms, graph, data, :INIT)

# opt = ADAM(0.04 / 2, (0.3, 0.7))

train(graph, data) = begin
  prms, opt = init_prms_ops(graph)
  best_prms = similar(prms)
  for i = 1:100
    result, bw_fn = pb_fn(prms, graph, data_t, :INIT)
    grads = bw_fn(1.0)
    result = fn(prms, graph, data_v, :INIT)
    update!(opt, prms, grads)
  end
  result
end

for g in 1:100
  gen_g = mutate!(graph)
  res = train(gen_g, data)
  results += (res, gen_g)
  graph = select_best(results)
end
