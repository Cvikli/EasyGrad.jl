Zero(arr::Number) = zero(arr)
# Zero(arr::AbstractArray) = Fill(0f0, size(arr)...) # TODO why we can't decide type for Zeros only for Fill?
Zero(arr::AbstractArray) = zeros(Float32, size(arr)...) # TODO why we can't decide type for Zeros only for Fill?
# Zero(arr::Array) = Zeros(size(arr)...)
Zero(arr::Number) = zero(arr)
# Zero(arr::AbstractArray) = Fill(0f0, size(arr)...) # TODO why we can't decide type for Zeros only for Fill?
Zero(arr::AbstractArray) = zeros(Float32, size(arr)...) # TODO why we can't decide type for Zeros only for Fill?
# Zero(arr::Array) = Zeros(size(arr)...)
