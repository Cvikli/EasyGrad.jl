using Revise
using SHA
using SyntaxTree: linefilter!

save_load_expression(ex::Expr; fname::String="") = begin
  out_ex = string(linefilter!(ex))
  fname == "" && (fname = bytes2hex(sha1(out_ex)) * ".jl")
  # println("$(@__DIR__)/rgf/$fname")
  !isdir("$(@__DIR__)/rgf") && mkdir("$(@__DIR__)/rgf")
  open("$(@__DIR__)/rgf/$fname","w") do io
    write(io, out_ex)
  end
  includet("rgf/$fname")
  println("$(ex.head) $(ex.args[1]) loaded from rgf/$fname ")
end

# ex = :(function x(sws,bv,d,s,c) 
# (3,5) 
# end)
# save_load_expression(ex)
# ;

