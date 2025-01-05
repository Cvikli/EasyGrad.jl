using Revise
using Test
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
using FiniteDifferences
using EasyGrad

@easygrad for_pb_func_test(i1, i2) = begin
	list = 5:105
	y = [0f0 for i in list]
	for i in 1:length(list)
		y[i] += sum(i1) + i2
	end
	y2=sum(y)
  y2
end debug="test_cases_functions/generated_test.3.6.for_pb_func.jl"

a, b = 2f0, 3f0

@show grad(central_fdm(5, 1), for_pb_func_test, a, b)
@show d_for_pb_func_test(a, b)
@testset "Gradient check " begin
	@test all(grad(central_fdm(5, 1), for_pb_func_test, a, b) .≈ d_for_pb_func_test(a, b)) 
end

#%%
# println("-----EVALUATION-----")
# 
# a, b = 2f0, 3f0
# for_comp_test(a, b)
# @show d_for_comp_test(a, b)
# @time for_comp_test(a, b)
# @show @time d_for_comp_test(a, b)
# j = grad(central_fdm(5, 1), for_comp_test, a, b)
# @show j
# @time d_for_comp_test(a, b)
# # 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
# @show d_for_comp_test(a, b)
# ;
# 1 nested version                              pipa...
# 2 multiple iteration... for (a,b,c) in list   progressing...
# 3 assign...																		progressing...
# 4 combining the 3...                          should be easy after others work... one check necessary...
# 5 list comprehension                          progressing...
# 6 function pullback in for                    progressing...
# 7 enumerate(enumerate(1:20))                  pipa...
# 8 broadcast is SAME like	            				= func pullback...

# ############# function pullback in for
# var"##pb#977" = Vector{Function}(undef, length(list))
# # var"##pb#977" = Function[undef for i in 1:length(list)]
# for (_i_i, i) = enumerate(list)
# 	y[i] += begin
# 							(var"##tmp#976", var"##pb#977"[_i_i]) = EasyGrad.Zygote.pullback(sum, i1)
# 							var"##tmp#976"
# 					end + i2
# end

# for (_i_i, i) = reverse(enumerate(list))
# 	y[i] -= sum(i1) + i2
# 	begin
# 			var"##pb_tmp#978" = var"##pb#977"[_i_i](d_y[i])
# 			EasyGrad.@add! d_i1 var"##pb_tmp#978"[1]
# 	end
# 	EasyGrad.@add! d_i2 d_y[i]
# end

# ############# list comprehension function pullback in for
# [sum(x) for i in 1:10]
# # derivate:


# ############# nested
# list = 1:k

# # allokáció i és j-vel
# var"##pb#977" = [Function[undef for i in 1:length(list1)] for i in 1:length(list2)]

# s_x = Array{typeof(x),1}(undef, length(list1))
# s_y = Array{Function,2}(undef, length(list), length(list2))
# for i in list1
# 	s_x[i] = y
# 	for j in list2
# 		s_y[i, j] = y
# 		# s_y[i][j] = y
# 		y=x*y+5
# 	end
# end


# ############# assign
# s_y = zero(size(length(10:100)))
# for (_i_i,i) in enumerate(10:100)
# 	s_y[_i_i] = y
# 	y=x*y+5
# end

# for (_i_i, i) in Reverse(enumerate(10:100))
# 	y = s_y[_i_i]
# 	dx = ∑!(dx, y * dy) 
# end
# #%%
# var"##pb#315" = Array{Function,1}(undef, length(list))
# for (_i_i,i) = enumerate(list)
# 	y[i] += begin
# 						(var"##tmp#314", var"##pb#315"[_i_i]) = EasyGrad.Zygote.pullback(sum, i1)
# 						var"##tmp#314"
# 					end + i2
# end

# begin
# end
# for (_i_i, i) = Iterators.reverse(enumerate(list))
# 	begin
# 		var"##pb_tmp#316" = var"##pb#315"[_i_i](d_y[i])
# 		@add! d_i1 var"##pb_tmp#316"[1]
# 	end
# end
# #%%
# using BenchmarkTools
# import Base.Iterators: Reverse
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0

# for_test1(l, a) = for i in reverse(l) a += 1 end
# for_test2(l, a) = for i in reverse(l) a += sum(i) end
# for_test4(l, a) = for i in Reverse(l) a += sum(i) end
# for_test4e(l, a) = for (idx,i) in Reverse(enumerate(l)) a += sum(i) end
# for_test3(l, a) = for i in reverse(1:length(l)) a += sum(l[i]) end
# for_test3r(l, a) = for (idx,i) in reverse(enumerate(1:length(l))) a += sum(l[i]) end
# test()=begin
# 	l = collect([randn(10,10) for i in 1:100000])
# 	a = 2
# 	# @btime for_test1($l, $a)
# 	@btime for_test2($l, $a)
# 	@btime for_test4($l, $a)
# 	@btime for_test4e($l, $a)
# 	@btime for_test3($l, $a)
# 	# @btime for_test3r($l, $a)
# 	l = 1:100000
# 	reverse(l)
# 	# @btime for_test1($l, $a)
# end
# test()
# #%%
# @edit Iterators.reverse([10, [10]])
# #%%
# using BenchmarkTools
# import Base.Iterators: Reverse
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
# for_test1(l, a) = for (i,j) in (l) a += 1 end
# for_test2(l, a) = for (_i, (i,j)) in enumerate(l) a += 1 end
# test()=begin
# 	l = collect([([3, 2],7) for i in 1:10000])
# 	a = 2
# 	@btime for_test1($l, $a)
# 	@btime for_test2($l, $a)
# end
# test()