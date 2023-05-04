module EasyGrad
using Revise
using CodeTracking
using DataStructures
using Zygote
using Boilerplate: @typeof, @sizes
using FillArrays
using SyntaxTree: linefilter!
import Base.Iterators
import Base.Meta: show_sexpr, isexpr

include("EasyStructs.jl")
include("ExprHelpers.jl")
include("RefClosures.jl")

import ..RefClosures: @refclosure, ►

import ..EasyStructs: InitFwInitPullback, InitPullback, EasyZero, EasyInit, EasyContext
import ..EasyStructs: push_iter!, pop_iter!, get_iter_fw_init, get_context_indexed
import ..EasyStructs: get_s_sym, dec_s_sym!, is_s_sym_used, is_sym_exists, is_sym_ignored, add_sym_to_used
import ..EasyStructs: gen_iter_sym, gen_fn_sym

import ..ExprHelpers: transform_func_symbol_to_pb!, get_funcsymbol, get_funcargs, show_expr, @show_expr

export @easygrad
export @refclosure, ►

export sensitivity
export @addt!, @add!, e_zero, ∑!  # necessary for "beautiful code generation"
export zero!
export zpullback

macro code_expr_easy(myex)
	esc(quote 
    res = $EasyGrad.@code_expr $myex
		res !== nothing ? res : Meta.parse($EasyGrad.@code_string $myex)
  end)
end

∑!(dest::Nothing, src::Nothing) = dest # In some cases when not all tuple elements are filled with nothing, it is necessary
∑!(dest::AbstractArray, src::Nothing) = dest # In some cases when not all tuple elements are filled with nothing, it is necessary
∑!(dest::Tuple, src::Nothing) = dest # In some cases when not all tuple elements are filled with nothing, it is necessary
∑!(dest::AbstractArray, src::AbstractArray) = begin
  sum!(dest, src, init=false)  # To "back sum" broadcasted parts.
end
∑!(dest::Vector{Array{Float32, N}}, src::Vector{Union{Nothing, Array{Float32, N}}}) where N= begin
  for i in 1:length(dest)
    ∑!(dest[i], src[i]) 
  end
  dest
end
∑!(dest::Vector{Array{T, N}}, src::Vector{Array{T, N}}) where {N,T <: Float32}= begin
  for i in 1:length(dest)
    ∑!(dest[i], src[i]) 
  end
  dest
end
∑!(dest::Vector{T}, src::Vector{T2}) where {T<:AbstractArray, T2<:AbstractArray}= begin
  for i in 1:length(dest)
    ∑!(dest[i], src[i]) 
  end
  dest
end
∑!(dest::Vector{Array{T, N}}, src::Tuple) where {N,T <: Float32} = begin
  for i in 1:length(dest)
    ∑!(dest[i], src[i]) 
  end
  dest
end
∑!(dest::Tuple, src::Tuple) = begin
  @assert length(dest) === length(src) "Only same length is supported for tuples."
  Tuple(∑!(dest[i], src[i]) for i in 1:length(dest))
end
∑!(dest::Number, src::AbstractArray) = dest += (sum)(src)
∑!(dest::AbstractArray, src::Number) = dest .+= src
∑!(dest, src) = dest += src
macro add!(lhs, rhs)
	esc(quote
    $lhs = (∑!)($lhs, $rhs) # TODO replace everything to: ∑! 
	end)
end
macro addt!(lhs, rhs)
	@assert lhs.head == :tuple
	@assert length(lhs.args) == length(rhs.args)
	tmps = Tuple(gensym("t") for _ in 1:length(lhs.args))
	lines = Expr[]
	push!(lines, Expr(:(=), Expr(:tuple, tmps...), Expr(:tuple, rhs.args...)))
	for i in 1:length(tmps)
		push!(lines, :(@add! $(lhs.args[i]) $(tmps[i])))  # reduce add! to here... why macro in a macro...
	end
	esc(Expr(:block, lines...))
end

zpullback = Zygote.pullback 
expr_args(ex::Expr) = ex.args
expr_args(arr::Array) = arr

# if init already defined, then someone else is taking care of init, we don't reinit.
create_init(init::Nothing) = EasyInit(Expr[], Expr[])
create_init(init::EasyInit) = init
modify_fw!(ex, init, res::InitFwInitPullback) = begin
  if res.fw_init !== nothing
    push!(init.fw, res.fw_init)
  end
  ex.head, ex.args = res.fw.head, res.fw.args
