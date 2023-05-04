using Boilerplate: @sizes

# [2,3,1] 						.* 			[2,1,3] 			= 	[2,3,3]
# [2,3,2,1] 					.* 			[2,1,2,3] 		= 	[2,3,2,3]
# [2,3,2] 						.* 			[2,1,2] 			= 	[2,3,2]
# [a,b,1] 						.* 			[a,1,c] 			= 	[2,3,2]
# [a,b,c] 						.* 			[a,1,c] 			= 	[2,3,2]
# [a,b,1,c] 				 	.+=			[2,3,2]
# [a,b,c....] 				.+ 			[a,1,c...] 		= 	[a,b,c]
# [a,b,c....,1,1,1] 	.+ 			[a,1,c...] 		= 	[a,b,c...1,1,1]
using Printf
# vararg_op_list = [("+", :.+=, sum), ("*", :.+=, prod)]
# op_list = ["+", "-", "*", "/", "^"]
op_type = []
for op in [
	:+,  :-, :*, :/, :^,
	:+=, :-=,  :*=, :/=, :^=,  # WARNING A += B IS A SYNTACTIC SUGAR FOR A = A + B
	:.+,:.-,  :.*, :./, :.^,
	:.+=, :.-=,:.*=, :./=,  :.^=,
	]
	s1=2.2												# 1
	s2=2.2
	p=randn(Float32, 2)						# 2
	q=2.2
	a=randn(Float32, 2) 					# 3
	b=randn(Float32, 2)
	a0=randn(Float32, 2,1)				# 4
	b0=randn(Float32, 2,1)
	a1=randn(Float32, 2,1)				# 5
	b1=randn(Float32, 1,5)
	a2=randn(Float32, 2,3,1) 
	b2=randn(Float32, 2,3,3)
	a3=randn(Float32, 2,3,1) 
	b3=randn(Float32, 2,1,2)
	a4=randn(Float32, 2,1,1) 			# 8
	b4=randn(Float32, 2,1)
	a5=randn(Float32, 2,1)   			# 9
	b5=randn(Float32, 2,1,1)
	a6=randn(Float32, 2,3)				# 10
	b6=randn(Float32, 2,3,1,1)
	a7=randn(Float32, 2,1,6,3,1)	#11
	b7=randn(Float32, 2,7,1,1,1)
	a8=randn(Float32, 1,1,6,3,1)
	b8=randn(Float32, 1,7,1,3,1)
	push!(op_type,Any[op])
	@show op
	head = "$op"
	for (i,(x,y)) in enumerate([
		(s1,s2),
		(p,q),
		(a,b),
		(a0,b0),
		(a1,b1),
		(a2,b2),
		(a3,b3),
		(a4,b4),
		(a5,b5),
		(a6,b6),
		(a7,b7),
		(a8,b8),
		])
		try
			exp=nothing
			if op in [:^, :^=, :.^, :.^=] 
				x= abs.(x) .+ 1.01f0 
				y= abs.(y) .+ 1.01f0 
			end 
			if head[1] == '.' && head[end] == '='
				exp = Expr(op,:($x),:($y))
			elseif head[end] == '='
				exp = Expr(:call, Symbol(head[1]), :($x), :($y))
			else
				exp = Expr(:call, op, :($x), :($y))
			end
			res = eval(exp)
			op_type[end] = [op_type[end]...,i]
			@printf("%19s = %16s %3s %16s \n", "$(size(res))","$(size(x))", "$op", "$(size(y))")
		catch e
			@printf("%19s = %16s %3s %16s \n",          "???","$(size(x))", "$op", "$(size(y))")
			# println(sprint(showerror, e))
		end
	end
