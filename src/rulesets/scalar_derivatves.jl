

function _normalize_scalarrules_macro_input(call, maybe_setup, partials)
	############################################################################
	# Setup: normalizing input form etc

	if Meta.isexpr(maybe_setup, :macrocall) && maybe_setup.args[1] == Symbol("@setup")
			setup_stmts = map(esc, maybe_setup.args[3:end])
	else
			setup_stmts = (nothing,)
			partials = (maybe_setup, partials...)
	end
	@assert Meta.isexpr(call, :call)

	# Annotate all arguments in the signature as scalars
	inputs = esc.(_constrain_and_name.(call.args[2:end], :Number))
	# Remove annotations and escape names for the call
	call.args[2:end] .= _unconstrain.(call.args[2:end])
	call.args = esc.(call.args)

	# For consistency in code that follows we make all partials tuple expressions
	partials = map(partials) do partial
			if Meta.isexpr(partial, :tuple)
					partial
			else
					length(inputs) == 1 || error("Invalid use of `@scalar_rule`")
					Expr(:tuple, partial)
			end
	end

	return call, setup_stmts, inputs, partials
end

macro scalar_rule(call, maybe_setup, partials...)
	call, setup_stmts, inputs, partials = _normalize_scalarrules_macro_input(call, maybe_setup, partials)
	f = call.args[1]
	rrule_expr = scalar_rrule_expr(f, call, setup_stmts, inputs, partials)
end

function scalar_rrule_expr(f, call, setup_stmts, inputs, partials)
	n_outputs = length(partials)
	n_inputs = length(inputs)

	# Δs is the input to the propagator rule
	# because this is a pull-back there is one per output of function
	Δs = _propagator_inputs(n_outputs)

	# 1 partial derivative per input
	pullback_returns = map(1:n_inputs) do input_i
			∂s = [partial.args[input_i] for partial in partials]
			propagation_expr(Δs, ∂s, true)
	end

	# Multi-output functions have pullbacks with a tuple input that will be destructured
	pullback_input = n_outputs == 1 ? first(Δs) : Expr(:tuple, Δs...)
	pullback = :(function pullback($(pullback_input))
					return ($(pullback_returns...),)
			end)

	return :(function $(esc(prop_name(:pb_,f)))($(inputs...))
					$(esc(:Ω)) = $call
					$(setup_stmts...)
					return $(esc(:Ω)), $pullback
			end)
end
