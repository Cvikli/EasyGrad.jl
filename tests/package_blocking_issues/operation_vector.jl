using FunctionWrappers: FunctionWrapper
using FunctionWranglers: FunctionWrangler, smap!
using BenchmarkTools

@show "ok"


function l(ops, a::T, b::T) where T
	out = zero(T)
	for op in ops
		out += op(a,b)
	end
	out
end
a=4
b=7
ops_s=[:ADD, :ADD, :MUL, :ADD, :SUBS, :SUBS, :MUL, :MUL]
ops_s = hcat([ops_s for i in 1:2*2*2*2*2*2]...)
@show length(ops_s)
sym_to_op = Dict(:ADD => [+], :SUBS => [-], :MUL => [*], :DIV => [/] )
opp=[sym_to_op[op][1] for op in ops_s]
w_op=[FunctionWrapper{Int, Tuple{Int, Int}}(op) for op in opp]
wg_op=FunctionWrangler(opp)

@btime $l($opp, $a, $b)
@btime $l($w_op, $a, $b)

function h(ops, a, b)
	out = 0
	for op in ops
		if op == :ADD
			out += +(a, b)
		elseif op == :SUBS
			out += -(a, b)
		elseif op == :MUL
			out += *(a, b)
		elseif op == :DIV
			out += /(a, b)
		end
	end
	out
end
function g(outs, w, a, b)
	smap!(outs, w, a, b)
	sum(outs)
end

@time h(ops_s, a, b)
@btime $h($ops_s, $a, $b)

outs = zeros(Int, length(opp))
@time g(outs, wg_op, a, b)
@btime $g($outs, $wg_op, $a, $b)
#%%
l(w_op, a, b)
#%%
h(ops_s, a, b)
#%%

# change default for `seconds` from 5.0 to 1.0
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0

# using Flux
IN1 = Float32[2]
IN2 = Float32[3]
IN3 = Float32[7]
IN4 = Float32[5]
ops = [+ , - , + ]
outs = Float32[0, 0, 0]
ins = [
	(Base.RefArray(IN1,1), Base.RefArray(IN2,1)), 
	(Base.RefArray(IN3,1), Base.RefArray(IN4,1)), 
	(Base.RefArray(outs,1), Base.RefArray(outs,2))
]

# thething(ops, ins, outs) = begin 
# 	outs[1] = +(ins[1][1][], ins[1][2][])
# 	outs[2] = -(ins[2][1][], ins[2][2][])
# 	outs[3] = +(ins[203][1][], ins[3][2][])
# 	outs
# end
thething_b() = begin 
	for op in 1:10000
		+(1, 3)
	end
	for op in 1:10000
		-(1, 3)
	end
end
THETHING_b(ops) = begin 
	for op in ops
		op(1, 3) 
	end
end
THETHING(ops, ins, outs) = begin 
	for (i,op) in enumerate(ops)
		outs[i] = op(ins[i][1][], ins[i][2][])
	end
	outs
end

plus = +
minus = +
plus_TYPED = FunctionWrapper{Int,Int}(+)
# minus_TYPED = +
@btime thething_b()
@btime THETHING_b(hcat([plus for i in 1:10000], [minus  for i in 1:10000]))
@btime THETHING_b(hcat([plus_TYPED for i in 1:10000], [plus_TYPED  for i in 1:10000]))
@btime THETHING(ops,ins,out)
@btime thething(ops,ins,out)

# outs
#%%
#%%
x = Ref(3)

x[]+=x[]+1
x[]+=x[]+1
