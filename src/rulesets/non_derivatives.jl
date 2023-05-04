
"""
@non_differentiable(signature_expression)

A helper to make it easier to declare that a method is not not differentiable.
This is a short-hand for defining an [`frule`](@ref) and [`rrule`](@ref) that
return [`DoesNotExist()`](@ref) for all partials (even for the function `s̄elf`-partial
itself)

Keyword arguments should not be included.

```jldoctest
julia> @non_differentiable Base.:(==)(a, b)

julia> _, pullback = rrule(==, 2.0, 3.0);

julia> pullback(1.0)
(DoesNotExist(), DoesNotExist(), DoesNotExist())
```

You can place type-constraints in the signature:
```jldoctest
julia> @non_differentiable Base.length(xs::Union{Number, Array})

```

!!! warning
This helper macro covers only the simple common cases.
It does not support `where`-clauses.
For these you can declare the `rrule` and `frule` directly

"""
macro non_differentiable(sig_expr)
	Meta.isexpr(sig_expr, :call) || error("Invalid use of `@non_differentiable`")
	has_vararg = _isvararg(sig_expr.args[end])

	primal_name, orig_args = Iterators.peel(sig_expr.args)

	primal_name_sig, primal_name = _split_primal_name(primal_name)
	constrained_args = _constrain_and_name.(orig_args, :Any)
	primal_sig_parts = [primal_name_sig, constrained_args...]

	unconstrained_args = _unconstrain.(constrained_args)

	primal_invoke = if !has_vararg
			:($(primal_name)($(unconstrained_args...); kwargs...))
	else
			normal_args = unconstrained_args[1:end-1]
			var_arg = unconstrained_args[end]
			:($(primal_name)($(normal_args...), $(var_arg)...; kwargs...))
	end

	:($(_nondiff_rrule_expr(primal_name, primal_sig_parts, primal_invoke)))
end



function _nondiff_rrule_expr(primal_name, primal_sig_parts, primal_invoke)
	tup_expr = tuple_expression(primal_sig_parts)
	pullback_expr = Expr(
			:function,
			Expr(:call, :pullback, :_),
			Expr(:tuple, nothing, Expr(:(...), tup_expr))
	)
	return esc(:(
			function $(prop_name(:pb_,primal_name))($(primal_sig_parts...); kwargs...)
					return ($primal_invoke, $pullback_expr)
			end
	))
end
