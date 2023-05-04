module EasyStructs
using Parameters
using DataStructures

@with_kw mutable struct EasyContext
  symbol_dict::DefaultDict{Symbol, Number}
  save_sym_dict::DefaultDict{Symbol, Number}
  ignored_symbols::Stack{Symbol} # to ignore some grads.
  # unique_counter::Int = 0
  source::LineNumberNode
  call_module::Module
  fn_name::Symbol
  gen_fn_counter::DefaultDict{Symbol, Number}
  random::Int=0
  iters::Stack{Union{Expr, Symbol}}=Stack{Union{Expr, Symbol}}()
end
mutable struct InitFwInitPullback
  fw_init::Union{Expr, Nothing}
  fw::Expr
  pb_init_fn::Function
  pb_fn::Function
end
mutable struct InitPullback
  pb_init_fn::Function
  pb_fn::Function
end
mutable struct EasyInit
  fw::Vector{Expr}
  bw::Vector{Expr}
end
struct EasyZero{T,N} <: AbstractArray{T,N}
  size::Vector{Int}
end

ignore_symbol!(ec::EasyContext, sym) = push!(ec.ignored_symbols, sym)
pop_ignore_symbol!(ec::EasyContext) =  pop!(ec.ignored_symbols)
get_s_sym(ec::EasyContext, sym::Symbol) = ec.save_sym_dict[sym]-1>1 ? Symbol(:s, ec.save_sym_dict[sym], :_, sym) : ec.save_sym_dict[sym]-1>0 ? Symbol(:s_, sym) : nothing
# get_s_sym(sym::Symbol, ec::EasyContext) = ec.save_sym_dict[sym] > 1 ? Symbol(:s, ec.save_sym_dict[sym], :_, sym) : nothing
dec_s_sym!(ec::EasyContext, sym::Symbol) = ec.save_sym_dict[sym] -= 1
is_s_sym_used(ec::EasyContext, sym) = haskey(ec.save_sym_dict, sym) && ec.save_sym_dict[sym]>0
is_sym_exists(ec::EasyContext, sym::Symbol) = ec.symbol_dict[sym] > 0
is_sym_ignored(ec::EasyContext, sym) = sym in ec.ignored_symbols

add_sym_to_used(ec::EasyContext, sym::Symbol) = ec.symbol_dict[sym] += 1
add_sym_to_used(ec::EasyContext, ex::Expr) = begin 
  @assert ex.head == :ref "Only indexing is supported."
  add_sym_to_used(ec, ex.args[1])
end

push_iter!(c::EasyContext, ex::Expr) = begin
  ignore_symbol!(c, ex.args[1])
  push!(c.iters, ex)
end
pop_iter!(c::EasyContext) = begin
  pop_ignore_symbol!(c)
  pop!(c.iters)  
end

gen_fn_sym(ec::EasyContext, str::String) = gen_fn_sym(ec, Symbol(str))
gen_fn_sym(ec::EasyContext, sym::Symbol) = (ec.gen_fn_counter[sym]+=1; ec.gen_fn_counter[sym]>1 ? 
Symbol(sym, :_, ec.gen_fn_counter[sym]) : sym)
gen_iter_sym(sym::Symbol) = Symbol(:_i_, sym)

get_iter_fw_init(c::EasyContext, pb_sym, pb_fn) = begin
  pb_iters_converted = get_iterators_to_first(pb_fn, c.iters)
  all_lengths = [:(length($(ex.args[2]))) for ex = c.iters]
  dims = length(c.iters)
  length(c.iters)>0 ? :($pb_sym = Array{typeof($pb_iters_converted[2]), $dims}(undef, $(all_lengths...),)) : nothing
end
get_context_indexed(c::EasyContext, sym) = begin
  all_idxs = [gen_iter_sym(ex.args[1]) for ex = c.iters]
  length(c.iters)>0 ? Expr(:ref, sym, all_idxs...) : sym
end

# TODO it is not easygrad related:
get_iterators_to_first(ex, iters) = begin
  for iterpack in iters
    ex = convert_iters_to_first(ex, iterpack.args[1], iterpack.args[2])
  end
  ex
end
convert_iters_to_first(sym::Symbol, iter, list) = begin
  sym == iter ? :(first($list)) : sym
end
convert_iters_to_first(ex::QuoteNode, iter, list) = begin
  ex
end
convert_iters_to_first(ex::Union{LineNumberNode, Number, Nothing}, iter, list) = begin
  ex
end
convert_iters_to_first(ex::Expr, iter, list) = begin
  Expr(ex.head, map(e -> convert_iters_to_first(e, iter, list), ex.args)...)
end

end