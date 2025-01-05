using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad
using FiniteDifferences

@easygrad indexing_test(i1, i2) = begin
  y = i1
	list = 1:16
	for i in list
		y += i2[i]
	end
  y
end debug="../tests/test_cases_functions/generated_test.4.indexing.jl"

a, b = 2f0, Float32.([1:16...])

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), indexing_test, a, b) .≈ d_indexing_test(a, b)) 
end

#%%
# println("-----EVALUATION-----")

# indexing_test(a, b)
# @show d_indexing_test(a, b)
# @time indexing_test(a, b)
# @show @time d_indexing_test(a, b)
# 
# j = grad(central_fdm(5, 1), indexing_test, a, b)
# @show j
# @time d_indexing_test(a, b)
# @show d_indexing_test(a, b)
# ;
# #%%
# using BenchmarkTools
# using Zygote
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
# @btime indexing_test($a, $b)
# @btime d_indexing_test($a, $b)
# @btime gradient($indexing_test, $a, $b)
# # 4.309 ns (0 allocations: 0 bytes)
# # 70.414 ns (4 allocations: 208 bytes)
# # 10.018 μs (275 allocations: 11.03 KiB)
# ;
# #%%
# # Expr(:call, :(:), 2, end

# #%%
# d_indexing_test_raw(i1, i2) = begin
# 	y = i1
# 	list = 1:16
# 	for i = list
# 			y += i2[i]
# 	end
# 	y
# 	d_y = 1.0f0
# 	i = list[end]
# 	d_i2 = zero(i2)
# 	for i = reverse(list)
# 			y -= i2[i]
# 			d_i2[i] += d_y
# 	end
# 	d_i1 = deepcopy(d_y)
# 	(d_i1, d_i2)
# end
# @btime d_indexing_test_raw($a, $b)