end 
modify_fw!(fw, init, res::Any) = fw
push_initbw!(init::EasyInit, ex) = push!(init.bw, ex) 
# create_init(init::Nothing) = Expr[]  # TODO use this
# create_init(init) = init             # TODO use this
finish_init!(fwex, bwex, easyinit::EasyInit, orig_init) = begin
  initfw = easyinit.fw
  if orig_init === nothing && length(initfw) > 0
    tmp = deepcopy(fwex)
    fwex.head = :block
    fwex.args = [initfw..., tmp]
  end
  initbw = easyinit.bw
  if orig_init === nothing && length(initbw) > 0
    # push!(pb_exs, to_expr_block(init))
    # append!(pb_exs, init)
    if length(initbw) == 1
      push!(bwex, :($(initbw[1].args[1])=$(initbw[1].args[2])))
    else
      lhs=(i.args[1] for i in initbw)
      rhs=(i.args[2] for i in initbw)
      push!(bwex, :(($(lhs...),)=($(rhs...),)))
    end
  # else
  #   push!(orig_init, to_expr_block(init))
  end
end
to_expr_block(ex_args) = length(ex_args) > 1 ? Expr(:block, ex_args...) : length(ex_args) == 1 ? ex_args[1] : nothing
# easygradpostaction(s::Symbol, ex::Expr, symbol_dict::DefaultDict{Symbol, Number}) = begin
#   return nothing
# end
easypreaction(s::Symbol, ex::Expr, c::EasyContext) = begin
  # if s == :(.=)
  #   return (dy -> (nothing, :($(ex.args[1]) .= $(Symbol(:saved_, ex.args[1])))))
  # end
  @assert s in [:+=, :.+=, :-= , :.-=, :*= , :.*=, :/= , :./=]  "No action for: $s"
  reverse_add = deepcopy(ex)
  if s == :+=         reverse_add.head = :-=
  elseif s == :.+=    reverse_add.head = :.-=
  elseif s == :-=     reverse_add.head = :+=
  elseif s == :.-=    reverse_add.head = :.+=
  elseif s == :*=     reverse_add.head = :/=
  elseif s == :.*=    reverse_add.head = :./=
  elseif s == :/=     reverse_add.head = :*=
  elseif s == :./=    reverse_add.head = :.*=
  end
  return reverse_add
end
rrule_fnsymbol(::Val{s}, args...; c::EasyContext) where s = begin
  # @warn "Not known function symbol: $s"
  tmp, pbsym, pb_tmp = gen_fn_sym(c, "val_$s"), gen_fn_sym(c, "∂fn_$s"), gen_fn_sym(c, "∂val_$s")
  pbfnsym_indexed = get_context_indexed(c, pbsym)
  is_easygradpb = isdefined(c.call_module, Symbol(:pb_, s)) || c.fn_name == s
  fwpbfn = is_easygradpb ?
            :($(Symbol(:pb_, s))($(args...),)) : 
            :(zpullback($s, $(args...),))

  return InitFwInitPullback(get_iter_fw_init(c, pbsym, fwpbfn),
                            :(($tmp, $pbfnsym_indexed) = $fwpbfn; $tmp), 
                            dy -> :($pb_tmp = $pbfnsym_indexed($dy)),
                            dy -> collect(:($pb_tmp[$i]) for i in 1:length(args))) # TODO no need for collect just maybe more human readable internals..
end



rrule(s::Val{:zero}, x; c::EasyContext, kw...) = (dy -> (:(zero($dy)),))
rrule(s::Val{:abs}, x; c::EasyContext, kw...) = (ȳ -> (:(
  signx = sign(x);
  signx * ȳ),))
rrule(s::Val{:inv}, x; c::EasyContext, kw...) = (ȳ -> (:(-(inv($x) ^ 2)),))
rrule(s::Val{:sum}, x; c::EasyContext, kw...) = (ȳ -> (:(broadcast($x, $ȳ) do xi, ȳi
                                                              ȳi
                                                            end),))
# rrule(s::Val{:mean}, x; c::EasyContext, kw...) = (ȳ -> (:(∂sum_x = broadcast($x, $ȳ) do xi, ȳi
#                                                               ȳi
#                                                             end;
#                                                             n = _denom($x, dims);
#                                                             ∂x = ∂sum_x / n;
#                                                             ∂x),))
# rrule(s::Val{:exp}, x; c::EasyContext, kw...) = (dy -> (:($dy),))
# rrule(s::Val{:σ}, x; c::EasyContext, kw...) = (dy -> (:($dy),))

