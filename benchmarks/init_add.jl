
using FillArrays

adder1(a,b ) = (c=zeros(Float32,size(a)...); c .= a .+ b.*2)
adder2(a,b ) = a .+ b.*2
testad() = begin
	# a = Fill(2f0, 10)
	# b = Fill(2f0, 10)
	a = zeros(Float32, 1000,2)
	b = zeros(Float32, 1000,2)
	@btime adder1($a, $b)
	@btime adder2($a, $b)
	# x=@btime adder($a, $b)
	# @show x
	# c = zeros(Float32, 10)
	# d = zeros(Float32, 10)
	# @btime adder($c, $d)
end
testad()
;
#%%
numRef(v::Float32) = Ref(v)
numRef(v::AbstractArray) = v
adder!(r::Array, a::Number) = r .+= a
adder!(r::Ref{Float32}, a::Number) = r[] += a
v = 1f0
i = Ref(v)
@time i = numRef(v)
i = [1f0]
i = 1f0
i = numRef(i)
# @time i = Ref(1f0)
adder!(i, 2f0)
@show i
@time adder!(i, 2f0)
@time adder!(i, 2f0)
@show i
@btime adder!($i, 2f0)
# @code_lowered adder!(Ref(i), 2f0)

v = 1f0
adder!(v, 2f0)
# @btime adder!($v, 2f0)