

quo(r::Float32,q::Float32) = r += q
foo(r::Ref{Float32},q::Float32) = r.x += q

a= Ref{Float32}(5.f0)
b= Ref{Float32}(8.f0)
c=Float32(4.)
d=Float32(5.8)
@time foo(a,c)
@time foo(a,c)
@time foo(b,c)
@time quo(d,c)
@time quo(d,c)
@time quo(d,c)

@code_llvm foo(a,c)
@code_llvm quo(d,c)

#%%

mutable struct TMP
    x::Vector{Float32}
end
@time t2 = TMP([4.f0])
@time t = TMP([4.f0])
fn(t) = t.x .+= 4.2f0
@time fn(t)
@time fn(t)
@time fn(t)

