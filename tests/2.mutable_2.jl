
fn5(i1, i2) = begin
  # global count += 1
  # @show "It ran $count"
  y = i1 .* i2
  # y .+= y .* 2.f0
  y .+= i1
  # y .+= y
  y
end


dfn5_t(i1, i2) = begin
  y = i1 .* i2
  y .+= i1
  y
  d_y = [1f0]
  y .-= i1
  d_i1 = d_y
  @show d_i1
  d_i1 .+= i2 .* d_y
  @show d_i1
  d_i2 = i1 .* d_y
  @show d_y
  @show d_i2
  @show i1
  (d_i1, d_i2)
end
@show dfn5_t(a, b)
dfn5_t(a, b)