rrule(s::Val{:+}, x, y; c::EasyContext, kw...) = (dy -> (:($dy), :($dy)))
rrule(s::Val{:-}, x, y; c::EasyContext, kw...) = (dy -> (:($dy), :(-$dy)))
rrule(s::Val{:*}, x, y; c::EasyContext, kw...) = (dy -> (:($dy * $y'), :($x' * $dy)))
rrule(s::Val{:.+}, x, y; c::EasyContext, kw...) = (dy -> (:($dy), :($dy)))
rrule(s::Val{:.-}, x, y; c::EasyContext, kw...) = (dy -> (:($dy), :(-$dy)))
rrule(s::Val{:.*}, x, y; c::EasyContext, kw...) = (dy -> (:($y .* $dy), :($x .* $dy)))
rrule(s::Val{:./}, x, y; c::EasyContext, kw...) = (dy -> (:($dy / $y), :(-$x * $dy / ($y * $y))))
rrule(s::Val{:.^}, x, y; c::EasyContext, kw...) = (dy -> (:($y .* $x .^ ($y-1) .* $dy), :(log($x) * ($x ^ $y) * $dy)))
rrule(s::Val{:(:)}, x, y; c::EasyContext, kw...) = (dy -> (nothing, nothing))  # Colon

rrule(s::Val{S}, a; c::EasyContext, kw...) where S = rrule_fnsymbol(s, a; c=c)
rrule(s::Val{S}, x, y; c::EasyContext, kw...) where S = rrule_fnsymbol(s, x, y; c=c)
rrule(s::Val{S}, args...; c::EasyContext, kw...) where S = rrule_fnsymbol(s, args...; c=c)

# easygrad(::typeof(Base.:(.*)), a, b) = (dy -> (nothing, :(b .* $dy), :(a .* $dy)))


# e_zero(a::AbstractArray) = EasyZero(size(a))
# e_zero(vec::Vector{AbstractArray{T}}) where T = [zero(a) for a in vec] # why we can't use this simply instead the next 2 lines
e_zero(vec::Vector{Array{Float32, N}}) where N = [zero(a) for a in vec] # TODO why we need this specific code?
e_zero(vec::Vector{Array{T}}) where T = [zero(a) for a in vec]
e_zero(vec::Vector{Vector{T}}) where T = [e_zero(a) for a in vec]
e_zero(vec::Vector{Vector{Function}}) = begin end # TODO remove it later.
e_zero(vec::Vector{Vector{Array{Float32, T}}}) where T = [e_zero(a) for a in vec]
e_zero(vec::Vector{Vector{Vector{T}}}) where T = [e_zero(a) for a in vec]
e_zero(a::AbstractArray{T}) where T = begin
  zero(a)
end
e_zero(a::Number) = 0f0
e_zero(a::Vector{Any}) = @assert false "Unhandled e_zero case: $(typeof(a))"
e_zero(a::Any) = nothing
e_zero(a::Ref) = @assert false "It shouldn't happen."
e_zero(a::Tuple) = Tuple(e_zero(a[i]) for i in 1:length(a))
zero!(arr::Nothing) = nothing
zero!(arr::Float32) = nothing
zero!(arr::Array{Float32}) = arr .= 0f0
zero!(arr::Vector{Array{Float32, N}}) where N = [zero!(a) for a in arr]
zero!(arr::Vector{Vector{Array{Float32, N}}}) where N = [zero!(a) for a in arr]

use_sym(sym::Symbol, init_sym, pullback_body, init_exprs, init, ec::EasyContext) = begin
  if !haskey(ec.symbol_dict, sym)
    if init || init_exprs !== nothing
      zero_init = init ? e_zero : e_zero
      if init_exprs !== nothing
        push!(init_exprs.bw, :($sym = e_zero($init_sym)))
      else
        push!(pullback_body, :($sym = e_zero($init_sym)))
      end
      add_sym_to_used(ec, sym)
      return true
    end
  else
    return true
  end
  return false
end

gen_d_sym(ex::Expr) = begin
  if ex.head==:ref
    return Expr(ex.head, gen_d_sym(ex.args[1]), ex.args[2:end]...)
  elseif ex.head == :(::)
    return gen_d_sym(ex.args[1])
  elseif ex.head == :tuple
    return Expr(ex.head, (gen_d_sym(ex.args[i]) for i in 1:length(ex.args))...)
  else
    show_expr(ex)
    @assert false "Unsupported d_symbol creation: $(ex.head)"
  end
end
gen_d_sym(sym::Symbol) = Symbol(:d_, sym) # TODO no point in numbering?

unwrap_sym(ex::Expr) = begin
  if isexpr(ex, :(::))
    return unwrap_sym(ex.args[1])
  elseif isexpr(ex, :.)
    return unwrap_sym(ex.args[1])  
  elseif isexpr(ex, :ref)
    return unwrap_sym(ex.args[1])  
  end
  show_expr(ex)
  @assert false "still not supported $ex"
end
unwrap_sym(sym::Symbol) = sym

init_or_add!(pullback_body, isexists, sym, dy, ec) = if isexists
  push!(pullback_body, :(@add! $sym $dy))
else
  push!(pullback_body, :($sym = $dy))
  # add_sym_to_used(ec, sym)
