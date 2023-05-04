# *** Part 1 ***
# A monkey patch to FunctionWrappers's assume function
# assume must have an alwaysinline attribute, otherwises it doesn't get inlined
using FunctionWrappers
import FunctionWrappers.FunctionWrapper
if VERSION >= v"1.6.0-DEV.663"
    @inline function assume(v::Bool)
        Base.llvmcall(
            ("""
             declare void @llvm.assume(i1)
             define void @fw_assume(i8) alwaysinline
             {
                 %v = trunc i8 %0 to i1
                 call void @llvm.assume(i1 %v)
                 ret void
             }
             """, "fw_assume"), Cvoid, Tuple{Bool}, v)
    end
else
    @inline function assume(v::Bool)
        Base.llvmcall(("declare void @llvm.assume(i1)",
                       """
                       %v = trunc i8 %0 to i1
                       call void @llvm.assume(i1 %v)
                       ret void
                       """), Cvoid, Tuple{Bool}, v)
    end
end
# method redefinition
@inline FunctionWrappers.assume(v::Bool) = Main.assume(v)

# *** Part 2, A simple wrapper around function pointers, to make life easier ***
# ArithBiOp{T} is a binary function with type  T x T -> T
struct ArithBiOp{T}
    fptr::Ptr{Nothing}
end

# get function pointer by look up code instance
function get_biop_ptr(f,::Type{T}) where T
    # triger compilation of the function
    
    m = which(f,(T,T)).specializations[1]
    if !isdefined(m,:cache)
        precompile(f,(T,T))   
    end
    @assert isdefined(m,:cache)
    # get the function pointer

    ptr =  m.cache.specptr
    @assert ptr != C_NULL
    return ArithBiOp{T}(ptr)
end

# unsafely call the function by following calling conversion
# this only works if the inputs are trivial enough, so we don't need to worry about GC
@inline function (op::ArithBiOp{T})(i1::T,i2::T) where T
    unsafe_call(op,i1,i2)
end

# assume is used to bypass null pointer checking.
@inline @generated function unsafe_call(op::ArithBiOp{T},i1::T,i2::T) where T
    :(fptr = op.fptr; assume(fptr != C_NULL);ccall(fptr,$T,($T,$T),i1,i2))
end

# ***Part 3: set up benchmark***
# we don't use divide here, since it's type unstable
encode_dict = Dict{Symbol,Int}([:ADD=>0,:SUBS=>1,:MUL=>2])
# symbol inputs
sym_ops = Symbol[:ADD, :ADD, :MUL, :ADD, :SUBS, :SUBS, :MUL, :MUL,:ADD, :ADD, :MUL, :ADD, :SUBS, :SUBS, :MUL, :MUL]
# encode inputs
int_ops = Int[encode_dict[i] for i in sym_ops]
# function inputs
f_ops = Function[+, +, *, +, -, -, *, *, +, +, *, +, -, -, *, *] 
# raw function pointers from Julia's generic function
ptr_ops = [get_biop_ptr(i,Int64) for i in f_ops]
# function wrappers
funcwrap_ops = [FunctionWrapper{Int, Tuple{Int, Int}}(op) for op in f_ops]

function condjump(ops,a,b)
    s = zero(typeof(a))
	for op in ops
		if op == 0
			s += +(a, b)
		elseif op == 1
			s += -(a, b)
		elseif op == 2
			s += *(a, b)
        end
	end
    return s
end

function direct_eval(ops,a,b)
    s = zero(typeof(a))
    for op in ops
        s += op(a,b)
    end
    return s
end

using BenchmarkTools
a=4
b=7

print("bundle of jump:");@btime condjump($int_ops,$a,$b);
print("function wrapper:");@btime direct_eval($funcwrap_ops,$a,$b);
print("raw pointer:");@btime direct_eval($ptr_ops,$a,$b);
print("dynamic dispatch:");@btime direct_eval($f_ops,$a,$b);