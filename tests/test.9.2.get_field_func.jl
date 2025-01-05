using Revise
using Test
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using FiniteDifferences
using EasyGrad

# ENV["JULIA_DEBUG"] = EasyGrad

struct CellFn
	fn
	pb_fn
end

@easygrad struct_test(s::MyStruct) = begin
	a = s.fn(1f0)
	a
end 


a = MyStruct((a) -> a, () -> 1f0)
pb_struct_test(a)
# @easygrad where_type_test(a, b) debug="../tests/test_cases_functions/generated_test.7.2.where_type.jl"

@testset "Gradient check " begin
	@test all((nothing,) .== d_struct_test(a))
end
# @testset "Gradient check pro" begin
	# @test all(grad(central_fdm(5, 1), struct_test, a) .≈ d_struct_test(a))
# end

