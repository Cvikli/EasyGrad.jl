using Revise
using RelevanceStacktrace
using DataStructures
using LoopVectorization
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

for_test(i1, i2) = begin
  y = i1
	list = 1:16
	for i in list
		y += i2[i]
	end
  y
end

a, b = 2f0, Float32.([1:16...])
@easygrad for_test(a, b)
println("-----EVALUATION-----")

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
using Zygote
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
@btime for_test($a, $b)
@btime d_for_test($a, $b)
@btime gradient($for_test, $a, $b)
# 4.309 ns (0 allocations: 0 bytes)
# 73.550 ns (5 allocations: 224 bytes) # 70.414 ns (4 allocations: 208 bytes)
# 10.018 μs (275 allocations: 11.03 KiB)
;
#%%
# Expr(:call, :(:), 2, end

#%%
d_for_test_raw(i1, i2) = begin
	y = i1
	list = 1:16
	for i = list
			y += i2[i]
	end
	y
	d_y = 1.0f0
	i = list[end]
	d_i2 = zero(i2)
	for i = reverse(list)
			y -= i2[i]
			d_i2[i] += d_y
	end
	d_i1 = deepcopy(d_y)
	(d_i1, d_i2)
end
@btime d_for_test_raw($a, $b)
