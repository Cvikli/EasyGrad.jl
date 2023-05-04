using FastClosures

fn_gen(x) = begin
	x .*= 10
	x1 = 10 .* x
	x2 = 10 .* x
	x3 = 10 .* x
	x4 = 10 .* x
	pb = @closure (a) -> begin
		a = 2 .* x .* a .+ x1 .+ x2 .+ x3 .+ x4 .+ x4 .+ x1
	end
	pb(0.25)
end

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
# @code_warntype fn_gen([2.1])
@btime $fn_gen([1.2])
#%%

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote
# include("6.func.test.jl")
import .FuncTest: func_test, d_func_test
#%%
import .FuncTest.FuncTest: func_test, d_func_test
a, b = rand(1), rand(1)
@time func_test(a, b)
@btime $func_test($a, $b)
@time d_func_test(a, b)
@btime $d_func_test($a, $b)
@btime $gradient($func_test, $a, $b) 

#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
fn_add(x) = for i in 1:100 x.+=1 end
fn_add2(x) = for i in 1:100 x .= 1 .+ x end
@btime fn_add([3])
@btime fn_add2([3])

#%%
#%%

# Test Summary:                   | Pass  Fail  Error  Total
# ∑                               |   18     7      9     34
#   test_basic.jl                 |    5     4      4     13
#     Gradient check              |    1                   1
#     Source by lines             |    4     4      4     12
#   test.2.mutable_3.jl           |          1             1
#     Gradient check              |          1             1
#   test.3.1.for.jl               |    1                   1
#   test.3.2.for.refalloc.jl      |    1                   1
#   test.3.3.for_avx.jl           |    5                   5
#   test.3.4.sum_avx.jl           |    1                   1
#   test.3.5.for_comprehension.jl |                 1      1
#     Gradient check              |                 1      1
#   test.4.indexing.jl            |    1                   1
#   test.5.1.if.jl                |          1             1
#     Gradient check              |          1             1
#   test.5.2.ternary.jl           |                 1      1
#   test.6.1.func.jl              |                 1      1
#     Gradient check              |                 1      1
#   test.6.2.func.jl              |    1            1      2
#     Gradient check              |    1            1      2
#   test.6.3.func_variations.jl   |                 1      1
#   test.7.1.type.jl              |    1                   1
#   test.7.2.where_type.jl        |    1                   1
#   test.8.1.assignment.jl        |          1             1
#     Gradient check              |          1             1
#   test.8.2.tuple_assign.jl      |    1                   1
# 
# Test Summary:                   | Pass  Fail  Error  Total
# ∑                               |   28     1      5     34
#   test_basic.jl                 |   13                  13
#   test.2.mutable_3.jl           |    1                   1
#   test.3.1.for.jl               |    1                   1
#   test.3.2.for.refalloc.jl      |    1                   1
#   test.3.3.for_avx.jl           |    5                   5
#   test.3.4.sum_avx.jl           |    1                   1
#   test.3.5.for_comprehension.jl |                 1      1
#     Gradient check              |                 1      1
#   test.4.indexing.jl            |    1                   1
#   test.5.1.if.jl                |    1                   1
#   test.5.2.ternary.jl           |                 1      1
#   test.6.1.func.jl              |                 1      1
#     Gradient check              |                 1      1
#   test.6.2.func.jl              |    1            1      2
#     Gradient check              |    1            1      2
#   test.6.3.func_variations.jl   |                 1      1
#   test.7.1.type.jl              |    1                   1
#   test.7.2.where_type.jl        |    1                   1
#   test.8.1.assignment.jl        |          1             1
#     Gradient check              |          1             1
#   test.8.2.tuple_assign.jl      |    1                   1

# Test Summary:                   | Pass  Fail  Error  Total
# ∑                               |   30     1      3     34
#   test_basic.jl                 |   13                  13
#   test.2.mutable_3.jl           |    1                   1
#   test.3.1.for.jl               |    1                   1
#   test.3.2.for.refalloc.jl      |    1                   1
#   test.3.3.for_avx.jl           |    5                   5
#   test.3.4.sum_avx.jl           |    1                   1
#   test.3.5.for_comprehension.jl |                 1      1
#     Gradient check              |                 1      1
#   test.4.indexing.jl            |    1                   1
#   test.5.1.if.jl                |    1                   1
#   test.5.2.ternary.jl           |    1                   1
#   test.6.1.func.jl              |    1                   1
#   test.6.2.func.jl              |    1            1      2
#     Gradient check              |    1            1      2
#   test.6.3.func_variations.jl   |                 1      1
#   test.7.1.type.jl              |    1                   1
#   test.7.2.where_type.jl        |    1                   1
#   test.8.1.assignment.jl        |          1             1
#     Gradient check              |          1             1
#   test.8.2.tuple_assign.jl      |    1                   1