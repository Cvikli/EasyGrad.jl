using Revise
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
# includet("EasyGrad.jl")
using EasyGrad: @easygrad, @code_expr_easy, process_body

fn6(i1, i2) = begin
  y = i1 .* i2    
  y .+= i1 .* i2
  y .+= y
  y
end
fn6(i1, i2) = begin
  y = i1 .* i2    
  y .+= i1 .* i2
  y .+= y
  y
end
# fn6(i1, i2) = begin
#   y1 = i1 .* i2
#   y2 = y1 .* i1
#   y = y2 .+ y2
#   y
# end
# using CodeTracking
# @code_expr fn6(1, 2)
# macro code_expr_easy2(myex)
# 	@show myex
# 	println("my $myex")
# 	esc(quote
#     res = @code_expr($myex)
# 		res !== nothing ? res : Meta.parse(@code_string $myex)
#   end)
# end

d_fn = @easygrad fn6(1, 2)
funcbody = d_fn
println("STARTING")
Meta.show_sexpr(funcbody)
# @show new_code
@show eval(funcbody)

a, b = [2f0], [3f0]
fn6(a, b)
@show d_fn6(a, b)
@time fn6(a, b)
@show @time d_fn6(a, b)
using FiniteDifferences
j = grad(central_fdm(5, 1), fn6, a, b)
@show j
@time d_fn6(a, b)
@show d_fn6(a, b)
;
#%%
using FiniteDifferences
start_c = count
j = grad(central_fdm(5, 1), fn5, randn(3,2), randn(3,2))
@show count - start_c
@sizes j
#%%
@edit central_fdm(3,1)
#%%
using FiniteDiff
start_c = count
fn_m(t) = fn5(t...)
j = FiniteDiff.finite_difference_jacobian(fn_m, [randn(3,2), randn(3,2)], relstep=1f-4)
@show count - start_cVal(:forward)
j
#%%
using .NumericalDiff
#%%
using DataStructures
sym_dict = DefaultDict{Symbol, Number}(0)
#%%
sym_dict[:a] += 1
@show haskey(sym_dict, :b)
@typeof sym_dict[:a]
#%%