using Revise
using Test
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using FiniteDifferences
using EasyGrad
using Zygote
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0

fn39(x) = x, 2 .* x

@easygrad for_pb_func_test(i1) = begin
	list = 1:60
	s, o = Zygote.@ignore (zeros(Float32, length(list), 5), zeros(Float32, length(list), 5)) 
	s_i, o_i = Zygote.@ignore (zeros(Float32, 5), zeros(Float32, 5))
	for i in 1:length(list)
		s_i, o_i = fn39(i1)
		s[i, :] .= s_i
		o[i, :] .= o_i
	end
	y2=sum(s) + sum(o)
  y2
end debug="test_cases_functions/generated_test.3.9.for_arrayfill.jl"

a = randn(Float32, 5)

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), for_pb_func_test, a) .≈ d_for_pb_func_test(a)) 
end

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
#%%
