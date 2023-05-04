

adder_wrapp!(a::Number, b::AbstractArray) = a += (sum)(b)
adder_wrapp!(a::Nothing, b::Nothing) = a # In some cases when not all tuple elements are filled with nothing, it is necessary
adder_wrapp!(a::AbstractArray, b::Nothing) = a # In some cases when not all tuple elements are filled with nothing, it is necessary
adder_wrapp!(a::AbstractArray, b) where N = ∑!(a, b)
adder_wrapp!(a::Vector{Array{Float32, N}}, b::Vector{Union{Nothing, Array{Float32, N}}}) where N= begin
  for i in 1:length(a)
    adder_wrapp!(a[i], b[i]) 
  end
  a
end
adder_wrapp!(a::Tuple, b::Tuple) = begin
  @assert length(a) === length(b) "Only support same length tuples."
  Tuple(adder_wrapp!(a[i], b[i]) for i in 1:length(a))
end
adder_wrapp!(a, b) = begin
  a += b
end
macro add!(lhs, rhs)
	esc(quote
    $lhs = (adder_wrapp!)($lhs, $rhs) # TODO replace everything to: ∑! 
	end)
end

∑!(dest::Number, src) = sum(src, init=dest)
∑!(dest, src) = sum!(dest, src, init=false) 

a,b,c,d = [randn(2000,200,30) for i in 1:4]

test(o,a) = begin
	o=∑!(o,a)
end
testori(o,a) = begin
	@add! o a
end
x=6.
y=[6.]
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
@btime test(y,a)
@btime test(y,a)
@btime test(x,a)
@btime test(x,a)
# @btime $testori($(Ref(y))[],$(Ref(a))[])
# @btime $testori($(Ref(y))[],$(Ref(a))[])
@btime $testori($(Ref(x))[],$(Ref(a))[])
@btime $testori($(Ref(x))[],$(Ref(a))[])
@btime @add! $(Ref(x))[] $(Ref(a))[]

#%%
fn() = begin
	a,b,c,d = [randn(2000,200,30) for i in 1:4]
	x=6.
	@btime $testori($(Ref(x))[],$(Ref(a))[])
	@btime testori($(Ref(x))[],$(Ref(a))[])
	@btime testori($(Ref(x))[],a)
	@btime $testori(x,$(Ref(a))[])
	@btime testori(x,$(Ref(a))[])
	@btime testori(x, a)
end
fn()

#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
fn_add(x) = for i in 1:100 x.+=1 end
fn_add2(x) = for i in 1:100 x .= 1 .+ x end
@btime fn_add([3])
@btime fn_add2([3])
