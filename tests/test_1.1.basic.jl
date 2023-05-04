using Zygote
using InteractiveUtils
using EasyGrad: @easygrad
using EasyGrad
using Test

@show "WE sTART"
@easygrad function test_basic(x, y)
	c = x .+ y
	c[1]
end debug="../tests/test_cases_functions/generated_test_1.1.basic_gen.jl"


a,b = [2.f0], [3.f0]
@show "OKAY WE HERE"
@show d_test_basic(a, b)
@testset "Gradient check " begin
    @test all(gradient(test_basic, a, b) .≈ d_test_basic(a, b))
end

# expected_res = split("""function pb_fn(x, y)
#     #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test_basic.jl:8 =#
#     #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test_basic.jl:9 =#
#     c = x .+ y
#     #= /home/master/repo/julia-awesomeness/EasyGrad.jl/tests/test_basic.jl:10 =#
#     (c[1], #= /home/master/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:481 =# EasyGrad.@refclosure((dd_y->begin
#                     d_c = zero(c)
#                     d_c[1] = EasyGrad.rev_bc_add!(d_c[1], dd_y)
#                     begin
#                         d_x = zero(x)
#                         d_y = zero(y)
#                     end
#                     (d_x, d_y) = (EasyGrad.rev_bc_add!(d_x, d_c), EasyGrad.rev_bc_add!(d_y, d_c))
#                     (d_x, d_y)
#                 end)))
# end""", "\n")
# f = open("EasyGrad.jl/tests/test_cases_functions/generated_test_basic_gen.jl", "r")

# @testset "Source by lines" begin
#     for (i,line) in enumerate(readlines(f))
#         if line[end] == '#' || occursin("#= /home", line) continue end
#         @test expected_res[i] == line
#     end
# end
# @inferred fn(a, b)
# @inferred d_fn(a, b)
;