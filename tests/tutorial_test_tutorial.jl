using BoilerplateCvikli: @sizes

function fun(a) 
	a +=2
	println("Okeesd")
	b = randn(Float32, 3,4,2)
	@show b
	@show a
	# @sizes ([b, b])
	c = a .+ b

end

# #%%
# using PyCall

# math = pyimport("math")
# math = pyimport("tensorflow")
# math.sin(2)

# #%%
# findall([1,0,1,1,0])

