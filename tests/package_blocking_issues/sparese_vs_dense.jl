
using SparseArrays

N = 1000
M = 1000
P = 100
a = ones(Float32, N, M)
b = ones(Float32, N, M)
as = sparse(a)
bs = sparse(b)


@time a .* b
@time a .* b
@time as .* bs
@time as .* bs
mul(x,y) = [x[i,j] * y[i,j]  for i in 1:size(x,1), j in 1:size(x,2) ]
	
@time mul(a,b)
@time mul(a,b)
@time mul(a,b)
;

