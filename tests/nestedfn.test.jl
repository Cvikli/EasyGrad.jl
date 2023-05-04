fn2(x) = x .* x
fn1(x) = begin
	fn2(x) .+ 1
end

macro expander(ex)
	mod = __module__
	@show ex
	@show macroexpand(__module__, ex)
	esc(ex)
end
whut = @code_expr_easy fn2(2) 
@show dump(whut)
@show @expander fn1(2)
;