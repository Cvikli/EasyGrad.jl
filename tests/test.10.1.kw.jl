using Revise
using Test
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using CodeTracking
using EasyGrad
using FiniteDifferences

@easygrad fn2(x; seed=2, asdf=2) = begin
	y = x .* x * 20 .* seed
	a = sum(y)
	a
end debug="../tests/test_cases_functions/generated_test.6.3.fn2_variation.jl"
@easygrad func_test3(i1, i2) = begin
	s = zero(i1)
	s2 = fn2(i2, seed=3, asdf=2)
	a = s .+ s2
	# y = y[1]
	y = sum(a)
	y
end debug="../tests/test_cases_functions/generated_test.6.3.func_variation.jl"

a, b = [2f0], [3f0]
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), fn2, a) .≈ d_fn2(a))
	@test all(grad(central_fdm(5, 1), func_test3, a, b) .≈ d_func_test3(a, b))
end


#%%
# a, b = rand(1), rand(1)
# println("-----EVALUATION-----")
# @easygrad fn2([1])
# @easygrad func_test3([1], [2])
# func_test3(a, b)
# @show d_func_test3(a, b)
# @time func_test3(a, b)
# @show d_func_test3(a, b)
# using FiniteDifferences
# j = grad(central_fdm(5, 1), func_test3, a, b)
# @show j
# @time d_func_test3(a, b)
# # 0.000005 seconds (9 allocations: 720 bytes)
# @show d_func_test3(a, b)
# ;

# using BenchmarkTools
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
# using Zygote
# a, b = randn(1), randn(1)
# # @show d_fn2(a)
# # @show Meta.parse(@code_string d_fn2(a))
# # @btime $fn2($a)
# # @btime $d_fn2($a)
# # @btime $gradient($fn2, $a)
# # @btime $func_test3($a, $b)
# @btime func_test3($a, $b)
# @btime d_func_test3($a, $b)
# @btime gradient($func_test3, $a, $b)
# # 91.729 ns (4 allocations: 384 bytes)
# # 177.421 ns (8 allocations: 672 bytes)
# # 200.355 ns (8 allocations: 688 bytes)

# ;
# end
# #%%
# using CodeTracking
# function fn21() 
# 	2
# end
# fn22 = () -> 2
# fn23() = 2

# Meta.show_sexpr(Meta.parse(@code_string fn21()))
# # Meta.show_sexpr(Meta.parse(@code_string fn22()))
# Meta.show_sexpr(Meta.parse(@code_string fn23()))
