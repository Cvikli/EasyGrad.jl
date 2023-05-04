using Revise
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using FiniteDifferences
using EasyGrad: @easygrad, @code_expr_easy, process_body


type_test(i1::Float32, i2::Array{Float32}) = begin
	a::Float32 = i1 * 2 + i2[1]
	a
end

a, b = 2f0, [3f0]
@easygrad type_test(a, b)
println("-----EVALUATION-----")

type_test(a, b)
@show d_type_test(a, b)
@time type_test(a, b)
@show @time d_type_test(a, b)
j = grad(central_fdm(5, 1), type_test, a, b)
@show j
@time d_type_test(a, b)
# 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
@show d_type_test(a, b)
;

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote

@btime $type_test($a, $b)
@btime $d_type_test($a, $b)
@btime $gradient($type_test, $a, $b)
# 1.123 ns (0 allocations: 0 bytes)
# 30.605 ns (2 allocations: 112 bytes)
# 35.869 ns (2 allocations: 128 bytes)
;