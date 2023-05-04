
fn6(a, b, c, y) = begin
	(y .= c .* a; saved_y1 = deepcopy(y))
	(y .= y .* b; saved_y2 = deepcopy(y))
	y .+= 2c
end
d_fn6(a, b, c, y) = begin
	y = deepcopy(y)
	(saved_y1 = deepcopy(y); y .= c .* a)
	(saved_y2 = deepcopy(y); y .= y .* b)
	y .+= 2c
	d_y = [1.f0]

	y .-= 2c
	d_c = d_y .* 2

	y .= saved_y2 # d_y-t zerozni kéne, meg vhogy mégsem, ha önmagába assignol.
	d_b = d_y .* y
	d_y .= d_y .* b # TODO here it is not getting loaded!

	y .= saved_y1
	d_c .+= d_y .* a # TODO AHHH
	d_a = d_y .* c

	d_a, d_b, d_c, d_y
end

a = [1.e0]
b = [2.e0]
c = [3.e0]
y = [4.e0]
d_d = 0.0001e0
@show fn6(a, b, c, deepcopy(y))
d_p = (fn6(a, b .+ d_d, c, deepcopy(y)) - fn6(a, b, c, deepcopy(y))) /d_d
@show d_p
d_fn6(a, b, c, deepcopy(y))

#%%
using FiniteDifferences

grad(central_fdm(5, 1), fn6, a, b, c, y)
jacobian(central_fdm(5, 1), fn6, a, b, c, y)