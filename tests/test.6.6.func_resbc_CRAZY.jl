using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using CodeTracking
# includet("../src/EasyGrad.jl")
using EasyGrad

@easygrad fn66(x) = begin
	a = x .* x .* 20
	y = sum(a)
	# y = a[1]
	y
end
@easygrad func_test(i1, i2) = begin
	s = zero(i1)
	s .+= fn66(i2)
	y = sum(s)
	y
end

a, b = [2f0, 1f0], [3f0, 1f0]

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), fn, a) .≈ d_fn66(a))
	@test all(grad(central_fdm(5, 1), func_test2, a, b) .≈ d_func_test2(a, b))
end


#%%
# println("-----EVALUATION-----")

# a, b = rand(1), rand(1)
# @show fn(a)
# @show d_fn(a)
# @show grad(central_fdm(5, 1), fn, a)
# func_test2(a, b)
# @time func_test2(a, b)
# j = grad(central_fdm(5, 1), func_test2, a, b)
# @show j
# @show d_func_test2(a, b)
# @time d_func_test2(a, b)
# 0.000005 seconds (9 allocations: 720 bytes)
;
#%%

# using BenchmarkTools
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
# using Zygote
# a, b = randn(1), randn(1)
# # @show d_fn(a)
# # @show Meta.parse(@code_string d_fn(a))
# # @btime $fn($a)
# # @btime $d_fn($a)
# # @btime $gradient($fn, $a)
# @btime $func_test2($a, $b)
# @btime $d_func_test2($a, $b)
# @btime $gradient($func_test2, $a, $b)
# # 92.460 ns (4 allocations: 384 bytes)
# # 177.269 ns (8 allocations: 672 bytes)
# # 202.157 ns (8 allocations: 688 bytes)

# ;

# end
# #%%
# using BoilerplateCvikli: @typeof
# tmp = gensym("tmp")
# @typeof tmp
# @show tmp
# Meta.show_sexpr(tmp)
# @show :($tmp = 12)
# #%%
# using BenchmarkTools
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
# using Zygote

# a, b = rand(1)[1], rand(1)[1]
# @btime $FuncTest.func_test2($a, $b)
# @btime $FuncTest.d_func_test2($a, $b)
# # @btime $gradient($func_test2_z, $a, $b)
# # #%%
# # using Zygote
# # Zygote.pullback(fn, b)[2](1)

# # #%%
# # using .EasyGrad: easygrad, infer_function
# # @show infer_function(:fn)
# # @show easygrad(infer_function(:fn), :i2)(:d_y)
# #%%
# fn(x) = begin
# 	y = x .* x * 20
# 	y
# end
# using EasyGrad
# d_func_test2_manual(i1, i2) = begin
# 	s = zero(i1)
# 	#= none:3 =#
# 	s2 = begin
# 					(tmp, pb_fn) = EasyGrad.Zygote.pullback(fn, i2)
# 					tmp
# 			end
# 	#= none:4 =#
# 	a = s .+ s2
# 	#= none:6 =#
# 	y = begin
# 					(tmp, pb_fn) = EasyGrad.Zygote.pullback(sum, a)
# 					tmp
# 			end
# 	#= none:7 =#
# 	y
# 	d_y = 1.0f0
# 	tmp2 = pb_fn(d_y)
# 	@show tmp2
# 	d_a = tmp2[1]
# 	d_s = deepcopy(d_a)
# 	d_s2 = deepcopy(d_a)
# 	tmp2 = pb_fn(d_s2)
# 	d_i2 = tmp2[1]
# 	d_i1 = zero(d_s)
# 	(d_i1, d_i2)
# end
# d_func_test2_manual(a, b)
# #%%
# using EasyGrad
# fn(x) = begin
# 	y = x .* x * 20
# 	y
# end
# manual2(i1, i2) = begin
# 	s = zero(i1)
# 	s2 = begin
# 					(var"##tmp#337", var"##pb#338") = EasyGrad.Zygote.pullback(fn, i2)
# 					var"##tmp#337"
# 			end
# 	a = s .+ s2
# 	y = begin
# 					(var"##tmp#334", var"##pb#335") = EasyGrad.Zygote.pullback(sum, a)
# 					var"##tmp#334"
# 			end
# 	(y, (dd_y->begin
# 							d_y = deepcopy(dd_y)
# 							var"##pb_tmp#336" = var"##pb#335"(d_y)
# 							d_a = var"##pb_tmp#336"[1]
# 							d_s = deepcopy(d_a)
# 							d_s2 = deepcopy(d_a)
# 							var"##pb_tmp#339" = var"##pb#338"(d_s2)
# 							d_i2 = var"##pb_tmp#339"[1]
# 							d_i1 = zero(d_s)
# 							(d_i1, d_i2)
# 					end))
# end
# a, b = randn(1), randn(1)
# manual2(a, b)[2](1f0)
# #%%
# f = () -> 1
# f2() = 1
# @show f isa Function
# @show f2 isa Function

