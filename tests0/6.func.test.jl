module FuncTest
using Revise
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad
using FastClosures


func_test(i1, i2) = begin
	s = zero(i1)
	a = s .+ i1 .+ i2
	y = sum(a)
	y
end

println("-----EVALUATION-----")

a, b = [2f0], [3f0]
# a, b = rand(1), rand(1)
@easygrad func_test(a, b)
@time func_test(a, b)
@show d_func_test(a, b)
using FiniteDifferences
j = grad(central_fdm(5, 1), func_test, a, b)
@show j
@show d_func_test(a, b)
@time d_func_test(a, b)
# 0.000005 seconds (9 allocations: 720 bytes)

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote
@btime $func_test($a, $b)
@btime $d_func_test($a, $b)
@btime $gradient($func_test, $a, $b)
# 46.668 ns (2 allocations: 192 bytes)
# 73.535 ns (7 allocations: 272 bytes) 139.056 ns (5 allocations: 464 bytes)
# 104.019 ns (5 allocations: 352 bytes)

end


#%%
# using BenchmarkTools
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
# using Zygote
# import .FuncTest: func_test

# a, b = rand(1)[1], rand(1)[1]
# @time func_test(a, b)
# # @btime $FuncTest.d_func_test($a, $b)
# # @btime $gradient($FuncTest.func_test, $a, $b)
# # #%%
# # using Zygote
# # Zygote.pullback(fn, b)[2](1)

# # #%%
# # using .EasyGrad: easygrad, infer_function
# # @show infer_function(:fn)
# # @show easygrad(infer_function(:fn), :i2)(:d_y)
#%%
fn(x) = begin
	y = x .* x * 20
	y
end
using EasyGrad
d_func_test_manual(i1, i2) = begin
		s = zero(i1)
		a = s .+ s
		y = sum(a)
		y
		d_y = 1.0f0
		d_a = EasyGrad.Zygote.pullback(sum, a)[2](d_y)[1]
		d_s = deepcopy(d_a)
		d_s = EasyGrad.rev_bc_add!(d_s, d_a)
		d_i1 = zero(d_s)
		d_i2 = deepcopy(d_a)
		(d_i1, d_i2)
end
a, b = [2f0], [3f0]
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
@btime d_func_test_manual($a, $b)
#%%
funcbody_manual2(i1, i2) = begin
	#= none:1 =#
	#= none:2 =#
	s = zero(i1)
	#= none:3 =#
	a = (s .+ i1) .+ i2
	#= none:4 =#
	y = begin
					(var"##tmp#1456", var"##pb#1457") = EasyGrad.Zygote.pullback(sum, a)
					var"##tmp#1456"
			end
	#= none:5 =#
	(y, #= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:552 =# EasyGrad.@refclosure((dd_y->begin
									d_y = zero(y)
									@typeof y
									d_y = (EasyGrad).rev_bc_add!(d_y, dd_y)
									@typeof d_y
									d_a = zero(a)
									@time begin
										var"##pb_tmp#1458" = var"##pb#1457"(d_y)
										@typeof var"##pb_tmp#1458"
											#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:339 =#
											d_a = (EasyGrad).rev_bc_add!(d_a, var"##pb_tmp#1458"[1])
									end
									@time begin
											d_s = zero(s)
											d_i1 = zero(i1)
											d_i2 = zero(i2)
									end
									@time (d_s, d_i1, d_i2) = ((EasyGrad).rev_bc_add!(d_s, d_a), (EasyGrad).rev_bc_add!(d_i1, d_a), (EasyGrad).rev_bc_add!(d_i2, d_a))
									d_i1 = (EasyGrad).rev_bc_add!(d_i1, zero(d_s))
									(d_i1, d_i2)
							end)))
end

a, b = [2f0], [3f0]
funcbody_manual2(a, b)[2](1f0)
@code_warntype funcbody_manual2(a, b)[2](1f0)
funcbody_manual2(a, b)[2](1f0)
funcbody_manual2(a, b)[2](1f0)
