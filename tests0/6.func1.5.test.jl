using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using CodeTracking
# includet("../src/EasyGrad.jl")
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

@easygrad fn(x) = begin
	a = x .* x .* 20
	y = sum(a)
	# y = a[1]
	y
end

println("-----EVALUATION-----")
a, b = [2f0], [3f0]
# a, b = rand(1), rand(1)
fn(a, b)
@show d_fn(a, b)
@time fn(a, b)
@show d_fn(a, b)
using FiniteDifferences
j = grad(central_fdm(5, 1), fn, a, b)
@show j
@time d_fn(a, b)
# 0.000005 seconds (9 allocations: 720 bytes)
@show d_fn(a, b)
;

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote
# @show d_fn(a)
# @show Meta.parse(@code_string d_fn(a))
# @btime $fn($a)
# @btime $d_fn($a)
# @btime $gradient($fn, $a)
@btime $func_test($a, $b)
@btime $d_func_test($a, $b)
@btime $gradient($func_test, $a, $b)
# 92.460 ns (4 allocations: 384 bytes)
# 177.269 ns (8 allocations: 672 bytes)
# 202.157 ns (8 allocations: 688 bytes)

;

#%%
using BoilerplateCvikli: @typeof
tmp = gensym("tmp")
@typeof tmp
@show tmp
Meta.show_sexpr(tmp)
@show :($tmp = 12)
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote

a, b = rand(1)[1], rand(1)[1]
@btime $FuncTest.func_test($a, $b)
@btime $FuncTest.d_func_test($a, $b)
# @btime $gradient($func_test_z, $a, $b)
# #%%
# using Zygote
# Zygote.pullback(fn, b)[2](1)

# #%%
# using .EasyGrad: easygrad, infer_function
# @show infer_function(:fn)
# @show easygrad(infer_function(:fn), :i2)(:d_y)
