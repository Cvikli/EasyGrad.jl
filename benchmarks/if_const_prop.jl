macro add!(lhs, rhs)
	esc(quote
		if $lhs isa Array
			$lhs += $rhs * 3
		else
			$lhs += $rhs * 2 + 1
		end
		$lhs
	end)
end

if_add(a::Array,b) = @add! a b
if_add(a::Number,b) = @add! a b
a, b = 2f0, 1f0
@code_llvm if_add(a, b)
# @code_llvm if_add([a], b)

#%%
macro add!(lhs, rhs)
	esc(quote
		if $lhs isa AbstractArray
			$lhs += $rhs
		else
			$lhs += $rhs
		end
		$lhs
	end)
end
a = 1f0
@macroexpand @add! a 1f0
test(a) = begin
	@add! a 1f0
	@time @add! a 1f0
	a
end

test(a)
#%%

macro addt!(lhs, rhs)
	@assert lhs.head == :tuple
	@assert length(lhs.args) == length(rhs.args)
	tmps = Tuple(gensym("t") for _ in 1:length(lhs.args))
	lines = Expr[]
	push!(lines, Expr(:(=), Expr(:tuple, tmps...), Expr(:tuple, rhs.args...)))
	for i in 1:length(tmps)
		push!(lines, :(@add! $(lhs.args[i]) $(tmps[i])))
	end
	esc( Expr(:block, lines...) )
end
c = 3f0
(@addt! (a, b) (2f0, c)) |> display
(@macroexpand1 @addt! (a, b) (2f0, c)) |> display
t = 1f0, 2f0
a, b = t
# if_add2
# @add_tuple! (a, b) = (b, a)
#%%
lhs, rhs = Expr(:tuple, :a, :b), Expr(:tuple, 2.0f0, 3.0f0)
@show lhs
# @assert lhs.head == :tuple
# @assert length(lhs.args) == length(rhs.args)
tuple_list = 1:length(lhs.args)
tmps = Tuple(gensym("t") for _ in tuple_list)
for i in tuple_list
	@show i
	@add! (tmps[i]) (rhs.args[i])
end
#%%
Meta.parse("@add! a b")