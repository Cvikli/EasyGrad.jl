using Revise
using Test
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using FiniteDifferences
using EasyGrad

@easygrad for_pb_func_test(i1, i2) = begin
	list = 5:105
	y = [0f0 for i in list]
	for j in 1:length(list)
		for i in 1:length(list)
		y[i] += sum(i1) + i2
		end
	end
	y2=sum(y)
  y2
end debug="test_cases_functions/generated_test.3.7.for_nested_pb_func.jl"

a, b = 2f0, 3f0

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), for_pb_func_test, a, b) .≈ d_for_pb_func_test(a, b)) 
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
# 1 nested version                              pipa...
# 2 multiple iteration... for (a,b,c) in list   progressing...
# 3 assign...																		progressing...
# 4 combining the 3...                          should be easy after others work... one check necessary...
# 5 list comprehension                          progressing...
# 6 function pullback in for                    progressing...
# 7 enumerate(enumerate(1:20))                  pipa...
# 8 broadcast is SAME like	            				= func pullback...