end
handle_symbols(sym::Symbol, dy, pullback_body, context, init_exprs) = begin
    # TODO we could merge zero init + addition as one operation.
    is_sym_ignored(context, sym) && return
    d_sym = gen_d_sym(sym)
    isexists = use_sym(d_sym, sym, pullback_body, init_exprs, false, context)
    init_or_add!(pullback_body, isexists, d_sym, dy, context)
    return
end

get_sym_n_value(a) = begin
  if a.head == :macrocall
    return a.args[3:4]
  end
  a.args
end
regroup_by_assigned(assigns) = begin
  assign_map = OrderedDict{Union{Symbol, Expr}, Union{Expr, Symbol, Nothing}}()
  for a in assigns
    sym, value = get_sym_n_value(a)
    assign_map[sym] = haskey(assign_map,sym) ? :($(assign_map[sym]) + $value) : value  # TODO think if we need  .+ 
  end
  collect(keys(assign_map)), collect(values(assign_map))
end
can_get_sym_n_value(a) = a.head == :macrocall || a.head == :(=)  
can_regroups_assignments(assigns) = begin
  for a in assigns
    if !can_get_sym_n_value(a)
      return false
    end
  end
  return true
end
push_assignment!(pullback_body, assign_body, context) = begin
  if length(assign_body)>1 && can_regroups_assignments(assign_body)
    d_syms, d_values = regroup_by_assigned(assign_body)
    for d_sym in d_syms
      add_sym_to_used(context, d_sym)
    end
    is_tuple_assingment = length(d_syms) != 1
    if is_tuple_assingment
      macro_tuple_add = :(@addt! ($(d_syms...),) ($(d_values...),))
    else
      macro_tuple_add = :(@add! $(d_syms[1]) $(d_values[1]))
    end
    push!(pullback_body, macro_tuple_add)
  elseif length(assign_body)>=1 
    append!(pullback_body, assign_body)
    # @assert false "No gradient backprop"
  end
end
push_reassign_symbols!(pullback_body, sym::Symbol, context::EasyContext) = begin
  is_overwrite = is_s_sym_used(context, sym) && get_s_sym(context, sym) !== nothing
  if is_overwrite 
    s_sym = get_s_sym(context, sym)
    d_sym = gen_d_sym(sym)
    dec_s_sym!(context, sym)
    # @show "IT ALREADY EXISTS $sym $(context.save_sym_dict[sym])"
    save_sym = gensym("save")  # TODO unused!
    # ex = :($s_sym = $sym; $ex)   # rewrite the original expression with an appended save
    # push!(pullback_body, :($sym = $s_sym))
    push!(pullback_body, :(zero!($d_sym)))
  end
end
push_reassign_symbols!(pullback_body, ex::Expr, context::EasyContext) = begin
  if isexpr(ex, :tuple)
    for e in ex.args
      push_reassign_symbols!(pullback_body, e, context)
    end
    return
  elseif isexpr(ex, :(::))
    push_reassign_symbols!(pullback_body, ex.args[1], context)
    return
  elseif isexpr(ex, :.)
    return push_reassign_symbols!(pullback_body, ex.args[1],context)  
  elseif isexpr(ex, :ref)
    #  push_reassign_symbols!(pullback_body, ex.args[1], context)  
    return
  end
  show_expr(ex)
  @assert false "still not supported $ex"
end
handle_assignment(ex, dy, pullback_body, context, init_exprs) = begin
  # ex = (:(=), :c, (:call, :.+, :x, :y))
  # ex = (:(=), (:tuple, :c, :d), (:tuple, (:call, :.+, :x, :y), (:call, :.+, :x, :y)))
  sym = ex.args[1] 
  expression = ex.args[2]
  @assert length(ex.args) == 2 "Only 2 args are supported."
  @assert sym isa Symbol || isexpr(sym, :ref) || isexpr(sym, :(::)) || sym.head == :tuple "Still direct or tuple assign are allowed $sym"

  assign_body = Expr[]

  init_assign_expr = create_init(init_exprs)
  process_body(expression, gen_d_sym(sym), assign_body, context, init_assign_expr)
  push_reassign_symbols!(assign_body, sym, context)

  finish_init!(ex, pullback_body, init_assign_expr, init_exprs)

  push_assignment!(pullback_body, assign_body, context)


  # ex2 = ex.args[2]
  # @show (ex2.head, ex2.args)
  return
end
handle_tuple(ex, dy, pullback_body, context, init_exprs) = begin
  exs = ex.args
  if isexpr(dy, :tuple) || isexpr(dy, :vect)
    dys = dy.args 
    for i in 1:length(exs)
      process_body(exs[i], dys[i], pullback_body, context, init_exprs)
    end
  else
    for i in 1:length(exs)
      process_body(exs[i], Expr(:ref, dy, i), pullback_body, context, init_exprs)
    end
  
  end
