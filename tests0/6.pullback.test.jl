using Revise
includet("6.func.test.jl")
using .FuncTest
#%%
a, b = [2f0], [3f0]
@show FuncTest.func_test(a, b)
@show FuncTest.d_func_test(a, b)


#%%
fn2(a) = 3a 
pb1(fn2, x) = (x, y->2*y)
fn1(x) = begin
	a = fn2(x) + x
	a
end
fn1_test(x) = begin
	a = begin 
		v, pbfn = pb1(fn2, x)
		v
	end + x
	v, a, pbfn(2)
end
fn1(1)
#%%
Meta.show_sexpr(:((y)->y))

#%%
macro asdf(ex)
	@show ex
	ex
end
using EasyGrad: @easygrad, @easygrad2
import EasyGrad

fun(x) = 2x
@easygrad fun(2)
@easygrad fun2(x) = 2x