end
# A[a1,a2...an] {+,-,+=,-=}				 B[b1,b2...bn,1,1...1] [a1==b1,a2==b2...an==bn,1,1...1]
# A[a1,a2...an] {*,*=} 						B[b1,b2...bn] [(A (array or scalar) && B scalar...) || (a1=any,a2==1&&b1==1,b2=any) || ()]
# A[a1,a2...an] {/,/=} 						B[b1,b2...bn] [a1==b1,a2==b2 || B Scalar]
# A 						{^,^=} 						B 						[A scalar && B scalar]
# A[a1,a2...an] {.+,.-,.*,./} 		B[b1,b2...bn] [ax==bx || (ax==1&&bx==1)]  res: max.(size(A),size(B))
# A[a1,a2...an] {.^} 							B 						[ax==bx || (ax==1&&bx==1) & A > 0 && B > 0]
# A[a1,a2...an] {.+=,.-=,.*=,./=} B[b1,b2...bm] [ax==bx || (ax==1&&bx==1)&&n>=m]
# A[a1,a2...an] {.^=} 						B[b1,b2...bn] [ax==bx || (ax==1&&bx==1)&&n>=m & A > 0 && B > 0)]
# 
# Any[:+, 1, 3, 4, 8, 9, 10]
# Any[:-, 1, 3, 4, 8, 9, 10]
# Any[:*, 1, 2, 5]
# Any[:/, 1, 2, 3, 4]  # DANGER... 3,4 case is bullshit
# Any[:^, 1]
# Any[:+=, 1, 3, 4, 8, 9, 10]
# Any[:-=, 1, 3, 4, 8, 9, 10]
# Any[:*=, 1, 2, 5]
# Any[:/=, 1, 2, 3, 4]
# Any[:^=, 1]
# Any[:.+, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
# Any[:.-, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
# Any[:.*, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
# Any[:./, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
# Any[:.^, 1, 2, 8]
# Any[:.+=, 2, 3, 4, 8]
# Any[:.-=, 2, 3, 4, 8]
# Any[:.*=, 2, 3, 4, 8]
# Any[:./=, 2, 3, 4, 8]
# Any[:.^=, 2, 8]

# reverse...
# Any[:*, 1, 2]  # only accept A x 1 * 1 x B
# Any[:*=, 1, 2]  # only accept A x 1 * 1 x B
# Any[:.+=, 3, 4, 6, 9, 10]  # assign...
# Any[:.-=, 3, 4, 6, 9, 10]  # assign...
# Any[:.*=, 3, 4, 6, 9, 10]  # assign...
# Any[:./=, 3, 4, 6, 9, 10]  # assign...
# Any[:.^=]  # assign...

op_type
# eval(Expr(:call,:.+=,:x,6))
# eval(Expr(:.+=,:x,6))
#%%

a=randn(2,3,3)
b=randn(2,2,3)
c=randn(2,3,3,2,1)
b .+= a
#%%
using Boilerplate: @sizes, @typeof
w=ones(Float32,300,30,40)
q=ones(Float32,300,1,40)
p=[1.]
@sizes q
fn(w,q)=sum(w,dims=[2,3];init=q)
fn(w)=sum(w,dims=[2,3])
# @sizes fn(w)
# @time fn(w)
#%%

@time sum!(q,w; init=true)
@show q
# @time sum(w; dims=[2,3], init=q)
# @time sum(w; init=q, dims=[2,3])
# @time fn(w,q)
;
#%%
using BenchmarkTools
@btime sum(w, dims=2);
#%%
@btime randn(3000,1,200);
#%%
using Base: promote_shape
function Base.promote_shape(a::Array{A}, b::Array{B}) where {A,B}
	promote_shape(size(a), size(b))
