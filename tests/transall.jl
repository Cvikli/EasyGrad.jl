

init_trunc_norm(mean, std, low, high; seed=nothing) = (shape) -> begin
	reshape(rand(Float32, 
							MersenneTwister(seed), 
							truncated(Normal(mean, std), low, high), 
							prod(shape)), 
					shape...)
end

# TR 0
noop(a1,a2, o) = begin
end

# TR 1
addop(a1,a2,o) = begin
	o .+= a1 .+ a2
end
TR1 = :(o .+= a1 .+ a2)
TR2 = :(o .+= a1 .* a2)

# TR 2
prodop(a1,a2,o) = begin
	o .+= a1 .* a2
end

# TR 3
biasaddop(a1,a2,o) = begin
	w1 = init_trunc_norm(0.51, 0.02, 0.151)(size(a1))
	o .+= a1 .+ a2 .+ w1 
end

# TR 4
biasaddprodop(a1,a2,o) = begin
	w1 = init_trunc_norm(0.51, 0.02, 0.151)(size(a1))
	o .+= a1 .* (a2 .+ w1) 
end

# TR 5
biasaddprodop(a1,a2,o) = begin
	w1 = init_trunc_norm(0.51, 0.02, 0.151)(size(a1))
	o .+= 1 ./ (a1 .+ a2 .+ w1) 
end

# TR 8
reluop(a1,a2,o) = begin
	if a1 > 0
		o .+= a1
	end 
end

# TR 9
mulmulreluop(a1,a2,o) = begin
	p1 = init_trunc_norm(0.51, 0.02, 0.151)(size(a1)) 
	p2 = init_trunc_norm(0.51, 0.02, 0.151)(size(a2)) 
	tmp = a1 .* p1 .+ a2 .* p2
	if tmp > 0
		o .+= tmp
	end 
end

# TR 10
mulmulreluop(a1,a2,o) = begin
	p1 = init_trunc_norm(0.51, 0.02, 0.151)(size(a1)) 
	p2 = init_trunc_norm(0.51, 0.02, 0.151)(size(a2)) 
	o .+= a1 .* p1 .+ a2 .* p2
end


