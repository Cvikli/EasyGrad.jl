using Revise

using SyntaxTree: linefilter!

using ChainRulesCore: @thunk, Zero
using LinearAlgebra
using LinearAlgebra: BlasFloat

includet("derivatives_helper_funcs.jl")
includet("scalar_derivatves.jl")
include("Base/base.jl")
include("Base/fastmath_able.jl")

includet("non_derivatives.jl")
include("Base/nondiff.jl")
include("Core/core.jl")

println(linefilter!(@macroexpand (@scalar_rule expm1(x) exp(x))))
# println(linefilter!(@macroexpand (@non_differentiable join(::Any))))

include("Base/array.jl")
# include("Base/arraymath.jl")
include("Base/evalpoly.jl")
include("Base/indexing.jl")
include("Base/mapreduce.jl")
include("Base/sort.jl")
include("LinearAlgebra/dense.jl")
include("LinearAlgebra/norm.jl")

# Everything transformed from rule(::typeof($function) ...) -> rrule(::Val{$function}, ...) 
# rrule\(::typeof\(([^\)]*)\), ?
# rrule\([\n\s]+::typeof\(([^\)]*)\),[\n\s]+ ?
# pb_$1

# pb_([^\(]*)\(
# rrule(::Val{$1}, 