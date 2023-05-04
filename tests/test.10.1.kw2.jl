using Revise
using Test
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using CodeTracking
using EasyGrad
using FiniteDifferences

@easygrad fn_S(x) = begin
	y = x .* x * 20
	a = sum(y, dims=1)
	a
end
a = randn(2)
fn_S(a)
@time fn_S(a)
d_fn_S(a)
@time d_fn_S(a)
#%%
using Zygote
a = randn(2)
Zygote.pullback(sum, a, dims=1)
