
macro double(ex)
	sleep(0.1)
	@show "OK"
	quote
		$ex
		$ex
	end
end
test() = begin
	@double 1+3
end
@time test()
@time test()

#%%
using Revise
includet("./macro_revised.jl")
using .RevisedMacro: test_fn, macro_fn, @gen_ex
# using .RevisedMacro: module_value
# import .RevisedMacro
# @show revise(RevisedMacro)
#%%
@show (macro_fn(), test_fn(), )
# @show RevisedMacro.test_fn()
# @show RevisedMacro.module_value
#%%
@show revise(RevisedMacro)
@show RevisedMacro.generated_fn()
@show RevisedMacro.module_value

#%%
isreeval(a) = begin
	@gen_ex b = a
	@show b
end
#%%

macro g_2_code(ex)
	  @show (fn_symb, fn_args)

	@show "Regenerate"
	esc(quote
		$ex
	end)
end
isreeval(2)
isreeval(3)