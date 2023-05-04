using Revise
using Test
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using FiniteDifferences
using EasyGrad

# ENV["JULIA_DEBUG"] = EasyGrad

@easygrad where_type_test(i1::Float32, i2::Array{Float32, N}) where {N} = begin
	a::Float32 = i1 * 2 + i2[1]
	a
end 


a, b = 2f0, [3f0]
# pb_where_type_test(a, b)
# @easygrad where_type_test(a, b) debug="../tests/test_cases_functions/generated_test.7.2.where_type.jl"

@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), where_type_test, a, b) .≈ d_where_type_test(a, b))
end


#%%
# where_type_test(a, b)
# println("-----EVALUATION-----")

# where_type_test(a, b)
# @show d_where_type_test(a, b)
# @time where_type_test(a, b)
# @show @time d_where_type_test(a, b)
# j = grad(central_fdm(5, 1), where_type_test, a, b)
# @show j
# @time d_where_type_test(a, b)
# # 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
# @show d_where_type_test(a, b)
# ;

# #%%
# asdf = [2f0]
# fa(x::Union{Vector{Float32}, Nothing}) = begin
# 	eh::Vector{Float32} = asdf
# 	eh2 = deepcopy(eh)
# 	(x, eh2)
# end
# # @code_warntype fa(nothing)
# # @code_warntype fa([2f0])
# @code_warntype fa([2.0f0])
# fa([2.0f0])

# #%%
# where2()
