using Revise
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad


@easygrad func_test(x) = begin
	y = x * x
	y
end


@show d_func_test(2f0)
using Zygote
gradient(a -> d_func_test(a)[1], 2f0)