
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0

f(x) = x .* x
X = randn(1000) .+ 10
O = randn(1000) .+ 10
test(O::Vector{Float64}, X::Vector{Float64}) = begin
	@btime O .= f.(2 .* X.^2 .+ 6 .* X.^3)
	# @btime for i in eachindex(X)
	# 	x = X[i]
	# 	X[i] = f(2x^2 + 6x^3 - sqrt(x))
	# end
	@btime @. O = f(2X^2 + 6X^3 - sqrt(X))
	@btime @. O = X + X + X + X + X
	@btime O .= X .+ X .+ X .+ X .+ X
	@btime O .= (((X .+ X) .+ X) .+ X) .+ X
end
test(O, X)
;