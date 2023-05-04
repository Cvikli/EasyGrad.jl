using SyntaxTree: linefilter, linefilter!
# using MacroTools: striplines
using BenchmarkTools

ex = :(pb_fn6(i1, i2) = begin
	y = i1 .* i2
	y .+= y .* 2
	y .+= y
	(y, EasyGrad.@refclosure((dd_y->begin
									d_y = deepcopy(dd_y)
									d_y .+= dd_y
									# d_y = deepcopy(d_y)
									d_y .+= dd_y .* 2
									# d_y = 2 .* d_y
									begin
											d_i1 = zero(i1)
											d_i2 = zero(i2)
									end
									(d_i1, d_i2) = (EasyGrad.rev_bc_add!(d_i1, i2 .* d_y), EasyGrad.rev_bc_add!(d_i2, i1 .* d_y))
									(d_i1, d_i2)
							end)))
end)
@btime striplines(ex)
@show striplines(ex)
@show (ex)
@btime linefilter(bex) setup=(bex=ex)
@show linefilter(ex)
@show (ex)
;
# MacroTools linefilter is DAMN bad!!! 10X difference!!
