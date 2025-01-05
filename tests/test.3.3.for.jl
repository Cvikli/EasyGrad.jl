using Revise
using Test
using LoopVectorization
using BoilerplateCvikli: @typeof, @sizes

using FiniteDifferences

using EasyGrad


@easygrad for_test(i1, i2) = begin
  y = i1
	list = 1:100
	for i in list
		y .+= i2
	end
  a = y[1]
	a
end debug="test_cases_functions/generated_test.3.3.for_avx.jl"

a, b = [2f0], [3f0]
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), for_test, a, b) .≈ d_for_test(a, b)) 
end

#%%
# for_test(a, b)
# @test (@elapsed for_test(a, b)) < 0.00001
# d_for_test(a, b)
# # @show @elapsed d_for_test(a, b)
# @test (@elapsed d_for_test(a, b)) < 0.0003
# @test (@allocated d_for_test(a, b)) < 9000  # TODO ezt minimalizálni majd
# j = grad(central_fdm(5, 1), for_test, a, b)
# @test j ≈ d_for_test(a, b)
# @time d_for_test(a, b)
# @show d_for_test(a, b)
;