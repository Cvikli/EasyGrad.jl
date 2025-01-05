using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

for_test(i1, i2) = begin
  y = i1
	list = 3:100
	for i in 3:length(list)
		y += i2
	end
  # y = y[1]
  y
end

a, b = 2f0, 3f0
@easygrad for_test(a, b)
println("-----EVALUATION-----")

for_test(a, b)
@time for_test(a, b)
@time pb_for_test(a, b)[2](1f0)
@time pb_for_test(a, b)[2](1f0)
@show d_for_test(a, b)
@time d_for_test(a, b)
# 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
using FiniteDifferences
j = grad(central_fdm(5, 1), for_test, a, b)
@show j
;
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote
@btime for_test($a, $b)
@btime pb_for_test($a, $b)[2](1f0)
@btime gradient(for_test, $a, $b)
# 51.200 ns (0 allocations: 0 bytes)
# 55.382 ns (0 allocations: 0 bytes)
# 23.949 μs (910 allocations: 27.81 KiB)
#%%

pb_for_test_manual(i1, i2) = begin
	y = i1
	list = 3:100
	for i = 3:length(list)
			y += i2
	end
	(y, @refclosure(dd_y -> begin
		d_y = deepcopy(dd_y)
		begin
				d_i2 = zero(i2)
		end
		for i = reverse(3:length(list))
				y -= i2
				d_i2 = EasyGrad.rev_bc_add!(d_i2, d_y)
		end
		d_i1 = deepcopy(d_y)
		(d_i1, d_i2)
	end))
end
@show (a, b)
@time pb_for_test_manual(a, b);
@time pb_for_test_manual(a, b);
#%%
using BenchmarkTools
using Zygote
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@btime for_test($a, $b)
@btime d_for_test($a, $b)
@btime pb_for_test_eval($a, $b)(1f0)
@btime gradient($for_test, $a, $b)
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
ref_test(x) = x[] = 2
a = Ref(1)
ref_test(a)
a
#%%
Meta.show_sexpr(:(a[] = 1))
#%%
d_pro_for_test(i1, i2) = begin
	y = i1
	list = 3:100
	for i = list
			y += i2
	end
	y
	d_y = 1.0f0
	d_i2 = zero(i2)
	for i = (reverse(list))[2:end]
			y -= i2
			d_i2 += d_y
	end
	d_i1 = d_y
	(d_i1, d_i2)
end
@show d_pro_for_test(a, b)
@time d_pro_for_test(a, b)
@btime d_pro_for_test(a, b)
;
#%%
arr = [1:100...]
@btime sum($arr)
ii1 = [0]
ii2 = [1]
@btime for_test($ii1, $ii2)
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

#%%
using CodeTracking
pb_for_test3(i1, i2) = begin
	y = i1
	list = 3:100
	for i = 3:length(list)
			y += i2
	end
	y1=y
	(y1, let y_tmp=y; i2_tmp=i2; (dd_y->begin
									d_y = deepcopy(dd_y)
									begin
											d_i2 = zero(i2)
									end
									for i = (3:length(list))
										y_tmp -= i2_tmp
											# d_i2 = EasyGrad.rev_bc_add!(d_i2, d_y)
									end
									d_i1 = deepcopy(d_y)
									(d_i1, d_i2)
							end)end)
end

Meta.show_sexpr(Meta.parse(@code_string pb_for_test3(a,b)))
@time pb_for_test3(a, b)[2](1f0)
@time pb_for_test3(a, b)[2](1f0)
@time pb_for_test3(a, b)[2](1f0)
#%%
using Revise
includet("../src/RefClosures.jl")

using .RefClosures
closure_test() = begin
	r = 1
	# let r = Ref(r); () -> begin
	@closure () -> begin
			# r[] += 1
			# r[]
			r += 1
			r
		end 
	# end
end
@show closure_test()
gen_func = closure_test() 
@time gen_func()
@time gen_func()
# @time closure_test()()
# @time closure_test()()
# @code_warntype closure_test()
# @code_warntype gen_func()
;

#%%
c = a + b

dc = a * b
#%%
pb_for_test2(i1, i2) = begin
	#= none:1 =#
	#= none:2 =#
	y = i1
	#= none:3 =#
	list = 3:100
	#= none:4 =#
	for i = 3:length(list)
			#= none:5 =#
			y += i2
	end
	#= none:8 =#
	EasyGrad.@refclosure((dd_y->begin
									d_y = deepcopy(dd_y)
									begin
											d_i2 = zero(i2)
									end
									for i = reverse(3:length(list))
											y -= i2
											d_i2 = EasyGrad.∑!(d_i2, d_y)
									end
									d_i1 = deepcopy(d_y)
									(d_i1, d_i2)
							end))
end
# @show pb_for_test2(a, b)
@time pb_for_test2(a, b)(1f0)
@time pb_for_test2(a, b)(1f0)