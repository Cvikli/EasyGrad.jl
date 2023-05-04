module ExprHelpers
import Base.Meta: show_sexpr, isexpr


# get_pb_sym(sym::Symbol, ec::EasyContext) = (ec.unique_counter += 1; Symbol(:pb, ec.unique_counter, :_, sym))
# get_pb_sym(ex::Expr, ec::EasyContext) = (println("checkanddeelte", ex); get_pb_sym(ex, ec))
get_pb_sym(sym::Symbol) = (Symbol(:pb_, sym))

transform_func_symbol_to_pb!(ex::Expr) = begin
  if ex.head == :where  # (:where, (:call, :fnname, parameters))
    ex = ex.args[1] # just open up the where bracket
  end
  pb_fn = get_pb_sym(ex.args[1])
  ex.args[1] = pb_fn
end
get_funcsymbol(ex::Function) = begin
  Symbol(ex)
end

antiwherehead(ex::Symbol) = ex
antiwherehead(ex::Expr) = ex.head == :where ? ex = ex.args[1].head : ex.head
get_funcsymbol(ex::Expr) = begin
  @assert ex.head == :(=) || ex.head == :function "Unhandled function shape."
  ex = ex.args[1]
  if ex.head == :where
    ex = ex.args[1] # just open up the where bracket
  end
  ex.args[1]
end
get_funcargs(fn_header::Expr) = begin
  if isexpr(fn_header, :where)  # (:where, (:call, :fnname, parameters))
    return get_funcargs(fn_header.args[1]) # just open up the where bracket
  elseif isexpr(fn_header, :call)
    # TODO maybe check kw args cases.
    return [e for e in fn_header.args[2:end] if !isexpr(e, :parameters) && !isexpr(e, :kw)]
  else
    @assert false "Unhandled function header."
  end
end
show_expr(ex) = (Meta.show_sexpr(ex); println())
macro show_expr(ex)  
  esc(quote
    Meta.show_sexpr($ex)
    println() 
  end)
end
end