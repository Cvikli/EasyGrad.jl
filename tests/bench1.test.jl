
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.50
fn6_z(i1, i2) = begin
  fn6(i1, i2)[1]
end

using Zygote
@btime fn6(a, b)
@time fn6_z(a, b)
@time fn6_z(a, b)
println("Zygote:")
# @time gradient(fn6_z, a, b)
# @time gradient(fn6_z, a, b)
# r, pbfn= pullback(fn6_z, a, b)
# @btime pbfn(1)
# @btime gradient(fn6_z, a, b)
println("Easygrad")
@show @time d_fn6(a, b)
@btime d_fn6(a, b)
;

fn6(i1, i2) = begin
  y = i1 .* i2
  y .+= y .* i1
  y .+= y
  y
end


d_fn6(i1, i2) = begin
	#= none:1 =#
	#= none:2 =#
	y = i1 .* i2
	#= none:3 =#
	y .+= y .* i1
	#= none:4 =#
	y .+= y
	#= none:5 =#
	y
	d_y = deepcopy(Float32[1.0])
	y .-= y
	d_y .+= d_y
	y .-= y .* i1
	d_y .+= i1 .* d_y
	d_i1 = y .* d_y
	d_i1 .+= i2 .* d_y
	d_i2 = i1 .* d_y
	(d_i1, d_i2)
end