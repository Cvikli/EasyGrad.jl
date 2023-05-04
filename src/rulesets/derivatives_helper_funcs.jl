




# "turn both `a` and `a::S` into `a`"
_unconstrain(arg::Symbol) = arg
function _unconstrain(arg::Expr)
    Meta.isexpr(arg, :(::), 2) && return arg.args[1]  # drop constraint.
    Meta.isexpr(arg, :(...), 1) && return _unconstrain(arg.args[1])
    error("malformed arguments: $arg")
end

# "turn both `a` and `::constraint` into `a::constraint` etc"
function _constrain_and_name(arg::Expr, _)
    Meta.isexpr(arg, :(::), 2) && return arg  # it is already fine.
    Meta.isexpr(arg, :(::), 1) && return Expr(:(::), gensym(), arg.args[1]) # add name
    Meta.isexpr(arg, :(...), 1) && return Expr(:(...), _constrain_and_name(arg.args[1], :Any))
    error("malformed arguments: $arg")
end
_constrain_and_name(name::Symbol, constraint) = Expr(:(::), name, constraint)  # add type

# For context on why this is important, see 
# https://github.com/JuliaDiff/ChainRulesCore.jl/pull/276
"Declares properly hygenic inputs for propagation expressions"
_propagator_inputs(n) = [esc(gensym(Symbol(:Δ, i))) for i in 1:n]

"""
    propagation_expr(Δs, ∂s, _conj = false)

    Returns the expression for the propagation of
    the input gradient `Δs` though the partials `∂s`.
    Specify `_conj = true` to conjugate the partials.
"""
function propagation_expr(Δs, ∂s, _conj = false)
    # This is basically Δs ⋅ ∂s
    _∂s = map(∂s) do ∂s_i
        if _conj
            :(conj($(esc(∂s_i))))
        else
            esc(∂s_i)
        end
    end
    n∂s = length(_∂s)

    summed_∂_mul_Δs = if n∂s > 1
        # Explicit multiplication is only performed for the first pair
        # of partial and gradient.
        init_expr = :((*).($(_∂s[1]), $(Δs[1])))

        # Apply `muladd` iteratively.
        foldl(Iterators.drop(zip(_∂s, Δs), 1); init=init_expr) do ex, (∂s_i, Δs_i)
            :((muladd).($∂s_i, $Δs_i, $ex))
        end
    else
        # Note: we don't want to do broadcasting with only 1 multiply (no `+`),
        # because some arrays overload multiply with scalar. Avoiding
        # broadcasting saves compilation time.
        :($(_∂s[1]) * $(Δs[1]))
    end

    return summed_∂_mul_Δs
end
prop_name(propname::Symbol, fname::QuoteNode) = prop_name(propname, fname.value)
prop_name(propname::Symbol, fname::Expr) = prop_name(propname, fname.args[end])
prop_name(propname::Symbol, fname::Symbol) = Symbol(propname, fname)

propagator_name(fname::QuoteNode, propname::Symbol) = propagator_name(fname.value, propname)
propagator_name(fname::Expr, propname::Symbol) = propagator_name(fname.args[end], propname)
propagator_name(fname::Symbol, propname::Symbol) = Symbol(fname, :_, propname)


_isvararg(expr) = false
function _isvararg(expr::Expr)
    Meta.isexpr(expr, :...) && return true
    if Meta.isexpr(expr, :(::))
        constraint = last(expr.args)
        constraint == :Vararg && return true
        Meta.isexpr(constraint, :curly) && first(constraint.args) == :Vararg && return true
    end
    return false
end

function _split_primal_name(primal_name)
    # e.g. f(x, y)
    if primal_name isa Symbol || Meta.isexpr(primal_name, :(.)) ||
        Meta.isexpr(primal_name, :curly)

        primal_name_sig = :(::Core.Typeof($primal_name))
        return primal_name_sig, primal_name
    # e.g. (::T)(x, y)
    elseif Meta.isexpr(primal_name, :(::))
        _primal_name = gensym(Symbol(:instance_, primal_name.args[end]))
        primal_name_sig = Expr(:(::), _primal_name, primal_name.args[end])
        return primal_name_sig, _primal_name
    else
        error("invalid primal name: `$primal_name`")
    end
end


function tuple_expression(primal_sig_parts)
    has_vararg = _isvararg(primal_sig_parts[end])
    return if !has_vararg
        num_primal_inputs = length(primal_sig_parts) - 1 # - primal
        Expr(:tuple, ntuple(_->nothing, num_primal_inputs)...)
    else
        num_primal_inputs = length(primal_sig_parts) - 2 # - primal and vararg
        length_expr = :($(num_primal_inputs) + length($(_unconstrain(primal_sig_parts[end]))))
        Expr(:call, :ntuple, Expr(:(->), :_, nothing), length_expr)
    end
end
