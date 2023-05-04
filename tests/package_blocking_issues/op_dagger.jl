using Distributed; 
# addprocs() # get us some workers
using Dagger

@show "heyy"
# do some stuff in parallel!
a = Dagger.@spawn 1+3
b = Dagger.@spawn rand(a, 4)
c = Dagger.@spawn sum(b)
fetch(c) # some number!
@show "heyys"

