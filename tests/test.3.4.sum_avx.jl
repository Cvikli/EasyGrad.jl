using Revise
using Test
using DataStructures
using Boilerplate: @typeof, @sizes
using BenchmarkTools
using LoopVectorization
using FiniteDifferences
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
using EasyGrad

@easygrad sum_test2(i1) = (y=0.f0; for v in i1 	y+= v end;y)
@easygrad sum_test(i1) = begin
  y = 0f0
	list = 1:100
	# for i in list
	@avx for i in list
		y += i1[i]
	end
  y
end  debug="test_cases_functions/generated_test.3.4.sum_avx.jl"

tosum = randn(Float32, 100)
# # @show tosum
# # @sizes tosum
# @info("-----EVALUATION-----")
# sum_test(tosum)
# @time sum_test(tosum)
# # @btime sum_test(tosum)
# @show d_sum_test2(tosum)
# @btime sum_test2(tosum)
# # @btime sum(tosum)
# 
# @show d_sum_test(tosum)
# @time sum_test(tosum)
# @show @time d_sum_test(tosum)
# using FiniteDifferences
# # j = grad(central_fdm(5, 1), d_sum_test, tosum)
# # @show j
# @time d_sum_test(tosum)
# ;

@testset "Gradient check " begin
	# @test all(grad(central_fdm(5, 1), sum_test2, tosum) .≈ d_sum_test2(tosum)) 
	@test all(grad(central_fdm(5, 1), sum_test, tosum) .≈ d_sum_test(tosum)) 
end