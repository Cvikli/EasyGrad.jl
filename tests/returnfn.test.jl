

fn2(x) = begin
	x, d_y -> begin
		d_x = d_y
		d_x
	end
end


ah(a, b) = begin
	c = a + b
	(c,b)
end
whut = @code_expr_easy fn2(2) 
@show dump(whut)
e = whut.args[2].args[3]
@show dump(e)
# @show dump(e.args[2])
;