end
handle_broadcastassignment(ex, dy, pullback_body, context, init_exprs) = begin
  # (:+=, :y, :i2)
  # (:.+=, :y, :i2)
  op, sym, arg = ex.head, ex.args[1], ex.args[2]
  # @show dys
  dy = gen_d_sym(sym)
  reverse_ex = easypreaction(ex.head, ex, context)
  push!(pullback_body, reverse_ex)

  init_assign_expr = create_init(init_exprs)
  assign_body = Expr[]
  process_body(ex.args[2], dy, assign_body, context, init_assign_expr)

  finish_init!(ex, pullback_body, init_assign_expr, init_exprs)
  push_assignment!(pullback_body, assign_body, context)
end
handle_call(ex, dy, pullback_body, context, init_exprs) = begin
  # @show_expr ex
   # (:call, :.+, :x, :y)
  #  @show "We in :call"
  fn_symb = ex.args[1]
  fn_args = ex.args[2:end]
  # fn_symb = infer_function(fn_symb) # TODO why we need this? sum not working with this.


  res = rrule(Val(fn_symb), fn_args...; c=context)
  dys = nothing
  untupled_pullback = Expr[]

  modify_fw!(ex, init_exprs, res) # why we need fw this early?
  
  if res isa InitPullback || res isa InitFwInitPullback
    push!(untupled_pullback, res.pb_init_fn(dy))
    dys = res.pb_fn(dy)
  else
    dys = res(dy) # TODO either pick this simple solution, or the above, based if there is tmp creation needed, for easier code look.
  end
  for i in 1:length(fn_args)
    process_body(fn_args[i], dys[i], untupled_pullback, context, init_exprs)
  end
  if res isa InitFwInitPullback 
    if length(untupled_pullback) == 1
      push!(pullback_body, untupled_pullback[1])
      @show "I think it is empty pullback assigment case, TODO somehow validate, if it has effect."
    elseif length(untupled_pullback) == 0
      @assert false "Still unknown case."
    else
      unsplitable = Expr(:block, (untupled_pullback[i] for i in 1:length(untupled_pullback))...)
      push!(pullback_body, unsplitable)
    end
    # ex.head, ex.args = fw.head, fw.args
  else  
    append!(pullback_body, untupled_pullback)
  end
  return
end
handle_getfield(ex, dy, pullback_body, context, init_exprs) = begin
  sym = unwrap_sym(ex.args[1])

  @show sym
  d_sym = gen_d_sym(sym)
  @show d_sym
  if !is_sym_exists(context, d_sym)
    add_sym_to_used(context, d_sym)
    push!(pullback_body, :($d_sym = nothing))
  end
  # TODO maybe handle struct fields.
  # @assert false "OK"
end
handle_broadcast(ex, dy, pullback_body, context, init_exprs) = begin
  @assert false "When does it run... gen_d_sym have to be checked"
  # show_expr(ex)
  sym = ex.args[1]
  is_exist = is_sym_exists(context, sym)
  if !is_exist
    d_sym = gen_d_sym(sym)
    add_sym_to_used(context, sym)
    push!(pullback_body, Expr(:(=), d_sym, nothing))
  end
  return
end
get_ref_sym(sym::Symbol) = sym 
get_ref_sym(ex::Expr) = begin
  if isexpr(ex, :.) && ex.args[2] isa QuoteNode
    return nothing
  end
  @assert ex.head == :ref
  get_ref_sym(ex.args[1])
end 
change_ref_sym!(ex::Symbol, newsym) = newsym 
change_ref_sym!(ex::Expr, newsym) = begin
	unwrap = isexpr(ex.args[1], :ref) ? change_ref_sym!(ex.args[1], newsym) : newsym
	Expr(:ref, unwrap, ex.args[2:end]...)
end
handle_ref(ex, dy, pullback_body, context, init_exprs) = begin
  # ex = (:ref, :c, 1)  c[1]
  sym = get_ref_sym(ex)
  if sym === nothing
    return # no assignment to struct fields.
  end
  d_sym = gen_d_sym(sym)
  isexists = use_sym(d_sym, sym, pullback_body, init_exprs, true, context)
  d_sym_idxed = change_ref_sym!(ex,  d_sym)
  init_or_add!(pullback_body, isexists, d_sym_idxed, dy, context)
  return
end

handle_if(ex, dy, pullback_body, context, init_exprs) = begin
  init_true_false = create_init(init_exprs)
  condition = ex.args[1]
  body_true, body_false = Expr[], Expr[]

  process_body(ex.args[2], dy, body_true, context, init_true_false)
  if 3 == length(ex.args)
    process_body(ex.args[3], dy, body_false, context, init_true_false)
  end

  expr_if = 3 == length(ex.args) ? 
            Expr(ex.head, condition, to_expr_block(body_true), to_expr_block(body_false)) :
            Expr(ex.head, condition, to_expr_block(body_true))
  finish_init!(ex, pullback_body, init_true_false, init_exprs)

  push!(pullback_body, expr_if) 
