using Revise
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad: @easygrad, @code_expr_easy, process_body
import EasyGrad

@easygrad square(x) = begin
	y =x .* x
	y
end

@easygrad broadcast_test(x) = begin
	y = square(x)
	y[1]
end

println("-----EVALUATION-----")

N = 1000
a = randn(N)
# a = [2f0]
broadcast_test(a)
@time broadcast_test(a)


d_broadcast_test(a)
@time d_broadcast_test(a)
@time d_broadcast_test(a)

using Zygote
r = gradient(broadcast_test, a)
@time gradient(broadcast_test, a)

;
#%%
@show "OK"
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
@btime broadcast_test($a)
@btime d_broadcast_test($a)
@btime gradient(broadcast_test, a)
# 653.433 ns (1 allocation: 7.94 KiB)
# 3.353 μs (10 allocations: 48.02 KiB)
# 3.051 μs (21 allocations: 40.25 KiB)
;
#%%

@easygrad square(x) = begin
	y =x .* x
	y
end
#%%
pb_square2(x) = begin
	y = x .* x
	(y, EasyGrad.@refclosure((dd_y->begin
									d_y = deepcopy(dd_y)
									d_x = x .* d_y + x .* d_y
									d_x
							end)))
end
pb_broadcast_test2(x) = begin
	y = begin
					var"##bc_pb#292" = pb_square2(x)
					# @time var"##tmp#293" = EasyGrad.extract_i.(var"##bc_pb#292", 1)
					x
					# @time var"##pb#294" = EasyGrad.extract_i.(var"##bc_pb#292", 2)
					# var"##tmp#293"
			end
	(y[1], ((dd_y-> begin
									d_y = zero(y)
									d_y[1] = EasyGrad.rev_bc_add!(d_y[1], dd_y)
									begin
										 	# var"##pb_tmp#295" = EasyGrad.fn_caller.(var"##pb#294", d_y)
											# d_x = var"##pb_tmp#295"
									end
									1f0
							end)))
end
pb_broadcast_test2(a)[2](1)
@time pb_broadcast_test2(a)[2](1)
@time pb_broadcast_test2(a)[2](1)
;
#%%
# @code_warntype pb_square2.(a)
@code_warntype pb_broadcast_test2(a)
# @code_warntype pb_broadcast_test2(a)[2](1)
# TODO why EasyGrad.@refclosure causes the error?
