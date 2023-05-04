
using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad


@easygrad tuple_assign(x) = begin
	a = x * 2
	y, y_v = a, 2a
	y2 = y_v + y
	y2
end

println("-----EVALUATION-----")

a = 2f0
@show tuple_assign(a)
@time tuple_assign(a)
@show d_tuple_assign(a)
@show @time d_tuple_assign(a)
@time d_tuple_assign(a)
# 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
@show d_tuple_assign(a)
using FiniteDifferences
j = grad(central_fdm(5, 1), tuple_assign, a)
@show j
#%%
@code_warntype pb_tuple_assign(a)
#%%
using BenchmarkTools
using Zygote
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@btime $tuple_assign($a)
@btime $d_tuple_assign($a)
@btime gradient(tuple_assign, $a)
# 0.014 ns (0 allocations: 0 bytes)
# 0.014 ns (0 allocations: 0 bytes)
# 1.121 ns (0 allocations: 0 bytes)
#%%
pb_tuple_assign2(x) = begin
end
@show pb_tuple_assign2([2f0])[2]
# @btime pb_tuple_assign2([2f0])[2](1f0)
# @code_warntype pb_tuple_assign2([2f0])
#%%
add!(a, b) = a += b
d_y = y = 2
tmp = d_y
d_y = add!(d_y, y*tmp)
d_y = add!(d_y, y*tmp)

#%%
e1 = :(a + b)
e2 = :(c + d)
e1 = :($e1 + $e2)