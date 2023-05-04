# jsdfklj

val = 5 
println("val = ", val)
a = 5 
b = 5 
println("sfsefsds",typeof(b))
b = 6.2

println("sfsefsds",typeof(b))
println("sfsefsds",b)

@warn a

@show val
;
#%%
function kerulet(a,b)
	return a+b+a+b
end
# kerulet(a,b) = begin
# 	a+b+a+b
# end
# asdf = () -> a + b
kerulet(1, 2)

a = [1, 3]
push!(a, 2)
b = Set()
push!(b, 2)
sort(a)
sort!(a)

#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
test() = begin
	a = randn(Float32,10,10)
	b = randn(Float32,1)
	c = 600 > sum(a) ? 5.1 : nothing
	c += 2.
	# @btime sum!($b, $a)
end
test()
@code_warntype test()
#%%
add(c::Float32) = @show "FLoat ran"
add(c::String) = @show "String ran"
add("12")
add(12f0)
#%%
using FileIO
# write(data, "filename.dat")
# load("asdf.json")
# using CUDA
# a = CUDA.randn(10)
using CUDA
# +(a::CuArray, b::Array) = Array(a) + b

#%%

data = [1]

abstract type AbsrractFormat end
struct JSON <: AbsrractFormat
	name::String
end
struct CSV <: AbsrractFormat
	name::String
end
write(j::AbsrractFormat,data) = save(j,data)
save(j::JSON, data) = open(j.name, "w") do f println(f,"rfef", (data)) end
save(j::CSV, data) = open(j.name, "w") do f println(f,"rfef", (data)) end
write(CSV("asdf.json"), data)

#%%
using SparseArrays
@show typeof(1:5)
# @edit sum(1:1000)

@edit print(stdout, "sdf")

#%%
a=1:4
@show a;


̂for i ∈  a
	println(a,i)
	if i==0
		
	end
end


#%%

"asdf" |> println
# |>(f) = x -> f(x)
import Base: map

map(f::Function) = x -> map(f, x)
[1, 2] |> map(a -> a*2)

#%%

function fn(a, arr)  
	for i in arr
		a += i 
	end
	a
end

#%%

c=[0f0]
@show typeof(c)
arr = collect(Float32,1:10000)
@code_warntype fn(c,arr)
# @btime fn(c[1],arr)
# @btime sum!(c,arr)
# @btime fn(c)

#%%
c = randn(Float32, 2<<10)
a = randn(Float32, 2<<10)
b = randn(Float32, 2<<10)

fn(c, a, b) = (c .= a .+ b; c)

@btime a + b
@btime a .+ b
@btime fn(c, a, b)
;
#%%
using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.00
println("-"^60)

using CUDA

arit(o, x, y) = o .+= x .* y
arit50(o, x, y) = for i=1:50 o .+= x .* y end
arit100(o, x, y) = for i=1:100 o .+= x .* y end

# x = randn(Float32,30_000_000)
# y = randn(Float32,30_000_000)
# @btime arit($x, $y)
# @btime arit($x, $y)
N = 1 << (20 + 4)
x_cu = CUDA.randn(Float32, N)
y_cu = CUDA.randn(Float32, N)
p_cu = CUDA.zeros(Float32, N)
# @btime CUDA.@sync arit($p_cu, $x_cu, $y_cu)
# @btime CUDA.@sync arit50($p_cu, $x_cu, $y_cu)
# @btime CUDA.@sync arit100($p_cu, $x_cu, $y_cu)
@gflops CUDA.@sync arit100(p_cu, x_cu, y_cu)
# @btime arit200($p_cu, $x_cu, $y_cu)

#%%

a = randn(3,2)
[1, 2] .|> a -> a*2
#%%
sq(x) = x>0 ? "nothing" : x ^ 2
sq(x,y) = sq(x*y)
b = randn(1,2)
sq.("asd")


#%%
a = (1:100)

@time sq.(a)
fn(a) = [i^2 for i in a] 
fn(a)
@time fn(a)
;



#%%
using BenchmarkTools

a = randn(Float64, 1_000_000)
b = randn(Float64, 1_000_000)
c = randn(Float64, 1_000_000)

begin
@btime $c = +($a, $b)
@btime $c .= $a .+ $b
end
;

#%%



#%%


# ∂fn 
💩 = 2
@show 💩
😁 = "Ok"



#%%
using Distributed
# addprocs(2)

pmap(v -> (println(myid());v ^ 2), 1:10)
#%%
a= remotecall_fetch(v -> v ^ 2, 2, 10)
# fetch(a)
#%%
@async sq(2)
#%%
addprocs(16, "rabbit@192.121.1.1", exename="/home/szil/julia", )
pmap(v -> v ^ 2, 1:10)
#%%
@everywhere [2,3] sq(a) = a^2
remotecall_fetch(sq, 2, 10)

#%%

@code_lowered sq(2)

#%%
import Base: promote_shape
function promote_shape(a::Array, b::Array)
	promote_shape(size(a), size(b))
end

#%%

a=randn(3,2)
b=randn(3,3)
a+b

#%%
macro asdf(ex)
	dump(ex)
	@show ex
	ex.args[1] = :-
	ex
end

println(@asdf 1 + 2)
;
#%%

a = 1:100
@btime sum(a)
a = collect(a)
@btime sum(a)
#%%
g(a) = begin
	s = 0
	@avx for i = 1:length(a)
		s += a[i]
	end
	s
end
@btime g(a)
# @code_warntype g()
# a=[1.2f0]
# @time g()
#%%

using Revise

includet("tutorial_test_tutorial.jl")

# ....
# ....
# ....
# ....
# ....
# ....
# ....

#%%

z=fun(5)
@show size(z)

#%%

using PyCall
np = pyimport("numpy")
tf = pyimport("tensorflow")
np.array([1,2])



















