
using Revise
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad


@easygrad tuple_asymmetric(x) = begin
	a = x .* 2
	res = a, 2a
	y, y_v = res
	y2 = y_v .+ y
	out = y2[1]
	out
end

println("-----EVALUATION-----")

a = [2f0]
@show tuple_asymmetric(a)
# @time tuple_asymmetric(a)
@show d_tuple_asymmetric(a)
@show @time d_tuple_asymmetric(a)
# @time d_tuple_asymmetric(a)
# # 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
# @show d_tuple_asymmetric(a)
# using FiniteDifferences
# j = grad(central_fdm(5, 1), tuple_asymmetric, a)
# @show j
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), tuple_asymmetric, a) .≈ d_tuple_asymmetric(a))
end
#%%
# @code_warntype pb_tuple_asymmetric(a)
# #%%
# using BenchmarkTools
# using Zygote
# a = randn(Float32, 2, 2)
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
# @btime gradient(tuple_asymmetric, $a)
# @btime $tuple_asymmetric($a)
# @btime $d_tuple_asymmetric($a)
# # 0.014 ns (0 allocations: 0 bytes)
# # 0.014 ns (0 allocations: 0 bytes)
# # 1.121 ns (0 allocations: 0 bytes)
# #%%
# pb_tuple_asymmetric2(x) = begin
# end
# @show pb_tuple_assign2([2f0])[2]
# # @btime pb_tuple_assign2([2f0])[2](1f0)
# # @code_warntype pb_tuple_assign2([2f0])
# #%%
# add!(a, b) = a += b
# d_y = y = 2
# tmp = d_y
# d_y = add!(d_y, y*tmp)
# d_y = add!(d_y, y*tmp)

# #%%
# e1 = :(a + b)
# e2 = :(c + d)
# e1 = :($e1 + $e2)