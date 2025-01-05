using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using BenchmarkTools
using LoopVectorization
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

sum_test2(i1) = (y=0.f0; for v in i1 y+= v end; y)
@easygrad sum_test(i1) = begin
  y = 0f0
	list = 1:100
	# for i in list
	@avx for i in list
		y += i1[i]
	end
  y
end

tosum = randn(Float32, 100)
# @show tosum
@sizes tosum
println("-----EVALUATION-----")
sum_test(tosum)
@time sum_test(tosum)
# @btime sum_test(tosum)
# @btime sum_test2(tosum)
# @btime sum(tosum)

@show d_sum_test(tosum)
@time sum_test(tosum)
@show @time d_sum_test(tosum)
using FiniteDifferences
# j = grad(central_fdm(5, 1), d_sum_test, tosum)
# @show j
@time d_sum_test(tosum)
@show d_sum_test(tosum)
;
#%%
func(s) = begin
	l = (reverse(1:100))[1:end-1]
	for i in l
		s += i
	end
	s
end
		
@time func(0)
@time func(0)
#%%
using FiniteDifferences
start_c = count
j = grad(central_fdm(5, 1), fn5, randn(3,2), randn(3,2))
@show count - start_c
@sizes j
#%%
@edit central_fdm(3,1)
#%%
using FiniteDiff
start_c = count
fn_m(t) = fn5(t...)
j = FiniteDiff.finite_difference_jacobian(fn_m, [randn(3,2), randn(3,2)], relstep=1f-4)
@show count - start_cVal(:forward)
j
#%%
pb_sum_test2(i1) = begin
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.2.sum_avx.test.jl:13 =#
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.2.sum_avx.test.jl:14 =#
	y = 0.0f0
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.2.sum_avx.test.jl:15 =#
	list = 1:100
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.2.sum_avx.test.jl:17 =#
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.2.sum_avx.test.jl:17 =# @avx for i = list
					#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.2.sum_avx.test.jl:18 =#
					y += i1[i]
			end
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/3.2.sum_avx.test.jl:20 =#
	(y, (dd_y->begin
									d_y = deepcopy(dd_y)
									begin
											d_i1 = zero(i1)
									end
									tmp = collect(reverse(list))
									@avx for i = tmp 
										y -= i1[i]
										d_i1[i] = EasyGrad.rev_bc_add!(d_i1[i], d_y)
									end
									(d_i1,)
							end))
end
@time pb_sum_test2(tosum)[2](1f0)
# @btime d_pro_for_test(a, b)
;
#%%
arr = [1:100...]
@btime sum($arr)
ii1 = [0]
ii2 = [1]
@btime for_test($ii1, $ii2)
#%%
using Zygote

@btime sum($tosum)
@btime sum_test($tosum)
@btime gradient($sum, $tosum)
@btime d_sum_test($tosum)

#%%
using Zygote


a, b = [2f0], [3f0]
a, b = randn(20), randn(20)
for_test_z(i1, i2) = begin
  y = i1
	list = 1:100
	for i in list
		y = i2 .+ y
	end
  sum(y)
end
@btime gradient(for_test_z, $a, $b)
