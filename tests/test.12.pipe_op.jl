using Revise
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad
using Zygote
using Test
using FiniteDifferences

incre(a) = 2 .* a + 2.f0
@easygrad pipe_func_test(i1, i2) = begin
	s = zero(i1)
	a = s .+ i1 .+ i2
	y = a |> sum
	z = y |> incre  |> incre 
	z
end debug="../tests/test_cases_functions/generated_test.12.pipe_op.jl"


a, b = [2f0], [3f0]
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), pipe_func_test, a, b) .≈ d_pipe_func_test(a,b))
end
                      #     d_y = dd_y
                      #     d_a = (EasyGrad.e_zero)(a)
                      #     begin
                      #         var"##pb_tmp#876" = var"##pb#875"(d_y)
                      #         EasyGrad.@add! d_a var"##pb_tmp#876"[1]
                      #     end
                      #     begin
                      #         d_s = (EasyGrad.e_zero)(s)
                      #         d_i1 = (EasyGrad.e_zero)(i1)
                      #         d_i2 = (EasyGrad.e_zero)(i2)
                      #     end
                      #     EasyGrad.@addt! (d_s, d_i1, d_i2) (d_a, d_a, d_a)
                      #     EasyGrad.@add! d_i1 zero(d_s)
                      #     (d_i1, d_i2)
                      # end)))