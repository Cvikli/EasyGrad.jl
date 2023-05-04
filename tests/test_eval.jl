using FiniteDifferences
using InteractiveUtils
using CodeTracking
using EasyGrad: @easygrad
using EasyGrad
using Test
fnnn(x) = begin 6. + x end
macro ok(x)
    eval(x)
end
test = @ok :(fn2n(x) = begin 6. + x end)
# @code_warntype test(7)
fn() = begin
    # fn24n(x) = begin 6. + x end
    q=5
    # exp = :(6+6;
    # 6. + :x)
    # println(eval(exp))
    o= Meta.show_sexpr(Meta.parse("x-> 7+x"))
    z = eval(Expr(:->, :x, (:call, :+, 6., :x))) 
    println(z)
    println(z(4.5))
    p = z(4.5+5) +3.1
end
fn()
@code_warntype fn()
;