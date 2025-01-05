using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using CodeTracking
# includet("../src/EasyGrad.jl")
using EasyGrad

@easygrad fn68(x) = x

@easygrad func_test(i1, fn_gen) = begin
	s = zero(i1)
	s2 = s + fn_gen(i1)
	# s += false ? fn_gen * 0f0 : 0f0
	s2
end

a = 2f0

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), func_test, a, fn68)[1] .≈ d_func_test(a, fn68)[1])
end
