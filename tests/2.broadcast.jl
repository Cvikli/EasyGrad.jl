

rev_bc_add!(a::Float32, b::Float32) = a += b
rev_bc_add!(a::Float32, b::Vector{Float32}) = a += sum(b)
rev_bc_add!(a::Array{Float32}, b::Array{Float32}) = begin
	sum_sizes= findall(v->v, size(a) .!= size(b))
	if length(sum_sizes)>0
		a .+= sum(b, dims=sum_sizes)
	else
		a .+= b
	end
end

#%%

a = randn(Float32, 2,3)
b = randn(Float32, 2,1)
@show a .+ b
a = randn(Float32, 2,1,2)
b = randn(Float32, 2,3,2)
@show b.*a
@show a.*b
@show b.+=a
# Meta.@lower b.+=a
# @edit Base.:+( a,b)
# @edit Base.broadcasted(+, a,b)

#%%
a=[1f0]
b = 2f0
a .+= b

d_a = [1f0]

d_b = zero(b)
a = randn(Float32, 2,3)
b = randn(Float32, 2,1)
# @time d_b += sum(d_a)
# @time d_b = easy_add!(d_b, d_a)
# @time d_b += sum(d_a)
# @time d_b = easy_add!(d_b, d_a)
#%%
c, d = randn(1, 2), randn(3, 2)
using EasyGrad: rev_bc_add!
@show rev_bc_add!(c, d)
@show size(c)
#%%
c, d = copy(a), copy(b)
@show c .+= d
#%%
#%%
randn(1,2) .* randn(3,1)
#%%
a = randn(Float32, 2,3)
b = randn(Float32, 2,1)
@time b .+= sum(a, dims=[2])
@time b .+= sum(a, dims=[2])
;
#%%
a = randn(Float32, 2,3)
b = randn(Float32, 2,1)
a .+= b

d_b = zero(b)
@show a
d_a = zero(a) .+ 1
@show d_a

# d_b .+= d_a 
easy_add!(d_b, d_a)

#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
a = randn(Float32, 2,3)
b = randn(Float32, 2,1)
@btime findall(v->v, size(a) .!= size(b))
@btime @inbounds findall(size(a) .!= size(b))

@show typeof([size(a)...] .!= size(b))
#%%
@edit findall(size(a) .!= size(b))
#%%
function myfindall(p, X)
	out = Vector{Int}(undef, length(X))
	ind = 0
	for (i, x) in pairs(X)
			if p(x)
					out[ind+=1] = i
			end
	end
	resize!(out, ind)
	return out
end
@btime myfindall(v->v, size(a) .!= size(b))
@btime myfindall(v->v, size(a) .!= size(b))

#%%

rev_bc_add!(a::Number, b::Number) = a += b
@code_warntype rev_bc_add!(1e0, 2f0)