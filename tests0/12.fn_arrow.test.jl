using Revise
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

@easygrad square(x) = x .* x

@easygrad fn_arrow_test(x) = begin
	y = x |> square
	y[1]
end

println("-----EVALUATION-----")

a = [2f0]
@show fn_arrow_test(a)
@time fn_arrow_test(a)


d_fn_arrow_test(a)
@time d_fn_arrow_test(a)
@time d_fn_arrow_test(a)

using Zygote
r = gradient(fn_arrow_test, a)
@time gradient(fn_arrow_test, a)
;