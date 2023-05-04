module RevisedMacro
using Revise

# macro gen_fn(ex)
# 	esc(quote
# 		generated_fn() = $ex
# 	end)
# end
# @gen_fn 5

# macro gen_val(ex)
# 	esc(quote
# 		module_value = $ex
# 	end)
# end
# @gen_val 7



macro gen_ex(ex)
	@show "Regenerate"
	esc(quote
		$ex
	end)
end
@gen_ex macro_fn() = 6
test_fn() = 6


end