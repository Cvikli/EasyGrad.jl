using Revise
using RelevanceStacktrace
using DataStructures
using BoilerplateCvikli: @typeof, @sizes
# includet("../src/EasyGrad.jl")
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad


@easygrad if_test(i1, i2) = begin
	s = i1
	if any(i1 .> 1.)
		s += i1 .* i2
	else
		s += i2 .+ i1
	end
	# s
	y = s[1]
	y
end

println("-----EVALUATION-----")

a, b = [2.2f0], [3.3f0]
a, b = rand(Float32, 1), rand(Float32, 1)
@show a, b
if_test(a, b)
@show d_if_test(a, b)
@time if_test(a, b)
@show @time d_if_test(a, b)
using FiniteDifferences
j = grad(central_fdm(10, 1), if_test, a, b)
@show j
@time d_if_test(a, b)
# 0.000006 seconds (13 allocations: 1008 bytes)
@show d_if_test(a, b)
;
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote

a, b = rand(Float32, 1), rand(Float32, 1)
@btime if_test($a, $b)
@btime d_if_test($a, $b)
@btime gradient($if_test, $a, $b)
# 81.494 ns (4 allocations: 320 bytes)
# 312.275 ns (16 allocations: 1.12 KiB)
# 6.419 μs (48 allocations: 2.20 KiB)
#%%
@show LineNumberNode(1, "none").line
@show LineNumberNode(1, "none").line
#%%
pb_if_test_man(i1, i2) = begin
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/5.if.test.jl:10 =#
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/5.if.test.jl:11 =#
	s = i1
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/5.if.test.jl:12 =#
	if any(i1 .> 1.0)
			#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/5.if.test.jl:13 =#
			s += i1 .* i2
	else
			#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/5.if.test.jl:15 =#
			s += i2 .+ i1
	end
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/5.if.test.jl:18 =#
	y = s[1]
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/5.if.test.jl:19 =#
	(y, #= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:552 =# EasyGrad.@refclosure((dd_y->begin
									d_y = dd_y
									d_s = (zero)(s)
									d_s[1] = (EasyGrad).rev_bc_add!(d_s[1], d_y)
									begin
											d_i1 = (EasyGrad.Zero)(i1)
											d_i2 = (EasyGrad.Zero)(i2)
									end
									if any(i1 .> 1.0)
											s -= i1 .* i2
											d_i1 = (EasyGrad).rev_bc_add!(d_i1, i2 .* d_s)
											d_i2 = (EasyGrad).rev_bc_add!(d_i2, i1 .* d_s)
									else
										@show d_i2
										@show d_i1
										@show d_s
										s -= i2 .+ i1
											d_i2 = (EasyGrad).rev_bc_add!(d_i2, d_s)
											d_i1 = (EasyGrad).rev_bc_add!(d_i1, d_s)
									end
									d_i1 = (EasyGrad).rev_bc_add!(d_i1, d_s)
									(d_i1, d_i2)
							end)))
end
pb_if_test_man(a, b)[2](1f0)
# @btime pb_if_test_man($a, $b)[2](1f0)
#%%
using FillArrays
a = Fill(1.f0, 2)
# Base.setindex!(A::Fill{T,N}, val, inds::Vararg{Int,N}) where {T,N} = (ar = Array(A); ar[inds...] = val;println(ar);  ar)
# b = [2.f0, 0f0]
# @edit a + b
# res = a[1] = 2.f0
# @show res
a