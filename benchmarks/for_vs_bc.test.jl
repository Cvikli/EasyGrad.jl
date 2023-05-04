

using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

square(x) = x .* x
a = randn(Float32, 100000)
ret = Vector{Float32}(undef, size(a)...)
sq_scalar(x) = x * x
sqb(x) = sq_scalar(x)
sq(y, x) = y .= x .* x

sq2(y, x) = begin
	@inbounds for i in 1:length(x)
		y[i] = sq_scalar(x[i])
	end
	y
end

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
@btime broadcast!(sqb, $ret, $a)
@btime sq($ret, $a)
@btime sq2($ret, $a)
;

#%%
# @eval Symbol("'+")
# :('+)(a,b) = a - b
# :(+)(1, 2)
#%%
fn(x) = x
a = randn(10000)

@time a .= fn(a)
@time a .= fn(a)
@time a .= a
@time a .= a
;
