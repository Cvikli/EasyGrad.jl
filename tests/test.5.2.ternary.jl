using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad


@easygrad ternary_test(i1, i2) = begin
	a = i1
	# a = any(i1 .> 1.) ? i1 .* i2 : i2 .+ i1 # TODO this doesn't work
	a += any(i1 .> 1.) ? i1 .* i2 : i2 .+ i1
	y = a[1]
	# y = y[1]
	y
end debug="../tests/test_cases_functions/generated_test.5.2.ternary.jl"

a, b = [2f0], [3f0]
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), ternary_test, a, b) .≈ d_ternary_test(a, b)) 
end


#%%
# println("-----EVALUATION-----")

# a, b = rand(1), rand(1)
# @show a, b
# ternary_test(a, b)
# @show d_ternary_test(a, b)
# @time ternary_test(a, b)
# @show @time d_ternary_test(a, b)
# using FiniteDifferences
# j = grad(central_fdm(10, 1), ternary_test, a, b)
# @show j
# @time d_ternary_test(a, b)
# # 0.000006 seconds (13 allocations: 1008 bytes)
# @show d_ternary_test(a, b)
# ;
# #%%
# using BenchmarkTools
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
# using Zygote

# a, b = rand(1), rand(1)
# @btime $ternary_test($a, $b)
# @btime $d_ternary_test($a, $b)
# @btime $gradient($ternary_test, $a, $b)
# # 55.937 ns (3 allocations: 224 bytes)
# # 228.131 ns (13 allocations: 848 bytes)
# # 4.644 μs (38 allocations: 1.64 KiB)
# ;
# #%%
# pb_if_test(i1, i2) = begin
# 	#= none:1 =#
# 	#= none:2 =#
# 	s = i1
# 	#= none:3 =#
# 	if any(i1 .> 1.0)
# 			#= none:4 =#
# 			s .+= i1 .* i2
# 	else
# 			#= none:6 =#
# 			s .+= i2 .+ i1
# 	end
# 	#= none:8 =#
# 	y = s[1]
# 	#= none:10 =#
# 	(y, (dd_y->begin
# 							d_y = deepcopy(dd_y)
# 							d_s = zero(s)
# 							d_s[1] = EasyGrad.rev_bc_add!(d_s[1], d_y)
# 							begin
# 									d_i1 = zero(i1)
# 									d_i2 = zero(i2)
# 							end
# 							if any(i1 .> 1.0)
# 									s .-= i1 .* i2
# 									d_i1 = EasyGrad.rev_bc_add!(d_i1, i2 .* d_s)
# 									d_i2 = EasyGrad.rev_bc_add!(d_i2, i1 .* d_s)
# 							else
# 									s .-= i2 .+ i1
# 									d_i2 = EasyGrad.rev_bc_add!(d_i2, d_s)
# 									d_i1 = EasyGrad.rev_bc_add!(d_i1, d_s)
# 							end
# 							d_i1 = EasyGrad.rev_bc_add!(d_i1, d_s)
# 							(d_i1, d_i2)
# 					end))
# end

# #%%
# @show LineNumberNode(1, "none").line
# @show LineNumberNode(1, "none").line