end
#%%
q=randn(30,400)
p=randn(30,400)
@time Base.:+(q,p)
#%%
# CodeInfo(
# 1 ─ %1  = Bs
# │         @_4 = Base.iterate(%1)
# │   %3  = @_4 === nothing
# │   %4  = Base.not_int(%3)
# └──       goto #4 if not %4
# 2 ┄ %6  = @_4
# │         B = Core.getfield(%6, 1)
# │   %8  = Core.getfield(%6, 2)
# │         Base.promote_shape(A, B)
# │         @_4 = Base.iterate(%1, %8)
# │   %11 = @_4 === nothing
# │   %12 = Base.not_int(%11)
# └──       goto #4 if not %12
# 3 ─       goto #2
# 4 ┄ %15 = Core.tuple(Base.:+, A)
# │   %16 = Core._apply_iterate(Base.iterate, Base.broadcast_preserving_zero_d, %15, Bs)
# └──       return %16
# )
# 7.093 μs (2 allocations: 93.83 KiB)
# 0.118740 seconds (382.40 k allocations: 21.776 MiB, 8.31% gc time, 99.89% compilation time)
# CodeInfo(
# 1 ─ %1  = Bs
# │         @_4 = Base.iterate(%1)
# │   %3  = @_4 === nothing
# │   %4  = Base.not_int(%3)
# └──       goto #4 if not %4
# 2 ┄ %6  = @_4
# │         B = Core.getfield(%6, 1)
# │   %8  = Core.getfield(%6, 2)
# │         Base.promote_shape(A, B)
# │         @_4 = Base.iterate(%1, %8)
# │   %11 = @_4 === nothing
# │   %12 = Base.not_int(%11)
# └──       goto #4 if not %12
# 3 ─       goto #2
# 4 ┄ %15 = Core.tuple(Base.:+, A)
# │   %16 = Core._apply_iterate(Base.iterate, Base.broadcast_preserving_zero_d, %15, Bs)
# └──       return %16
# )
# 6.975 μs (2 allocations: 93.83 KiB)
# 0.056079 seconds (27.36 k allocations: 1.400 MiB, 99.95% compilation time)
# 0.093647 seconds (354.44 k allocations: 19.927 MiB, 99.89% compilation time)
#%%

@sizes a
@sizes b
@sizes sum(b, dims=[3])[:,:,:,:,1]
@sizes reshape(sum(b, dims=[3]), size(a)...)
a .+= sum(b, dims=[3,5])

#%%

b .+= a
# @show b
# b .= a
# @show b
# b .= a
# @show b

#%%
@time a=randn(Float32,10,10)
@time b=randn(Float32,20,20)
@time c=randn(Float32,10,10)
@time d=randn(Float32,20,20)
swap(a,b) = a,b = b,a
@time swap(a,b)
@time swap(a,b)
@sizes a
@time a,b = b,a
t=b,a
@time b = a+d
@time a = t[1]+c
b,a=t
@time a,b = b+c,a+d
@time a,b = b+d,a+c
@sizes a
@code_warntype swap(a,b)
@sizes a

#%%

a .= b .+ c .+ b
∂b, ∂c = zeros(b), zeros(c)
∂b, ∂c = ∑!(∂b, ∂a .+ ∂a), ∑!(∂c, ∂a)

a .= c .* b
∂b, ∂c = zeros(b), zeros(c)
∂b, ∂c = ∑!(∂b, c .* ∂a), ∑!(∂c, b .* ∂a)

a .= c .* b .* b
∂b, ∂c = zeros(b), zeros(c)
∂b, ∂c = ∑!(∂b, b .* c .* ∂a .+ b .* c .* ∂a), ∑!(∂c, b .* b .* ∂a)

a .= b .* c .* d
∂b, ∂c, ∂d = zeros(b), zeros(c), zeros(d)
∂b, ∂c, ∂d = ∑!(∂b, c .* d .* ∂a), ∑!(∂c, b .* d .* ∂a), ∑!(∂d, b .* c .* ∂a)

a .= a .* b .* c
∂a1, ∂b, ∂c = copy(∂a), zeros(b), zeros(c)
∂a1, ∂b, ∂c = ∑!(∂a1, b .* c .* ∂a), ∑!(∂b, a .* c .* ∂a), ∑!(∂c, a .* b .* ∂a)
∂a = ∂a1

∑!(dest, src) = sum!(dest, src, init=false)  # To "back sum" broadcasted parts.
# problem
a, b = a .* b .*c, a .* b
# rewrite
a, b = a .* b .*c, a .* b
# prealloc derivates
∂a1, ∂b1, ∂c = copy(∂a), copy(∂b), zeros(c)
# reverse
∂a1 .= ∑!(∂a1, b .* c .* ∂a1 .+ b .* ∂b1) 
∂b1 .= ∑!(∂b1, a .* c .* ∂a1 .+ a .* ∂b1)
∂c .= ∑!(∂c, a .* b .* ∂a1)
∂a = ∂a1
∂b = ∂b1

#%%
#problem
for i in 1:30
	a, b = a .* b .*c, a .* b
