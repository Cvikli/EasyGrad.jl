
using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

struct Test
	a::Float32
	b
end

@easygrad dot_test(i, x) = begin
	a = i*3
	h = x.a * a
	y = x.b * 2 + h
	y
end

println("-----EVALUATION-----")

x = Test(2f0, 12.)
a = 1f0
@show dot_test(a, x)
@time dot_test(a, x)

using Zygote
r = gradient(dot_test, a, x)
@show r

@show d_dot_test(a, x)
@show @time d_dot_test(a, x)
@time d_dot_test(a, x)
# 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
@show d_dot_test(a, x)
using FiniteDifferences
j = grad(central_fdm(5, 1), dot_test, a, x)
@show j
#%%
using BenchmarkTools
using Zygote
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@btime $dot_test($a, $x)
@btime $d_dot_test($a, $x)
@btime gradient(dot_test, $a, $x)
#%%
@code_warntype pb_dot_test(a, x)
#%%
a = QuoteNode(:y)
# a = Expr(:quote, :x)
@show a.args
a.head
#%%
@typeof :(:x)
Meta.show_sexpr(:(:x))
#%%
# a = :(a)
nt = :((x=1, $(a.value)=3))
@show eval(nt)
Meta.show_sexpr(nt)
#%%
t = (a=1, b=randn(10))
@show t
@show t.a
@time t = (t..., c=2)
@time (t..., d=2)
;