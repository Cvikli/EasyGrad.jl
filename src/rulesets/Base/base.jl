# See also fastmath_able.jl for where rules are defined simple base functions
# that also have FastMath versions.

@scalar_rule one(x) zero(x)
@scalar_rule zero(x) zero(x)
@scalar_rule transpose(x) One()

# `adjoint`

function rrule(::Val{adjoint}, z::Number)
    adjoint_pullback(ΔΩ) = (NO_FIELDS, ΔΩ')
    return (z', adjoint_pullback)
end

# `real`

@scalar_rule real(x::Real) One()

function rrule(::Val{real}, z::Number)
    # add zero(z) to embed the real number in the same number type as z
    real_pullback(ΔΩ) = (NO_FIELDS, real(ΔΩ) + zero(z))
    return (real(z), real_pullback)
end

# `imag`

@scalar_rule imag(x::Real) Zero()

function rrule(::Val{imag}, z::Complex)
    imag_pullback(ΔΩ) = (NO_FIELDS, real(ΔΩ) * im)
    return (imag(z), imag_pullback)
end

# `Complex`

function rrule(::Type{T}, z::Complex) where {T<:Complex}
    Complex_pullback(ΔΩ) = (NO_FIELDS, Complex(ΔΩ))
    return (T(z), Complex_pullback)
end
function rrule(::Type{T}, x::Real) where {T<:Complex}
    Complex_pullback(ΔΩ) = (NO_FIELDS, real(ΔΩ))
    return (T(x), Complex_pullback)
end
function rrule(::Type{T}, x::Number, y::Number) where {T<:Complex}
    Complex_pullback(ΔΩ) = (NO_FIELDS, real(ΔΩ), imag(ΔΩ))
    return (T(x, y), Complex_pullback)
end

# `hypot`

@scalar_rule hypot(x::Real) sign(x)

function rrule(::Val{hypot}, z::Complex)
    Ω = hypot(z)
    function hypot_pullback(ΔΩ)
        return (NO_FIELDS, (real(ΔΩ) / ifelse(iszero(Ω), one(Ω), Ω)) * z)
    end
    return (Ω, hypot_pullback)
end

@scalar_rule fma(x, y, z) (y, x, One())
@scalar_rule muladd(x, y, z) (y, x, One())
@scalar_rule rem2pi(x, r::RoundingMode) (One(), DoesNotExist())
@scalar_rule(
    mod(x, y),
    @setup((u, nan) = promote(x / y, NaN16), isint = isinteger(x / y)),
    (ifelse(isint, nan, one(u)), ifelse(isint, nan, -floor(u))),
)

@scalar_rule deg2rad(x) π / oftype(x, 180)
@scalar_rule rad2deg(x) oftype(x, 180) / π

@scalar_rule(ldexp(x, y), (2^y, DoesNotExist()))

# Can't multiply though sqrt in acosh because of negative complex case for x
@scalar_rule acosh(x) inv(sqrt(x - 1) * sqrt(x + 1))
@scalar_rule acoth(x) inv(1 - x ^ 2)
@scalar_rule acsch(x) -(inv(x ^ 2 * sqrt(1 + x ^ -2)))
@scalar_rule acsch(x::Real) -(inv(abs(x) * sqrt(1 + x ^ 2)))
@scalar_rule asech(x) -(inv(x * sqrt(1 - x ^ 2)))
@scalar_rule asinh(x) inv(sqrt(x ^ 2 + 1))
@scalar_rule atanh(x) inv(1 - x ^ 2)


@scalar_rule acosd(x) (-(oftype(x, 180)) / π) / sqrt(1 - x ^ 2)
@scalar_rule acotd(x) (-(oftype(x, 180)) / π) / (1 + x ^ 2)
@scalar_rule acscd(x) ((-(oftype(x, 180)) / π) / x ^ 2) / sqrt(1 - x ^ -2)
@scalar_rule acscd(x::Real) ((-(oftype(x, 180)) / π) / abs(x)) / sqrt(x ^ 2 - 1)
@scalar_rule asecd(x) ((oftype(x, 180) / π) / x ^ 2) / sqrt(1 - x ^ -2)
@scalar_rule asecd(x::Real) ((oftype(x, 180) / π) / abs(x)) / sqrt(x ^ 2 - 1)
@scalar_rule asind(x) (oftype(x, 180) / π) / sqrt(1 - x ^ 2)
@scalar_rule atand(x) (oftype(x, 180) / π) / (1 + x ^ 2)

@scalar_rule cot(x) -((1 + Ω ^ 2))
@scalar_rule coth(x) -(csch(x) ^ 2)
@scalar_rule cotd(x) -(π / oftype(x, 180)) * (1 + Ω ^ 2)
@scalar_rule csc(x) -Ω * cot(x)
@scalar_rule cscd(x) -(π / oftype(x, 180)) * Ω * cotd(x)
@scalar_rule csch(x) -(coth(x)) * Ω
@scalar_rule sec(x) Ω * tan(x)
@scalar_rule secd(x) (π / oftype(x, 180)) * Ω * tand(x)
@scalar_rule sech(x) -(tanh(x)) * Ω

@scalar_rule acot(x) -(inv(1 + x ^ 2))
@scalar_rule acsc(x) -(inv(x ^ 2 * sqrt(1 - x ^ -2)))
@scalar_rule acsc(x::Real) -(inv(abs(x) * sqrt(x ^ 2 - 1)))
@scalar_rule asec(x) inv(x ^ 2 * sqrt(1 - x ^ -2))
@scalar_rule asec(x::Real) inv(abs(x) * sqrt(x ^ 2 - 1))

@scalar_rule cosd(x) -(π / oftype(x, 180)) * sind(x)
@scalar_rule cospi(x) -π * sinpi(x)
@scalar_rule sind(x) (π / oftype(x, 180)) * cosd(x)
@scalar_rule sinpi(x) π * cospi(x)
@scalar_rule tand(x) (π / oftype(x, 180)) * (1 + Ω ^ 2)

@scalar_rule sinc(x) cosc(x)

@scalar_rule(
    clamp(x, low, high),
    @setup(
        islow = x < low,
        ishigh = high < x,
    ),
    (!(islow | ishigh), islow, ishigh),
)
@scalar_rule x \ y (-(Ω / x), one(y) / x)


function rrule(::Val{identity}, x)
    function identity_pullback(ȳ)
        return (NO_FIELDS, ȳ)
    end
    return (x, identity_pullback)
end

# rouding related,
# we use `zero` rather than `Zero()` for scalar, and avoids issues with map etc
@scalar_rule round(x) zero(x)
@scalar_rule floor(x) zero(x)
@scalar_rule ceil(x) zero(x)
