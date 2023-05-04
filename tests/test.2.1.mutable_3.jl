using FiniteDifferences
using InteractiveUtils
using EasyGrad
using Test


@easygrad fn6(i1, i2) = begin
  y = i1 .* i2
  y .+= y .* 3
  # y .*= 0.0000f0

  sum(y)
  # z=y
  # z
end  debug="../tests/test_cases_functions/generated_test.2.1.mutable_3.jl"


a,b = [2.f0], [3.f0]
# a, b = randn(Float32, 21, 4), randn(Float32, 21,4)
# @show grad(central_fdm(5, 1), fn6, a, b)
# @show d_fn6(a, b)

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), fn6, a, b) .≈ d_fn6(a, b)) 
end

#%%
# @__FILE__
# "$(@__DIR__)/test_cases_functions/2.mutable_3.test.gen.jl"
# PROGRAM_FILE

# pb_fn6(i1, i2) = begin
#   #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.2.mutable_3.jl:9 =#
#   #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.2.mutable_3.jl:10 =#
#   y = i1 .* i2
#   #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.2.mutable_3.jl:11 =#
#   y .+= y .* 2
#   #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.2.mutable_3.jl:12 =#
#   y .+= y
#   #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test.2.mutable_3.jl:13 =#
#   (y, #= /home/master/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:481 =# EasyGrad.@refclosure((dd_y->begin
#                   d_y = deepcopy(dd_y)
#                   d_y .+= dd_y
#                   # d_y = deepcopy(d_y)
#                   d_y .+= dd_y .* 2
#                   # d_y = 2 .* d_y
#                   begin
#                       d_i1 = zero(i1)
#                       d_i2 = zero(i2)
#                   end
#                   (d_i1, d_i2) = (EasyGrad.rev_bc_add!(d_i1, i2 .* d_y), EasyGrad.rev_bc_add!(d_i2, i1 .* d_y))
#                   (d_i1, d_i2)
#               end)))
# end
# # 18,12
# pb_fn6(a,b)[2]([1.f0])
# # pb_fn6(a,b)[1]