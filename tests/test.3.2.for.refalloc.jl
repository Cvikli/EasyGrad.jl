using Revise
using FiniteDifferences
using Boilerplate: @typeof, @sizes
using EasyGrad

@easygrad for_test(i1, i2) = begin
  y = i1
	list = 3:100
	for i in 3:length(list)
		y += i2
	end
  # y = y[1]
  y
end  debug="test_cases_functions/generated_test.3.1.for.refalloc.jl"

# println("-----EVALUATION-----")

a, b = 2f0, 3f0
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), for_test, a, b) .≈ d_for_test(a, b)) 
end

