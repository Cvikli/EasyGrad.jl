
# 1. measure dict vs if case speed 
# 2. reverse broadcast simplest
# 3. @.reverse CODE 
using RelevanceStacktrace
using BoilerplateCvikli: @typeof, @sizes
using EasyGrad: @easygrad
using EasyGrad
using FiniteDifferences

t1(a) = begin
# @easygrad t1(a) = begin
  b=6
  x=a
  s_x = x
  x=2*b
  y=a*b
  s3_x = x
  x=a+y
  s4_x = x
  x=x
  s5_x = x
  x=x+x*a
  s6_x = x
  x=x*y+a
  s7_x = x
  x=3*x+y*x
  x, (dd_y) -> begin
    d_x = zero(x)
    d_x = d_x + dd_y
    x = s7_x
    d_y = zero(y)
    d_x, d_y =d_x + 3d_x + y * d_x, d_y + x * d_x
    x = s6_x
    d_a = zero(a)
    d_x, d_y, d_a = d_x + y * d_x, d_y + x * d_x, d_a + d_x
    x = s5_x
    d_x, d_a = d_x + d_x + a * d_x, d_a + x * d_x
    x = s4_x
    d_x =  d_x + d_x
    x = s3_x
    d_a, d_y =d_a + d_x, d_y + d_x
    d_b = zero(b)
    d_a, d_b = d_a + b * d_y, d_b + a * d_y
    x = s_x
    d_b = d_b + 2d_x
    d_a = d_a + d_x
    (d_a,)
  end
end
a=4.f0
# t1(a)

# @show grad(central_fdm(5, 1), t1, a) # (83715.18f0,)
@show t1(a)[2](1.f0)
#%%
x=x*y*y
x=3*x+y*x+y*y
#%%
t2(x,y) = begin
  x+=y
  x+=x*x
end

#%%
t3(x,y) = begin
  if x<5
    x=8
  end

  if x<5
    x=8
  else
    x=9
  end

  if x==y
    y=8
  elseif x>8
    x=9
  elseif x==10
    x=2
  end

  if x==y
    y=8
  elseif x>8
    x=9
  else
    y=3
  end
end

t4(x) = begin
  for i = 2:10
    x+=x+3
  end
  x
end

fn(j) = begin
  j*5 + j*j
end 

function f()
  a=fn(x)*8
  a
end

function g()
  fn(x)*8+8
end

struct Obj
  e::Float32
  f::Float32
end

q=Obj(4.f0,5.f0)
function h(i)
  x=i.e*i.f + i.e 
  x
end
h(q)

v=randn(Float32,2)
w=randn(Float32,2)
function l(x::Float32)
  f=Obj(4.f0,5.f0)
  c=f.e*x 
  c+=f.f*4
  c
end


foo(x::Vector{Float32}) = begin
  x .+= 4 .* x
  x 
end
foo(v)

bar(x::Array{Float32, N}, y) where N = begin
  y .+= x .* y
end
bar(v,w)

quo(x::Array{Float32, N}, y) where N = begin
  q=@. x*y
  q
end
quo(v,w)