end
# rewrite
fn(a,b,c,d,t1,t2) = begin
	# t1 = zero(a)
	# t2 = zero(b)
	s_a = Array{typeof(a .* b .* c), 1}(undef, length(1:30))
	s_b = Array{typeof(a .* b), 1}(undef, length(1:30))
	for (_i_i, i) in enumerate(1:30)
		# 1.
		# t1, t2 = a .* b .*c, a .* b 
		# a, b = t1, t2

		# 2.
		# a,b = a .* b .*c, a .* b 
		
		# 3.
		# t1 .= a  
		# t2 .= b
		# a .= t1 .* t2 .*c
		# b .=  t1 .* t2
		
		# 4.
		# a1 .= a .* b .*c 
		# b1 .= a .* b
		# a .= a1  
		# b .= b1

		# 5.
		s_a[_i_i] .= a .* b .*c 
		s_b[_i_i] .= a .* b
		a, b = s_a[_i_i], s_b[_i_i]  
	end

	∂fn(dy) = begin
		∂a=dy
		∂b=dy

		∂a1, ∂b1, ∂c = copy(∂a), copy(∂b), zeros(c)
		for i in 30:1
			a = afor[i]
			b = bfor[i]
			∂a1 .= ∑!(∂a1, b .* c .* ∂a1 .+ b .* ∂b1) 
			∂b1 .= ∑!(∂b1, a .* c .* ∂a1 .+ a .* ∂b1)
			∂c .= ∑!(∂c, a .* b .* ∂a1)
			∂a = ∂a1
			∂b = ∂b1
			# a = a ./b ./c
			# b = b ./a
		end
	end

end
a,b,c,d = [randn(2000,200,30) for i in 1:4]
@time t1,t2 = randn(2000,200,30),randn(2000,200,30)
@time randn(2000,200,30)
@btime fn(a,b,c,d,t1,t2)
@btime fn(a,b,c,d,t1,t2)
@btime fn(a,b,c,d,t1,t2)
# @time (a,b)
# @time (a,b,c)
# @time (a,b,c,d)

;
#%%


#problem, not solveable due to a is on the right side...
for i in 1:30
	a .+= a .* b .*c
end
#problem
for i in 1:30
	a .+= b .* c
end
# no rewrite
# derivative
for i in 1:30
	∑!(∂b, b .* ∂a)
	∑!(∂c, c .* ∂a)
end
#problem
for i in 1:30
	a .*= b .* c
end
# no rewrite
# derivative
for i in 30:1
	a ./= b .* c
	∑!(∂b, a .* b .* ∂a)
	∑!(∂c, a .* c .* ∂a)
	∑!(∂a, b .* c .* ∂a) # warning...
end



#%%
∑!(dest, src) = sum!(dest, src, init=false)  # To "back sum" broadcasted parts.
#%%
b=8
c=3
@time d_c= b
@time d_c= b
#%%
shape(dest, src) = begin
	if size(desc) == size(src)
		return src
	else
		return sum!(desc, src, init=false)
	end
end

#%%

r_add!(a::Number, b::Number) = a += b ## TODO reverse_broadcast_add! to shorter solution
rev_bc_add!(a::Number, b::Vector{Float32}) = a += sum(b)
rev_bc_add!(a::Number, b::Vector{Number}) = a += sum(b)
rev_bc_add!(a::AbstractArray{T}, b::AbstractArray{T}) where T = rev_bc_add!(Array(a), Array(b))
rev_bc_add!(a::Array{T}, b::Array{T}) where T = begin
	sum_sizes = findall(size(a) .!= size(b))
  @show sum_sizes
	if length(sum_sizes)>0
		a .+= reshape(sum(b, dims=sum_sizes), size(a)...)
	else
		a .+= b
	end
end
rev_bc_add!(a::Vector{T}, b::Vector{T}) where T = begin
	sum_sizes = findall(v->v, size(a) .!= size(b))
	if length(sum_sizes)>0
		a .+= sum(b, dims=sum_sizes)
	else
		a .+= b
	end
end


#%%
b.*[2.0f0,4.0f0]
#%%
@eval ($(Symbol("Δ+")))(a) = a^2

#%%

