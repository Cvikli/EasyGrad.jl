using Revise
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using CodeTracking
# includet("../src/EasyGrad.jl")
using EasyGrad

@easygrad fn(x) = begin
	y = sum(x)
	y
end
@easygrad func_test(i1, i2) = begin
	s = zero(i1)
	s2 = s .+ fn(i2)
	# s .+= fn(i2)
	# s2 = fn(i2)
	# s .+= s2
	# a = s
	# y = sum(a)
	y = sum(s2)
	y
end

println("-----EVALUATION-----")
pb_fn([1f0])
# a, b = [2f0], [3f0]
a, b = rand(Float32, 2), rand(Float32, 2)
func_test(a, b)
@show d_func_test(a, b)
@time func_test(a, b)
@show d_func_test(a, b)
using FiniteDifferences
j = grad(central_fdm(5, 1), func_test, a, b)
@show j
@time d_func_test(a, b)
# 0.000005 seconds (9 allocations: 720 bytes)
@show d_func_test(a, b)
;

#%%
using Boilerplate: @typeof
tmp = gensym("tmp")
@typeof tmp
@show tmp
Meta.show_sexpr(tmp)
@show :($tmp = 12)
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
using Zygote

a, b = rand(1)[1], rand(1)[1]
@btime $FuncTest.func_test($a, $b)
@btime $FuncTest.d_func_test($a, $b)
# @btime $gradient($func_test_z, $a, $b)
# #%%
# using Zygote
# Zygote.pullback(fn, b)[2](1)

# #%%
# using .EasyGrad: easygrad, infer_function
# @show infer_function(:fn)
# @show easygrad(infer_function(:fn), :i2)(:d_y)
#%%
fn(x) = begin
	y = x .* x * 20
	y
end
using EasyGrad
d_func_test_manual(i1, i2) = begin
	s = zero(i1)
	#= none:3 =#
	s2 = begin
					(tmp, pb_fn) = EasyGrad.Zygote.pullback(fn, i2)
					tmp
			end
	#= none:4 =#
	a = s .+ s2
	#= none:6 =#
	y = begin
					(tmp, pb_fn) = EasyGrad.Zygote.pullback(sum, a)
					tmp
			end
	#= none:7 =#
	y
	d_y = 1.0f0
	tmp2 = pb_fn(d_y)
	@show tmp2
	d_a = tmp2[1]
	d_s = deepcopy(d_a)
	d_s2 = deepcopy(d_a)
	tmp2 = pb_fn(d_s2)
	d_i2 = tmp2[1]
	d_i1 = zero(d_s)
	(d_i1, d_i2)
end
d_func_test_manual(a, b)
#%%
using EasyGrad
fn(x) = begin
	y = x .* x * 20
	y
end
manual2(i1, i2) = begin
	s = zero(i1)
	s2 = begin
					(var"##tmp#337", var"##pb#338") = EasyGrad.Zygote.pullback(fn, i2)
					var"##tmp#337"
			end
	a = s .+ s2
	y = begin
					(var"##tmp#334", var"##pb#335") = EasyGrad.Zygote.pullback(sum, a)
					var"##tmp#334"
			end
	(y, (dd_y->begin
							d_y = deepcopy(dd_y)
							var"##pb_tmp#336" = var"##pb#335"(d_y)
							d_a = var"##pb_tmp#336"[1]
							d_s = deepcopy(d_a)
							d_s2 = deepcopy(d_a)
							var"##pb_tmp#339" = var"##pb#338"(d_s2)
							d_i2 = var"##pb_tmp#339"[1]
							d_i1 = zero(d_s)
							(d_i1, d_i2)
					end))
end

manual2(a, b)[2](1f0)
@btime manual2($a, $b)[2](1f0)
#%%
pb_func_test_gen(i1, i2) = begin
	s = zero(i1)
	s2 = begin
					(var"##tmp#301", var"##pb#302") = EasyGrad.Zygote.pullback(fn, i2)
					# (var"##tmp#301", var"##pb#302") = pb_fn(i2)
					var"##tmp#301"
			end
	a = s .+ s2
	y = begin
					(var"##tmp#298", var"##pb#299") = EasyGrad.Zygote.pullback(sum, a)
					var"##tmp#298"
			end
	(y, (dd_y->begin
			# d_y = zero(y)
			# d_y = (EasyGrad).rev_bc_add!(d_y, dd_y)
			d_y = deepcopy(dd_y)

			var"##pb_tmp#300" = var"##pb#299"(d_y)
			d_a = var"##pb_tmp#300"[1]
			# d_a = zero(a)
			# d_a = (EasyGrad).rev_bc_add!(d_a, var"##pb_tmp#300"[1])
			# d_s = Zeros(size(s)...)
			# d_s2 = Zeros(size(s2)...)
			# d_s2 = zero(s2)
			# (d_s, d_s2) = ((EasyGrad).rev_bc_add!(d_s, d_a), (EasyGrad).rev_bc_add!(d_s2, d_a))
			# (d_s, d_s2) = deepcopy(d_a), deepcopy(d_a)
			d_s = deepcopy(d_a)
			d_s2 = deepcopy(d_a)
			# @show d_s2
			# @show d_s
			var"##pb_tmp#303" = var"##pb#302"(d_s2)
			# @show var"##pb_tmp#303"
			# d_i2 = zero(i2)
			# (EasyGrad).rev_bc_add!(d_i2, var"##pb_tmp#303"[1])
			d_i2 = var"##pb_tmp#303"[1]
			# d_i1 = zero(i1)
			# d_i1 = (EasyGrad).rev_bc_add!(d_i1, zero(d_s))
			d_i1 = zero(d_s)
			(d_i1, d_i2)
	end))
