
using Revise
using RelevanceStacktrace
using DataStructures
using Boilerplate: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad


@easygrad power(a, n::Int) = begin
	n2 = 0
	y0 = 0
	if n < 0.1
		y = 1
	else
		n2 = n-1
		y0 = power(a, n2)
		y = a * y0
	end
	# y = n <1 ? 1 : a * power(a, n-1)
	y
end

println("-----EVALUATION-----")

a, b = 2f0, 3
@show power(a, b)
@time power(a, b)
@show d_power(a, b)
@show @time d_power(a, b)
@time d_power(a, b)
# 0.000004 seconds (1 allocation: 16 bytes) # a, b = 2f0, 3f0
@show d_power(a, b)
using Zygote
@show gradient(power, a, b)
# Finite diff can't work here
# using FiniteDifferences
# j = grad(central_fdm(5, 1), power, a, b)
# @show j

#%%
using BenchmarkTools, Zygote
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@btime power($a, $b)
@btime d_power($a, $b)
@btime gradient(power, $a, $b)
#%%
printer2(args...) = println(args)
@show args
args = (:a, :b)
ex = Expr(:block,
						:((a, b) = (4, 5)),
						# :(eval(collect((arg) for arg in $args))))
						:(eval($args)))
						# :((($args)[1], $b)))
argsym_fixer(a, b) = :()
@show ex
eval(ex)
# 
# [3,4,5]...
#%%
args = (:a, :b)
ex = Expr(:block,
            :((a, b) = (4, 5)),
            :($(args...),))
eval(ex)
#%%
pb_power3(a, n::Int) = begin
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:11 =#
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:12 =#
	n2 = 0
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:13 =#
	if n < 0.1
			#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:14 =#
			y = 1
	else
			#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:16 =#
			n2 = n - 1
			#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:17 =#
			y = begin
							(var"##tmp#299", var"##pb#300") = pb_power3(a, n2)
							var"##tmp#299"
					end
			@show (n, y)
			#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:18 =#
			y = a * y
	end
	#= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/tests/10.recursive_fn.jl:21 =#
	(y, #= /home/sixzero/repo/julia-awesomeness/EasyGrad.jl/src/EasyGrad.jl:410 =# ((dd_y->begin
									d_y = deepcopy(dd_y)
									begin
											d_a = zero(a)
											d_n2 = zero(n2)
											d_n = zero(n)
									end
									if n < 0.1
									else
											d_a = EasyGrad.rev_bc_add!(d_a, y * d_y)
											d_y = EasyGrad.rev_bc_add!(d_y, a * d_y)
											var"##pb_tmp#301" = var"##pb#300"(d_y)
											d_a = EasyGrad.rev_bc_add!(d_a, var"##pb_tmp#301"[1])
											d_n2 = EasyGrad.rev_bc_add!(d_n2, var"##pb_tmp#301"[2])
											d_n = EasyGrad.rev_bc_add!(d_n, d_n2)
											@show (n, d_a)
									end
									(d_a, d_n)
							end)))
end

pb_power3(a, b)[2](1)