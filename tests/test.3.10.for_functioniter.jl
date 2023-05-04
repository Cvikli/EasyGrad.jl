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

fn310(x, i) = x, 2 .* x .+ i

@easygrad for_pb_func_test(i1) = begin
	list = 1:30
	s, o = Zygote.@ignore (zeros(Float32, length(list), 5), zeros(Float32, length(list), 5)) 
	s_i, o_i = Zygote.@ignore (zeros(Float32, 5), zeros(Float32, 5))
	for i in list
		s_i, o_i = fn310(i1[i], i)
		s[i, :] .= s_i
		o[i, :] .= o_i
	end
	y2=sum(s) + sum(o)
  y2
end debug="test_cases_functions/generated_test.3.10_for_funciter.jl"

a = [randn(Float32, 5) for _ in 1:30]

@testset "Gradient check " begin
	@test all(grad(central_fdm(7, 1), for_pb_func_test, a) .≈ d_for_pb_func_test(a)) 
end
;
#%%
# @code_warntype pb_for_pb_func_test(a)[2](1f0)
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
#%%
