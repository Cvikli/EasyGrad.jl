module FuncVariations
using Revise
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using CodeTracking
# includet("../src/EasyGrad.jl")
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

@easygrad fn(x) = begin
	y = x .* x * 20
	a = sum(y)
	a
end
@easygrad func_test(i1, i2) = begin
	s = zero(i1)
	s2 = fn(i2)
	a = s .+ s2
	# y = y[1]
	y = sum(a)
	y
end

println("-----EVALUATION-----")

a, b = [2f0], [3f0]
# a, b = rand(1), rand(1)
func_test(a, b)
@show d_func_test(a, b)
@time func_test(a, b)
@show d_func_test(a, b)
using FiniteDifferences
j = grad(central_fdm(5, 1), func_test, a, b)
@show j
@time d_func_test(a, b)
# 0.000005 seconds (9 allocations: 720 bytes)
@show d_func_test(a, b)
;

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote
# @show d_fn(a)
# @show Meta.parse(@code_string d_fn(a))
# @btime $fn($a)
# @btime $d_fn($a)
# @btime $gradient($fn, $a)
# @btime $func_test($a, $b)
@btime func_test($a, $b)
@btime d_func_test($a, $b)
@btime gradient($func_test, $a, $b)
# 91.729 ns (4 allocations: 384 bytes)
# 176.889 ns (8 allocations: 688 bytes) # 177.421 ns (8 allocations: 672 bytes)
# 200.355 ns (8 allocations: 688 bytes)

;
end
#%%
using CodeTracking
function fn1() 
	2
end
fn2 = () -> 2
fn3() = 2

Meta.show_sexpr(Meta.parse(@code_string fn1()))
# Meta.show_sexpr(Meta.parse(@code_string fn2()))
Meta.show_sexpr(Meta.parse(@code_string fn3()))
