using Revise
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

@easygrad square(x) = x .* x

@easygrad bcarrow_test(x) = begin
	y = x .|> square
	y[1]
end

println("-----EVALUATION-----")

a = [2f0]
@show bcarrow_test(a)
@time bcarrow_test(a)


d_bcarrow_test(a)
@time d_bcarrow_test(a)
@time d_bcarrow_test(a)

using Zygote
r = gradient(bcarrow_test, a)
@time gradient(bcarrow_test, a)
;