# @code_warntype (@eval ($(Symbol("'+"))))(3)
# var"+^"(4)
# var"Δ.+"(a) = a*2
# var".+¯¹"(a...) = sum(a)*2
# var".+¯¹"(5)
# var"+̇ "(5)
# a=var".+=^"
vararg_op_list = [("+", :.+=, sum), ("*", :.+=, prod)]
op_list = ["+", "-", "*", "/", "^"]
# op_list = ["+", "-", "*", "/", "^", "÷", "\\", "%"]
for op in op_list
	rev_op = "." * op * "'¹"
	@show rev_op
	@eval ($(Symbol("$rev_op")))(A::Array{T,N},B::Array{T,M}) where {T,N,M} =println("eheh")
end
for op in vararg_op_list
	rev_op = "." * op * "'¹"
	@show rev_op
	@eval ($(Symbol("$rev_op")))(A::Array{T,N},Bs::(Array{T,M} where M)...) where {T,N} = begin
		@sizes A
		for B in Bs
			@sizes B
			union_length = min(length(size(A)),length(size(B)))
			unmatched_dims = findall(size(A)[1:union_length] .!= size(B)[1:union_length])
			@show unmatched_dims
			# reshape for cutting tail 1,1,1,... to match dimension
			A = reshape(A, size(A)[1:union_length]...)
			if length(unmatched_dims) > 0
				# @sizes sum(A, dims=unmatched_dims)
				# B .+= sum(A, dims=unmatched_dims)
				sum!(B,A; init=false)
			else
				B .+= A
			end
		end
	end 
end 

# a .+= b .+ c
# a .= a .+ b .+ c

# var".+=^"(a, var".+^"(a, b,c ))
@sizes b
@sizes a
@sizes c
@show b
var".+=^"(c, b, a)
@show b
#%%

(var"+++")(x::T, y::T) where {T} = println("ok")


#%%

a=randn(Float32,100,100)
b=randn(Float32,100,100)
# a=6
# b=5
using BenchmarkTools
fn(a, b)= begin
	for i = 1:10
		a, b=a .+ 6 .+b, b .+ 7 .+ a .* 2
	end
	a, b
end
gn(a,b) = begin
	a, b=a .+ 6 .+b, b .+ 7 .+ a .* 2
end
qn(a,b) = begin
	c1=copy(a)
	d1=copy(b)
	@btime hn($a,$b,$c1,$d1)
end
hn(a,b,a1,b1) = begin
	for i = 1:10
		a1.=a .+ 6 .+b
		b1.=b .+ 7 .+ a .* 2
		a.=a1
		b.=b1
	end
	a,b
end
kn(a,b) = begin
	a1=copy(a)
	b1=copy(b)
	for i = 1:10
		a1.=a .+ 6 .+b
		b1.=b .+ 7 .+ a .* 2
		a.=a1
		b.=b1
	end
end
iin(a,b) = begin
	for i = 1:10
		a.+=a .+ 6 .+b
		b.+=b .+ 7 .+ a .* 2
	end
end
wn(a,b,a1,b1) = begin
	for i = 1:10
		a1.=a .+ 6 .+b
		b1.=b .+ 7 .+ a .* 2
		a,b,a1,b1=a1,b1,a,b
	end
	a,b
end
@time fn(a,b) 
@time fn(a,b) 
# @btime fn($a,$b) 
# @btime fn(a,b) 
# @time a, b=a+6+b, b+7+a*2
@time gn(a,b)
@time gn(a,b)
a1=copy(a)
b1=copy(b)
@time hn(a,b,a1,b1)
@time hn(a,b,a1,b1)
@btime fn($a,$b)
@btime kn($a,$b)
@btime hn($a,$b,$a1,$b1)
# qn(a,b)
@btime wn($a,$b,$a1,$b1)
@time wn(a,b,a1,b1)
@show wn(a,b,a1,b1)==hn(a,b,a1,b1)
# x=hn(a,b,a1,b1)
# y=wn(a,b,a1,b1)
# @show x
# @time iin(a,b)
# @time iin(a,b)
# @btime gn($a,$b)
# @btime hn($a,$b)
# @btime iin($a,$b)
# @btime a, b=a+6+b, b+7+a*2
;
#%%



#%%
a, b = 6, 7
foo(a, b) = begin 
	for i = 1:2
		a, b=a + 6, b + 7+i
	end
	a,b
end
@time foo(a,b)
@time foo(a,b)
@btime x = foo($a,$b)
# fn(a,b)
;