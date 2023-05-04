using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

@easygrad square(x) = begin
	y = x * x
	y
end

println("-----EVALUATION-----")

a = randn(10000)
# @show square.(a)
@time square.(a)

# @show d_square.(a)
@time d_square.(a)
@time d_square.(a)
# @time d_square(a[1])
# @time d_square(a[1])


using Zygote
r = gradient(square, a[1])
@time r = gradient(square, a[1])
@show r
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@time d_square.(a)
@time d_square.(a)
@btime d_square.($a)
;
#%%
using GFlops
using LoopVectorization
@gflops sum(a)
@gflops ret .= square.(a)
@gflops ret .= a .* a
@gflops ret .= a .^ 2;
# @btime ret .= $a .^ 2;
# avx_sq(x) = @avx x .^ 2
# @gflops ret .= avx_sq(a);
# @btime ret .= avx_sq($a);
@btime ret .= square.($a);
#%%
@btime for i in 1:length(a)
	ret[i] = a[i] * a[i]
end
;
#%%
pb_square(x) = begin
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/12.broadcast.test.jl:7 =#
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/12.broadcast.test.jl:8 =#
	y = x * x
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/12.broadcast.test.jl:9 =#
	(y, #= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:483 =# EasyGrad.@refclosure((dd_y->begin
									d_y = deepcopy(dd_y)
									d_x = x * d_y + x * d_y
									(d_x,)
							end)))
end
pb_extractor(fns, dy) = fns[2](dy)
fn(a) = pb_square(a)[2](1)
fn_pro(a) = pb_extractor.(pb_square.(a), 1)
ret = zero(a)
@time ret .= square.(a)
# @btime ret .= square.(a)
# @time ret .= fn.(a)

@btime ret .= extract1(fn.(a))
@typeof fn_pro(a)
#@btime ret .= fn_pro(a)
#%%
sqbc(a) = square.(a)
N = 10
inp = randn(N)
@btime square.(inp)
d_square.(inp)
# @show d_square.(inp)
@btime extract1.(d_square.(inp))
pullback(sqbc, inp)[2](zero(inp) .+ 1)
# @show pullback(sqbc, inp)[2](zero(inp) .+ 1)
@btime pullback(sqbc, inp)[2](zero(inp) .+ 1)
@btime gradient(a -> sum(sqbc(a)), inp)
;
#%%
a2 = randn(2)
ret2 = zero(a2)
extract1(y) = y[1]
@time ret2 .= extract1.(fn.(a2))
@btime fn.(a2)
# @btime ret2 .= extract1.(fn.(a2))
;
#%%
test() = begin
extract1(a)= a[1]
extract2(a)= a[2]
extract3(a)= a[3]
extract4(a)= a[4]
N = 100000
test_g = [(rand(), rand(), rand(), rand()) for i in 1:N]
@typeof test_g
g1, g2, g3, g4 = extract1.(test_g), extract2.(test_g), extract3.(test_g), extract4.(test_g)
@time g1, g2, g3, g4 = extract1.(test_g), extract2.(test_g), extract3.(test_g), extract4.(test_g)
end
test()
;
#%%
fn2.(a, b) := array(da), array(db)
array(sizea)((da, db))



