using Revise
using Test
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using FiniteDifferences
using EasyGrad

@easygrad for_comp_test(i1, i2) = begin
	list = 5:105
	y = [i1 + i2 * i for i in list]
  y2 = sum(y)
  y2
end debug="test_cases_functions/generated_test.3.5.for_comprehension.jl"

a, b = 2f0, 3f0

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), for_comp_test, a, b) .≈ d_for_comp_test(a, b)) 
end

#%%
# println("-----EVALUATION-----")
# 
# a, b = 2f0, 3f0
# for_comp_test(a, b)
# @show d_for_comp_test(a, b)
# @time for_comp_test(a, b)
# @show @time d_for_comp_test(a, b)
# j = grad(central_fdm(5, 1), for_comp_test, a, b)
# @show j
# @time d_for_comp_test(a, b)
# # 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
# @show d_for_comp_test(a, b)
# ;