end
pb_func_test_gen(a, b)
@btime pb_func_test_gen($a, $b)[2](1f0)
#%%
pb_func_test_man2(i1, i2) = begin
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/6.func2.test.jl:16 =#
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/6.func2.test.jl:17 =#
	s = zero(i1)
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/6.func2.test.jl:18 =#
	s2 = begin
					(var"##tmp#1148", var"##pb#1149") = EasyGrad.Zygote.pullback(fn, i2)
					var"##tmp#1148"
			end
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/6.func2.test.jl:20 =#
	a = s .+ s2
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/6.func2.test.jl:22 =#
	y = begin
					(var"##tmp#1145", var"##pb#1146") = EasyGrad.Zygote.pullback(sum, a)
					var"##tmp#1145"
			end
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests0/6.func2.test.jl:24 =#
	(y, #= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:522 =# ((dd_y->begin
									d_y = (EasyGrad.Zero)(y)
									d_y = (EasyGrad).rev_bc_add!(d_y, dd_y)
									d_a = (EasyGrad.Zero)(a)
									begin
											var"##pb_tmp#1147" = var"##pb#1146"(d_y)
											#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:318 =#
											d_a = (EasyGrad).rev_bc_add!(d_a, var"##pb_tmp#1147"[1])
									end
									begin
											d_s = (EasyGrad.Zero)(s)
											d_s2 = (EasyGrad.Zero)(s2)
									end
									(d_s, d_s2) = ((EasyGrad).rev_bc_add!(d_s, d_a), (EasyGrad).rev_bc_add!(d_s2, d_a))
									begin
											var"##pb_tmp#1150" = var"##pb#1149"(d_s2)
											#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:318 =#
											d_i2 = (EasyGrad.Zero)(i2)
											d_i2 = (EasyGrad).rev_bc_add!(d_i2, var"##pb_tmp#1150"[1])
											# d_i2 += var"##pb_tmp#1150"[1]
											# d_i2 = var"##pb_tmp#1150"[1]
										end
									d_i1 = (EasyGrad.Zero)(d_s)
									# d_i1 = (EasyGrad).rev_bc_add!(d_i1, EasyGrad.Zero(d_s))
									(d_i1, d_i2)
							end)))
end
pb_func_test_man2(a, b)[2](1f0)
@btime pb_func_test_man2($a, $b)[2](1f0)
;

#%%
using FillArrays
@show zeros(Float32, 2)
b = Fill([1f0, 1f0], 2)
@show b
@typeof zeros(Float32, 2)
@typeof b
sum!(zeros(Float32, 2), b, init=false)
#%%
pb_fn2(x) = begin
	y = begin
					(var"##tmp#467", var"##pbrf_sum#468") = EasyGrad.Zygote.pullback(sum, x)
					var"##tmp#467"
			end
	(y, EasyGrad.@refclosure((dd_y->begin
									d_y = dd_y
									d_x = e_zero(x)
									begin
											var"##pb_tmp#469" = var"##pbrf_sum#468"(d_y)
											@typeof d_x
											@show d_x
											@typeof var"##pb_tmp#469"[1]
											@show var"##pb_tmp#469"[1]
											d_x = ∑!(d_x, var"##pb_tmp#469"[1])
									end
									(d_x,)
							end)))
end
pb_func_test_man3(i1, i2) = begin
	s = zero(i1)
	@typeof s
	s .+= begin
					(var"##tmp#464", var"##pbrf_fn#465") = pb_fn2(i2)
					@typeof var"##tmp#464"
					var"##tmp#464"
			end
	y = begin
					(var"##tmp#461", var"##pbrf_sum#462") = EasyGrad.Zygote.pullback(sum, s)
					var"##tmp#461"
			end
	(y, EasyGrad.@refclosure((dd_y->begin
									d_y = dd_y
									d_s = e_zero(s)
									begin
											var"##pb_tmp#463" = var"##pbrf_sum#462"(d_y)
											@add! d_s var"##pb_tmp#463"[1]
									end
									s .-= fn(i2)
									begin
										@show d_s
										var"##pb_tmp#466" = var"##pbrf_fn#465"(d_s)
											@show var"##pb_tmp#466"
											d_i2 = var"##pb_tmp#466"[1]
									end
									d_i1 = e_zero(i1)
									@add! d_i1 zero(d_s)
									(d_i1, d_i2)
							end)))
end
pb_func_test_man3(a, b)[2](1f0)
@btime pb_func_test_man3($a, $b)[2](1f0)
;
