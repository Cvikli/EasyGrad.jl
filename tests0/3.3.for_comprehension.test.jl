using Revise
using RelevanceStacktrace
using DataStructures
using FastClosures
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

ENV["JULIA_DEBUG"] = EasyGrad

@easygrad for_comp_test(i1, i2) = begin
	list = 5:105
	y = [i1 + i2 * i for i in list]
  y2 = sum(y)
  y2
end

println("-----EVALUATION-----")

a, b = 2f0, 3f0
for_comp_test(a, b)
@show d_for_comp_test(a, b)
@time for_comp_test(a, b)
@show @time d_for_comp_test(a, b)
using FiniteDifferences
j = grad(central_fdm(5, 1), for_comp_test, a, b)
@show j
@time d_for_comp_test(a, b)
# 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
@show d_for_comp_test(a, b)
;
#%%
using BenchmarkTools
using Zygote
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@btime for_comp_test($a, $b)
@btime d_for_comp_test($a, $b)
@btime gradient($for_comp_test, $a, $b)
# 111.361 ns (1 allocation: 496 bytes)
# 431.286 ns (11 allocations: 2.59 KiB) # 272.720 ns (8 allocations: 656 bytes)
# 5.852 μs (44 allocations: 28.48 KiB)
#%%
ENV["JULIA_DEBUG"] = Main
ENV["JULIA_DEBUG"] = nothing
using Logging
 @debug "hmm"
 @info "working?"
 @debug "hmm2"
 @info "workisng?"

#%%
pb_for_comp_test2(i1, i2) = begin
#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.3.for_comprehension.test.jl:10 =#
#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.3.for_comprehension.test.jl:11 =#
list = 5:105
#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.3.for_comprehension.test.jl:12 =#
y = [i1 + i2 * i for i = list]
#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.3.for_comprehension.test.jl:13 =#
y2 = begin
				(var"##tmp#605", var"##pb#606") = EasyGrad.Zygote.pullback(sum, y)
				var"##tmp#605"
		end
#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.3.for_comprehension.test.jl:14 =#
(y2, #= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:450 =# EasyGrad.@refclosure((dd_y->begin
								d_y2 = deepcopy(dd_y)
								var"##pb_tmp#607" = var"##pb#606"(d_y2)
								d_y = var"##pb_tmp#607"[1]
								begin
										d_i1 = zero(i1)
										d_i2 = zero(i2)
								end
								for _i_i = 1:length(list)
										i = list[_i_i]
										@show d_y
										@show _i_i
										var"##dy#608" = d_y[_i_i]
										d_y[_i_i] = zero(d_y[_i_i])
										d_i1 = EasyGrad.rev_bc_add!(d_i1, var"##dy#608")
										var"##dy#609" = var"##dy#608"
										var"##dy#608" = zero(var"##dy#608")
										d_i2 = EasyGrad.rev_bc_add!(d_i2, i * var"##dy#609")
								end
								(d_i1, d_i2)
						end)))
end
pb_for_comp_test2(a, b)[2](1f0)

#%%
pb_for_comp_test_man2(i1, i2) = begin
	list = 5:105
	y = [i1 + i2 * i for i = list]
	y2 = begin
					(var"##tmp#2126", var"##pb#2127") = EasyGrad.Zygote.pullback(sum, y)
					var"##tmp#2126"
			end
	(y2, EasyGrad.@refclosure((dd_y->begin
			d_y2 = (EasyGrad.Zero)(y2)
			d_y2 = (EasyGrad).rev_bc_add!(d_y2, dd_y)
			begin
					var"##pb_tmp#2128" = var"##pb#2127"(d_y2)
					d_y = (EasyGrad.Zero)(y)
					# @show d_y
					# @show y
					d_y = (EasyGrad).rev_bc_add!(d_y, var"##pb_tmp#2128"[1])
					# @show var"##pb_tmp#2128"[1]
					# d_y = var"##pb_tmp#2128"[1]
			end
			begin
					d_i1 = (EasyGrad.Zero)(i1)
					d_i2 = (EasyGrad.Zero)(i2)
			end
			for _i_i = 1:length(list)
					i = list[_i_i]
					d_i1 = (EasyGrad).rev_bc_add!(d_i1, d_y[_i_i])
					d_i2 = (EasyGrad).rev_bc_add!(d_i2, i * d_y[_i_i])
			end
			(d_i1, d_i2)
	end)))
end

pb_for_comp_test_man2(a,b)[2](1f0)
@btime pb_for_comp_test_man2(a,b)[2](1f0)