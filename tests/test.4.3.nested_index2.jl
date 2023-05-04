# supporting nested indexing.
# arr[1][2]
# arr[1][i]

using Revise
using RelevanceStacktrace
using DataStructures
using LoopVectorization
using Boilerplate: @typeof, @sizes
using EasyGrad
using FiniteDifferences

@easygrad nested_indexing_test(i1, i2) = begin
  y = i1
	for i in 1:16
		y += i2[1, i]
	end
  y
end debug="../tests/test_cases_functions/generated_test.4.indexing.jl"

a, b = 2f0, randn(Float32, 2, 16)

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), nested_indexing_test, a, b) .≈ d_nested_indexing_test(a, b)) 
end

@code_warntype d_nested_indexing_test(a, b)