end
handle_loops(iter, for_ex_body, ex, dy, pullback_body, context, init_exprs, for_type) = begin
  
  @assert iter.args[1] isa Symbol "Still only symbol iterator supported, not tuple. $iter"

  init_for_expr = create_init(init_exprs) 
  d_iter_var = gen_iter_sym(iter.args[1])

  push_iter!(context, iter)

	dy = for_type == :STD_FOR ? nothing : Expr(:ref, dy, d_iter_var)

  for_body = Expr[]
  process_body(for_ex_body, dy, for_body, context, init_for_expr)
  pop_iter!(context)
	
	if for_type == :STD_FOR
		ex.args[1] = :(($d_iter_var, $(iter.args[1])) = enumerate($(iter.args[2])))
	elseif for_type == :COMPREHENSION 
		ex.args[1].args[2] = :(($d_iter_var, $(iter.args[1])) = enumerate($(iter.args[2])))
	elseif for_type == :TYPED_COMPREHENSION
		ex.args[2].args[2] = :(($d_iter_var, $(iter.args[1])) = enumerate($(iter.args[2])))
	end
  finish_init!(ex, pullback_body, init_for_expr, init_exprs)
	
  if length(for_body)>0
    push!(pullback_body, 
					:(for ($d_iter_var, $(iter.args[1])) = Iterators.reverse(enumerate($(iter.args[2]))) 
							$(for_body...) 
						end))
  end
end
handle_for(ex, dy, pullback_body, context, init_exprs) = begin
	# (for (= i (call : 1 10)) (block #= none:1 =# (= b d)))
  # @show ("FOOR", ex.head, ex.args)
  iter = ex.args[1]
	for_ex_body = ex.args[2] 
	handle_loops(iter, for_ex_body, ex, dy, pullback_body, context, init_exprs, :STD_FOR)
  return
end
handle_comprehension(ex, dy, pullback_body, context, init_exprs) = begin
	# ex : (:comprehension, (:generator, :y (:(=), :y, :z)))
  # ex : (:comprehension, (:generator, (:call, :+, :i1, (:call, :*, :i2, :i)), (:(=), :i, :list)))
  @assert ex.args[1].head == :generator
  iter = ex.args[1].args[2]
	for_ex_body = ex.args[1].args[1]
	handle_loops(iter, for_ex_body, ex, dy, pullback_body, context, init_exprs, :COMPREHENSION)
  return
end
handle_typedcomprehension(ex, dy, pullback_body, context, init_exprs) = begin
	# ex : (:typed_comprehension, T, (:generator, :y (:(=), :y, :z)))
  @assert ex.args[2].head == :generator
  iter = ex.args[2].args[2]
	for_ex_body = ex.args[2].args[1]
	handle_loops(iter, for_ex_body, ex, dy, pullback_body, context, init_exprs, :TYPED_COMPREHENSION)
  return
end
ignore_macros = [Symbol("@show"), Symbol("@assert"), Symbol("@sizes"), Symbol("@typeof"), ]
is_zygote_ignore(ex) = begin
  isexpr(ex, :.) && ex.args[1] == :Zygote && ex.args[2] == QuoteNode(Symbol("@ignore"))
end
handle_macrocall(ex, dy, pullback_body, context, init_exprs) = begin
  # @show "MACROCALL START"
  if ex.args[1] in ignore_macros || (is_zygote_ignore(ex.args[1]))
    # @show "Skip these macros."
    return
  end
  macro_body = Expr[]
  macro_body_init = create_init(init_exprs) # It means someone else is taking care of init.

  # push!(init_exprs, :($res_sym = zero($ex)))
  process_body(ex.args[3], nothing, macro_body, context, macro_body_init)
  finish_init!(ex, pullback_body, macro_body_init, init_exprs)

  if ex.args[1] !== Symbol("@avx") && ex.args[1] !== Symbol("@show") # TODO why avx not working in reverse code?
    if length(macro_body) > 0
      push!(pullback_body, Expr(:macrocall, ex.args[1], ex.args[2], macro_body[1]))
    end
  else
    @show macro_body
    push!(pullback_body, macro_body[1])
  end
  return
