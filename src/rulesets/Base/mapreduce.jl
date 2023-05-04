#####
##### `sum`
#####

function rrule(::Val{sum}, x::AbstractArray{T}; dims=:) where {T<:Number}
    y = sum(x; dims=dims)
    function sum_pullback(ȳ)
        # broadcasting the two works out the size no-matter `dims`
        x̄ = broadcast(x, ȳ) do xi, ȳi
            ȳi
        end
        return (NO_FIELDS, x̄)
    end
    return y, sum_pullback
end


function rrule(::Val{sum}, ::typeof(abs2),
    x::AbstractArray{T};
    dims=:,
) where {T<:Union{Real,Complex}}
    y = sum(abs2, x; dims=dims)
    function sum_abs2_pullback(ȳ)
        return (NO_FIELDS, DoesNotExist(), 2 .* real.(ȳ) .* x)
    end
    return y, sum_abs2_pullback
end
