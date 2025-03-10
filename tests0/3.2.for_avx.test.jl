using Revise
using RelevanceStacktrace
using DataStructures
using FastClosures
using LoopVectorization
using BoilerplateCvikli: @typeof, @sizes

using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad


for_test(i1, i2) = begin
  y = i1
	list = 1:100
	for i in list
		y .+= i2
	end
  a = y[1]
	a
end

@easygrad for_test(1, 2)
println("-----EVALUATION-----")

a, b = [2f0], [3f0]
for_test(a, b)
@show d_for_test(a, b)
@time for_test(a, b)
@show @time d_for_test(a, b)
using FiniteDifferences
j = grad(central_fdm(5, 1), for_test, a, b)
@show j
@time d_for_test(a, b)
@show d_for_test(a, b)
;
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@btime for_test($a, $b)
@btime d_for_test($a, $b)
# 199.698 ns (0 allocations: 0 bytes)
# 3.142 μs (108 allocations: 8.52 KiB)
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
d_pro_for_test(i1, i2) = begin
	y = i1
	list = 1:100
	for i = list
			y .+= i2
	end
	y
	d_y = Float32[1.0]
	# y .-= i2
	d_i2 = zero(i2)
	for i = (reverse(list))[2:end]
			# y .-= i2
			d_i2 .+= d_y
	end
	d_i1 = d_y
	(d_i1, d_i2)
end
@time d_pro_for_test(a, b)
@time d_pro_for_test(a, b)
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
using LoopVectorization
using CodeTracking

foo() = @avx for i in 1:10
	i += 1
end
Meta.parse(@code_string foo())
