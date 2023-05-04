using Revise
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
# includet("../src/EasyGrad.jl")
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad


@easygrad if_test(i1, i2) = begin
	s = i1
	if any(i1 .> 1.)
		s += i1 .* i2
	elseif any(i1 .> 0.)
		s += i2 .+ i1 .* 2
	elseif any(i1 .> -1.)
		s += i2 .+ i1 .* 2
	elseif any(i1 .> -2.)
		s += i2 .* 2 .+ i1 .* 3
	else
		s += i2 .+ i1
	end
	# s
	y = s[1]
	y
end

println("-----EVALUATION-----")

a, b = [1.5f0], [-2.3f0]
a, b = [0.5f0], [-2.3f0]
a, b = [-0.5f0], [-2.3f0]
a, b = [-1.5f0], [-2.3f0]
@show a, b
if_test(a, b)
@show d_if_test(a, b)
@time if_test(a, b)
@show @time d_if_test(a, b)
using FiniteDifferences
j = grad(central_fdm(10, 1), if_test, a, b)
@show j
@time d_if_test(a, b)
# 0.000006 seconds (13 allocations: 1008 bytes)
@show d_if_test(a, b)
;
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote

a, b = rand(1), rand(1)
@btime if_test($a, $b)
@btime d_if_test($a, $b)
@btime gradient($if_test, $a, $b)
# 113.174 ns (6 allocations: 448 bytes)
# 361.114 ns (19 allocations: 1.30 KiB) # 483.841 ns (26 allocations: 1.83 KiB)
# 22.215 μs (113 allocations: 5.81 KiB)
#%%
br_ex = Expr(:block, :(a = 1 + 2), :(b = a * 2))
Expr(:if, :(2 > 1), br_ex, Expr(:elseif, :(2 > 3), br_ex, br_ex))
