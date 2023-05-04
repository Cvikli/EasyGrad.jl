#####
##### `dot`
#####


function rrule(::Val{dot}, x, y)
    function dot_pullback(ΔΩ)
        return (NO_FIELDS, @thunk(y .* ΔΩ'), @thunk(x .* ΔΩ))
    end
    return dot(x, y), dot_pullback
end


function rrule(::Val{dot}, x::AbstractVector{<:Number}, A::AbstractMatrix{<:Number}, y::AbstractVector{<:Number})
    Ay = A * y
    z = adjoint(x) * Ay
    function dot_pullback(ΔΩ)
        dx = @thunk conj(ΔΩ) .* Ay
        dA = @thunk ΔΩ .* x .* adjoint(y)
        dy = @thunk ΔΩ .* (adjoint(A) * x)
        return (NO_FIELDS, dx, dA, dy)
    end
    dot_pullback(::Zero) = (NO_FIELDS, Zero(), Zero(), Zero())
    return z, dot_pullback
end

function rrule(::Val{dot}, x::AbstractVector{<:Number}, A::Diagonal{<:Number}, y::AbstractVector{<:Number})
    z = dot(x,A,y)
    function dot_pullback(ΔΩ)
        dx = @thunk conj(ΔΩ) .* A.diag .* y  # A*y is this broadcast, can be fused
        dA = @thunk Diagonal(ΔΩ .* x .* conj(y))  # calculate N not N^2 elements
        dy = @thunk ΔΩ .* conj.(A.diag) .* x
        return (NO_FIELDS, dx, dA, dy)
    end
    dot_pullback(::Zero) = (NO_FIELDS, Zero(), Zero(), Zero())
    return z, dot_pullback
end

#####
##### `cross`
#####


# TODO: support complex vectors
function rrule(::Val{cross}, a::AbstractVector{<:Real}, b::AbstractVector{<:Real})
    Ω = cross(a, b)
    function cross_pullback(ΔΩ)
        return (NO_FIELDS, @thunk(cross(b, ΔΩ)), @thunk(cross(ΔΩ, a)))
    end
    return Ω, cross_pullback
end


#####
##### `det`
#####

function rrule(::Val{det}, x::Union{Number, AbstractMatrix})
    Ω = det(x)
    function det_pullback(ΔΩ)
        ∂x = x isa Number ? ΔΩ : Ω * ΔΩ * inv(x)'
        return (NO_FIELDS, ∂x)
    end
    return Ω, det_pullback
end

#####
##### `logdet`
#####


function rrule(::Val{logdet}, x::Union{Number, StridedMatrix{<:Number}})
    Ω = logdet(x)
    function logdet_pullback(ΔΩ)
        ∂x = x isa Number ? ΔΩ / x' : ΔΩ * inv(x)'
        return (NO_FIELDS, ∂x)
    end
    return Ω, logdet_pullback
end

#####
##### `logabsdet`
#####


function rrule(::Val{logabsdet}, x::AbstractMatrix)
    Ω = logabsdet(x)
    function logabsdet_pullback(ΔΩ)
        (Δy, Δsigny) = ΔΩ
        (_, signy) = Ω
        f = signy' * Δsigny
        imagf = f - real(f)
        g = real(Δy) + imagf
        ∂x = g * inv(x)'
        return (NO_FIELDS, ∂x)
    end
    return Ω, logabsdet_pullback
end

#####
##### `trace`
#####


function rrule(::Val{tr}, x)
    # This should really be a FillArray
    # see https://github.com/JuliaDiff/ChainRules.jl/issues/46
    function tr_pullback(ΔΩ)
        return (NO_FIELDS, Diagonal(fill(ΔΩ, size(x, 1))))
    end
    return tr(x), tr_pullback
end


#####
##### `pinv`
#####

@scalar_rule pinv(x) -(Ω ^ 2)


function rrule(::Val{pinv}, x::AbstractVector{T},
    tol::Real = 0,
) where {T<:Union{Real,Complex}}
    y = pinv(x, tol)
    function pinv_pullback(Δy)
        ∂x = sum(abs2, parent(y)) .* vec(Δy') .- 2real(y * Δy') .* parent(y)
        return (NO_FIELDS, ∂x, Zero())
    end
    return y, pinv_pullback
end

function rrule(::Val{pinv}, x::LinearAlgebra.AdjOrTransAbsVec{T},
    tol::Real = 0,
) where {T<:Union{Real,Complex}}
    y = pinv(x, tol)
    function pinv_pullback(Δy)
        ∂x′ = sum(abs2, y) .* Δy .- 2real(y' * Δy) .* y
        ∂x = x isa Transpose ? transpose(conj(∂x′)) : adjoint(∂x′)
        return (NO_FIELDS, ∂x, Zero())
    end
    return y, pinv_pullback
end

function rrule(::Val{pinv}, A::AbstractMatrix{T}; kwargs...) where {T}
    Y = pinv(A; kwargs...)
    function pinv_pullback(ΔY)
        m, n = size(A)
        # contract over the largest dimension
        if m ≤ n
            ∂A = (Y' * -ΔY) * Y'
            ∂A = add!!(∂A, (Y' * Y) * (ΔY' - (ΔY' * Y) * A)) # Y' Y ΔY' (I - Y A)
            ∂A = add!!(∂A, (I - A * Y) * (ΔY' * Y) * Y') # (I - A Y) ΔY' Y Y'
        elseif m > n
            ∂A = Y' * (-ΔY * Y')
            ∂A = add!!(∂A, Y' * (Y * ΔY') * (I - Y * A)) # Y' Y ΔY' (I - Y A)
            ∂A = add!!(∂A, (ΔY' - A * (Y * ΔY')) * (Y * Y')) # (I - A Y) ΔY' Y Y'
        end
        return (NO_FIELDS, ∂A)
    end
    return Y, pinv_pullback
end

#####
##### `sylvester`
#####

# included because the primal uses `schur`, for which we don't have a rule


# included because the primal mutates and uses `schur` and LAPACK

function rrule(::Val{sylvester}, A::StridedMatrix{T}, B::StridedMatrix{T}, C::StridedMatrix{T}
) where {T<:BlasFloat}
    RA, QA = schur(A)
    RB, QB = schur(B)
    D = QA' * (C * QB)
    Y, scale = LAPACK.trsyl!('N', 'N', RA, RB, D)
    Ω = rmul!(QA * (Y * QB'), -inv(scale))
    function sylvester_pullback(ΔΩ)
        ∂Ω = T <: Real ? real(ΔΩ) : ΔΩ
        ∂Y = QA' * (∂Ω * QB)
        trans = T <: Complex ? 'C' : 'T'
        ∂D, scale2 = LAPACK.trsyl!(trans, trans, RA, RB, ∂Y)
        ∂Z = rmul!(QA * (∂D * QB'), -inv(scale2))
        return NO_FIELDS, @thunk(∂Z * Ω'), @thunk(Ω' * ∂Z), @thunk(∂Z * inv(scale))
    end
    return Ω, sylvester_pullback
end

#####
##### `lyap`
#####

# included because the primal uses `schur`, for which we don't have a rule


# included because the primal mutates and uses `schur` and LAPACK

function rrule(::Val{lyap}, A::StridedMatrix{T}, C::StridedMatrix{T}
) where {T<:BlasFloat}
    R, Q = schur(A)
    D = Q' * (C * Q)
    Y, scale = LAPACK.trsyl!('N', T <: Complex ? 'C' : 'T', R, R, D)
    Ω = rmul!(Q * (Y * Q'), -inv(scale))
    function lyap_pullback(ΔΩ)
        ∂Ω = T <: Real ? real(ΔΩ) : ΔΩ
        ∂Y = Q' * (∂Ω * Q)
        ∂D, scale2 = LAPACK.trsyl!(T <: Complex ? 'C' : 'T', 'N', R, R, ∂Y)
        ∂Z = rmul!(Q * (∂D * Q'), -inv(scale2))
        return NO_FIELDS, @thunk(mul!(∂Z * Ω', ∂Z', Ω, true, true)), @thunk(∂Z * inv(scale))
    end
    return Ω, lyap_pullback
end
