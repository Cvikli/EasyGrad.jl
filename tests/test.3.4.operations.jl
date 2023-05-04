using Revise
using Test
using DataStructures
using Boilerplate: @typeof, @sizes
using BenchmarkTools
using Zygote
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
using EasyGrad

@easygrad op_test(x, w) = begin
  y = x * w 
  r = sum(y)
	r
end  debug="test_cases_functions/generated_test.3.4.operations.jl"

X = randn(Float32, 4,3)
W = randn(Float32, 3,2)

# # @sizes tosum
# @info("-----EVALUATION-----")
# @show op_test(X, W)
# @time sum_test(tosum)
# # @btime sum_test(tosum)
# @show d_sum_test2(tosum)
# @btime sum_test2(tosum)
# # @btime sum(tosum)
# 
# @show d_op_test(X, W)
# @time sum_test(tosum)
# @time d_op_test(X, W)
# using FiniteDifferences
# # j = grad(central_fdm(5, 1), d_sum_test, tosum)
# # @show j
# @time d_sum_test(tosum)
# ;
# grad(central_fdm(5, 1), op_test, X, W)

@testset "Gradient check " begin
	# @test all(grad(central_fdm(5, 1), op_test, X, W) .≈ d_sum_test2(tosum)) 
	@test all(gradient(op_test, X, W) .≈ d_op_test(X, W)) 
end