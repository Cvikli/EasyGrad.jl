using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad
using FiniteDifferences
using Test

fn53(x) = x

@easygrad if_test(i1, i2) = begin
	s = i1
	if any(i1 .> 1.)
		for i in 1:10
			s += fn53(i2) .+ i1
		end
	elseif any(i1 .> 1.)
		s += i2
	else
		s += i2 .+ i1
	end
	y = s[1]
	y
end debug="../tests/test_cases_functions/generated_test.5.3.if_for.jl"

a, b = [2.2f0], [3.3f0]

@testset "Gradient check " begin
@test all(grad(central_fdm(5, 1), if_test, [1.5f0], b) .≈ d_if_test([1.5f0], b)) 
@test all(grad(central_fdm(5, 1), if_test, [0.5f0], b) .≈ d_if_test([0.5f0], b)) 
end

#%%
# @show grad(central_fdm(5, 1), if_test, a, b)

# println("-----EVALUATION-----")

# a, b = rand(1), rand(1)
# @show a, b
# if_test(a, b)
# @show d_if_test(a, b)
# @time if_test(a, b)
# @show @time d_if_test(a, b)
# j = grad(central_fdm(10, 1), if_test, a, b)
# @show j
# @time d_if_test(a, b)
# # 0.000006 seconds (13 allocations: 1008 bytes)
# @show d_if_test(a, b)
# ;
# #%%
# using BenchmarkTools
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
# using Zygote

# a, b = rand(1), rand(1)
# @btime if_test($a, $b)
# @btime d_if_test($a, $b)
# @btime gradient($if_test, $a, $b)
# # 82.127 ns (4 allocations: 320 bytes)
# # 334.283 ns (17 allocations: 1.19 KiB)
# # 5.646 μs (49 allocations: 2.22 KiB)
# #%%
# @show LineNumberNode(1, "none").line
# @show LineNumberNode(1, "none").line

#%%
# pb_if_test(i1, i2) = begin
# 	#= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.5.1.if.jl:10 =#
# 	#= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.5.1.if.jl:11 =#
# 	s = i1
# 	#= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.5.1.if.jl:12 =#
# 	if any(i1 .> 1.0)
# 			#= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.5.1.if.jl:13 =#
# 			s += i1 .* i2
# 	else
# 			#= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.5.1.if.jl:15 =#
# 			s += i2 .+ i1
# 	end
# 	#= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.5.1.if.jl:18 =#
# 	y = s[1]
# 	#= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.5.1.if.jl:19 =#
# 	(y, #= /home/master/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:565 =# EasyGrad.@refclosure((dd_y->begin
# 									d_y = deepcopy(dd_y)
# 									begin
# 											d_s = zero(s)
# 									end
# 									d_s[1] = EasyGrad.rev_bc_add!(d_s[1], d_y)
# 									@show d_s
# 									begin
# 											d_i1 = zero(i1)
# 											d_i2 = zero(i2)
# 											d_i2 = zero(i2)
# 											d_i1 = zero(i1)
# 									end
# 									if any(i1 .> 1.0)
# 										s -= i1 .* i2
# 										@show s
# 										@show i1
# 										@show i2
# 											d_i1 = EasyGrad.rev_bc_add!(d_i1, i2 .* d_s)
# 											d_i2 = EasyGrad.rev_bc_add!(d_i2, i1 .* d_s)
# 											@show d_i1
# 											@show d_i2
# 									else
# 										d_s -= i2 .+ i1
# 											d_i2 = EasyGrad.rev_bc_add!(d_i2, d_s)
# 											d_i1 = EasyGrad.rev_bc_add!(d_i1, d_s)
# 									end
# 									begin
# 											# d_i1 = zero(i1)
# 									end
# 									d_i1 = EasyGrad.rev_bc_add!(d_i1, d_s)
# 									(d_i1, d_i2)
# 							end)))
# end

# pb_if_test(a,b)[2](1.f0)