end
handle_function_definition(ex, dy, pullback_body, context, init_exprs) = begin
  println("-----FUNCTION------")
  # ex = (:function, (:call, :fn, parameters),            (:block, ...))
  # ex = (:function, (:where,...(:call, :fn, parameters), (:block, ...))
  func_header, func_body = ex.args[1], ex.args[2]
  context.random += 1

    summarywalk(func_body, context)
  transform_func_symbol_to_pb!(func_header) # TODO maybe could be placed outside?
  pb_func_body = Expr(:block) # TODO maybe deepcopy?
  @assert context.random<2 "EHHHH"
  process_body(func_body, :dd_y, pb_func_body.args, context, init_exprs)
  tuple_of_args = Expr(:tuple, Tuple(gen_d_sym(s) for s in get_funcargs(func_header))...)
  push!(pb_func_body.args, tuple_of_args)
  # Meta.show_sexpr(innerfunc_body)
  pullback = Expr(:->, :dd_y, pb_func_body)  # TODO make this to the NAMED pb_function_name name, so named function!
  pullback = :(@refclosure $pullback)
  # @show pullback
  func_body.args[end] = Expr(:tuple, func_body.args[end], pullback)
  # @show ex
  # Here we add the return statement to the FUNCTION ex.
  return ex
end
summarywalk(sym::Symbol, c::EasyContext) = begin
  c.save_sym_dict[sym] += 1
end
summarywalk(ex, c::EasyContext) = begin  # TODO kw + parameter args hangling
  if (ex isa LineNumberNode) return
  elseif !(ex isa Expr) return
  elseif ex.head == :(=) && isexpr(ex.args[1], :(::))
    summarywalk(ex.args[1].args[1], c)
  elseif ex.head == :(=) && ex.args[1] isa Symbol
    summarywalk(ex.args[1], c)
  elseif ex.head == :(=) && isexpr(ex.args[1], :tuple)
    for e in ex.args[1].args
      summarywalk(e, c)
    end
  end
  for e in ex.args
    if e isa Expr
      summarywalk(e, c)
    end
  end
