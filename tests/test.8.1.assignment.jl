
using Revise
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad
using FiniteDifferences


@easygrad assignment(x) = begin
	y = x .* 2
	y = y .* y
	y[1]
end debug="../tests/test_cases_functions/generated_test.8.1.assignment.jl"


a = [2f0]
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), assignment, a) .≈ d_assignment(a))
end

#%%
# println("-----EVALUATION-----")

# a = [2f0]
# @show assignment(a)
# @time assignment(a)
# @show d_assignment(a)
# @show @time d_assignment(a)
# @time d_assignment(a)
# # 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
# @show d_assignment(a)
# using FiniteDifferences
# j = grad(central_fdm(5, 1), assignment, a)
# @show j
# ;
# #%%
# @code_warntype pb_assignment(a)
# #%%
# using BenchmarkTools
# using Zygote
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
# @btime assignment($a)
# @btime d_assignment($a)
# @btime gradient(assignment, $a)
# # 45.377 ns (2 allocations: 192 bytes)
# # 172.982 ns (9 allocations: 704 bytes)
# # 218.735 ns (10 allocations: 816 bytes)
# #%%
# pb_assignment2(x) = begin
# 	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:10 =#
# 	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:11 =#
# 	y = x .* 2
# 	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:12 =#
# 	begin
# 			s_y = y
# 			y = y .* y
# 	end
# 	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:13 =#
# 	(y[1], EasyGrad.@refclosure((dd_y->begin
# 									d_y = (zero)(y)
# 									EasyGrad.@add! d_y[1] dd_y
# 									y = s_y
# 									@show y
# 									@show d_y
# 									EasyGrad.@add! d_y y .* d_y + y .* d_y
# 									@show d_y
# 									d_x = (zero)(x)
# 									EasyGrad.@add! d_x 2 .* d_y
# 									(d_x,)
# 							end)))
# end
# @show pb_assignment2([2f0])[2](1.f0)
# # @btime pb_assignment2([2f0])[2](1f0)
# # # @code_warntype pb_assignment2([2f0])
# # #%%
# # add!(a, b) = a += b
# # d_y = y = 2
# # tmp = d_y
# # d_y = add!(d_y, y*tmp)
# # d_y = add!(d_y, y*tmp)
# #%%
# @show grad(central_fdm(5, 1), assignment, a)
# @show d_assignment(a)
# #%%
# pb_assignment(x) = begin
#           #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:10 =#
#           #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:11 =#
#           y = x .* 2
#           #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:12 =#
#           begin
#               s_y = y
#               y = y .* y
#           end
#           #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.8.1.assignment.jl:13 =#
#           (y[1], #= /home/master/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:559 =# EasyGrad.@refclosure((dd_y->begin
# 						d_y = zero(y)
# 						d_y[1] = EasyGrad.rev_bc_add!(d_y[1], dd_y)
# 						y = s_y
# 						d_y = EasyGrad.rev_bc_add!(d_y, y .* d_y - d_y) 
# 						begin
# 								d_x = zero(x)
# 						end
# 						d_x = EasyGrad.rev_bc_add!(d_x, 2 .* d_y)
# 						(d_x,)
# 				end)))
# 	end
# pb_assignment(a)[2](1.f0)