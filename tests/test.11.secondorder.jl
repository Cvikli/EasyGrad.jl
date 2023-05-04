using Revise
using RelevanceStacktrace
using Boilerplate: @typeof, @sizes
using EasyGrad
using Zygote


@easygrad sec_order_func_test(x) = begin
	y = x * x
	y
end debug="../tests/test_cases_functions/generated_test.11.secondorder.jl"


a = 2f0

@testset "Gradient check " begin
	@test all(gradient(sec_order_func_test, a) .≈ d_sec_order_func_test(a))
end