end
process_body(ex, dy, pullback_body, context::EasyContext, init_exprs=nothing) = begin
  if typeof(ex) <: LineNumberNode return # push!(pullback_body, ex) 
  end
  # @show ex
  # print("Stage: "); Meta.show_sexpr(ex); println(" \t {",dy,"}");
  if typeof(ex) <: Number return 
  elseif ex isa Symbol && dy === nothing  return
  elseif ex isa Symbol                    return handle_symbols(ex, dy, pullback_body, context, init_exprs)
  end
  # code sequences
  if ex.head in [:if, :elseif]            return handle_if(ex, dy, pullback_body, context, init_exprs) 
  elseif ex.head === :for                 return handle_for(ex, dy, pullback_body, context, init_exprs) 
  elseif ex.head === :comprehension       return handle_comprehension(ex, dy, pullback_body, context, init_exprs) 
  elseif ex.head === :typed_comprehension return handle_typedcomprehension(ex, dy, pullback_body, context, init_exprs) 
  elseif ex.head === :block               return for i in length(ex.args):-1:1 process_body(ex.args[i], dy, pullback_body, context, init_exprs) end
  elseif (ex.head === :(=) || ex.head === :function || ex.head === :macro) && 
    		 (isexpr(ex.args[1], :call) || (isexpr(ex.args[1], :where) && isexpr(ex.args[1].args[1], :call)))
                                          return handle_function_definition(ex, dy, pullback_body, context, init_exprs) # function definition
  elseif ex.head === :parameters          return # (call f (parameters (kw y 1)) x)
  elseif ex.head === :kw                  return # (call f x (kw y 1) (kw z 2))
  elseif ex.head === :...                 return @assert false "variadic parameters aren't supported in functions..."  # (:call, :f, (:..., :x))
  elseif ex.head === :return              return @assert false "Unimplemented thing..."
  elseif ex.head === :macrocall           return handle_macrocall(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head === :->                  return @assert false "Unimplemented lambda function, try avoid ()->... shits... :D give a fkn name to it LOL!"
  # code elements
  elseif ex.head === :(::)                return process_body(ex.args[1], dy, pullback_body, context, init_exprs)  # types are left out from the party
  elseif ex.head === :string              return nothing  # curly is left out from the party
  elseif ex.head === :curly               return nothing  # curly is left out from the party
  elseif ex.head === :. && ex.args[2] isa QuoteNode  
                                          return handle_getfield(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head === :call && ex.args[1] == :|> 
    # (call |> x sqrt) -> (call sqrt 5)
    ex.args = [ex.args[3], ex.args[2]]
    return process_body(ex,  dy, pullback_body, context, init_exprs)
  elseif ex.head === :call && ex.args[1] === :.|>
    # (call .|> x sqrt) -> (. sqrt (tuple x))
    ex.head = :.; ex.args = [ex.args[3], Expr(:tuple,ex.args[2])]
    return process_body(ex,  dy, pullback_body, context, init_exprs)
  elseif ex.head === :call                return handle_call(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head === :. && ex.args[2].head === :tuple return handle_broadcast(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head === :vect                return handle_tuple(ex, dy, pullback_body, context, init_exprs) # @assert false "Unimplemented thing..."
  elseif ex.head === :ref                 return handle_ref(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head === :tuple               return handle_tuple(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head === :$                   return @assert false "Unimplemented thing..."
  elseif ex.head === :let                 return @assert false "Unimplemented thing..."
  elseif ex.head === :(=) || ex.head === :(.=)    return handle_assignment(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head in [:.+=, :+=, :.*=, :-=, :.-=, :/=, :./=, :^=, :.^=]     return handle_broadcastassignment(ex, dy, pullback_body, context, init_exprs)
  elseif ex.head === :(<:) || ex.head === :(>:)   return @assert false "Unimplemented thing..."
  end
  println("UNHANDLED ex:")
  show_expr(ex)
  println()
  @assert false
end

sensitivity(arr::Float32) = 1f0 
sensitivity(arr::Tuple) = Tuple(sensitivity(a) for a in arr)
sensitivity(arr::Array{Float32, N}) where N = zero(arr) .+ 1f0 # TODO how to prefill it with ones?
sensitivity(arr::Vector{Array{Float32, N}}) where N = [sensitivity(a) for a in arr] 
pullback_to_grad(funcname) = begin
  pb_fn_ex = Symbol(:pb_, funcname)
  d_fn = Symbol(:d_, funcname)
  # (println("OK", ($pb_fn_ex(args...;kw...)[2]($sensitivity)));
  sensitivity = 1f0
  :($(d_fn)(args...;kw...) = begin
    val, _pb_fn = $(pb_fn_ex)(args...;kw...)
    _pb_fn(sensitivity(val))
  end )
end

mutable struct EasyCode
	easyfn::Function
	pb_easyfn::Function
end
function Base.getproperty(ecode::EasyCode, sym::Symbol)
  if sym == :d_easyfn
      return (args...;kw...) -> begin
        val, pb_fn = ecode.pb_easyfn(args...;kw...)
        pb_fn(sensitivity(val))
      end
  else
      return getfield(ecode, sym)
  end
end
# easygrad_runtime(ex) = begin

#   context = EasyContext(DefaultDict{Symbol, Number}(0), DefaultDict{Symbol, Number}(0), 
#   Stack{Symbol}(), LineNumberNode(0, ""), Main, :runtimegenerated, DefaultDict{Symbol, Number}(0), 0,
#   Stack{Union{Expr, Symbol}}())
#   # fw_fn = @RuntimeGeneratedFunction(ex)
#   fw_fn = @RuntimeGeneratedFunction(Main, ex, opaque_closures=false)
#   pb_ex = process_body(ex, 1f0, [], context)
#   # @show pb_ex
#   pb_fn = @RuntimeGeneratedFunction(Main, pb_ex, opaque_closures=false)
#   EasyCode(fw_fn, pb_fn)
# end
macro easygrad(ex, debug=:(:LIVE))
  f = Expr(:quote, ex)
  line, file = Int64(__source__.line), String(__source__.file)
  dirpath = dirname(file)
  is_fn_def = ex.head == :(=) || ex.head == :function
  esc(quote
    # file, line = $is_fn_def ?  : $EasyGrad.CodeTracking.whereis($EasyGrad.CodeTracking.@which $ex)
    funcbody = $is_fn_def ? $f : $EasyGrad.@code_expr_easy $ex
    $linefilter!(funcbody)
    funcname = $get_funcsymbol(funcbody)
    context = $EasyContext($DefaultDict{Symbol, Number}(0), $DefaultDict{Symbol, Number}(0), 
                            $Stack{Symbol}(), LineNumberNode($line, $file), $__module__, funcname, $DefaultDict{Symbol, Number}(0), 0,
                            $Stack{Union{Expr, Symbol}}())
    $is_fn_def && eval(funcbody)
    $process_body(funcbody, 1f0, [], context)
     # TODO put linenumbers back?
    $linefilter!(funcbody)
    @show funcbody
    eval(funcbody)
    # eval(:(_body = ($funcbody)))
    grad_fn = $pullback_to_grad(funcname)
    eval(grad_fn)
    if $debug != :LIVE 
      if $debug in [:DEBUG, :TEST]
        fname = "test_$(Int(round(time()*1000))).jl"
      else 
        fname = $debug
      end
      open($dirpath * "/$fname", "w") do io; print(io, funcbody) end
      @show $dirpath * "/$fname"
      include($dirpath * "/$fname"); # println("$(@__DIR__)/$fname is included!")
    end  
    funcbody
	end)
end

end

#%%
# 1. deepcopy simplification additional allocation.
# 2. 