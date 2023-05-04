using Boilerplate: @typeof

# dump(Meta.parse("fn(x,y)"))
# Meta.show_sexpr(Meta.parse("fn(x,y)"))
# Meta.show_sexpr(Meta.parse("a.b"))

sexpr(ex::QuoteNode) = ex.value
sexpr(ex::Expr) = [ex.head, [sexpr(arg) for arg in ex.args]...]
sexpr(ex) = ex

parss(str) = Meta.show_sexpr(Meta.parse(str))
pars(str) = sexpr(Meta.parse(str))

to_dict(x, d...) = Dict{Any,Any}(x => to_dict(d...))
to_dict(d) = d

IteratorSplitter(x::Vector) = enumerate(x)
IteratorSplitter(x::Union{Dict, Pair}) = x
pathtree(depth) = join([d ? "│  " : "   " for d in depth],"")
easy_print_tree(d, depth=Bool[]) = println(pathtree(depth), "└─ ",d)
easy_print_tree(d::Union{Dict, Pair, Vector}, depth=Bool[]) = begin
	lastidx = length(d)
	i=1
	for (k,v) in IteratorSplitter(d)
		last_mark = lastidx == i 
		println(pathtree(depth), last_mark ? "└─ " : "├─ " ,  k)
		easy_print_tree(v, [depth..., last_mark==0])
		i+=1
	end
end
AST_map = Dict{Any,Any}()
# #%%
# Meta.show_sexpr(Meta.parse("add.c"));println()
# Meta.show_sexpr(Meta.parse("add.(b,b)"));println()
# #%%

examples = [
	# "y=a+b*v.b",
"x=4;y=3;z=2"																# (toplevel (= x 4) (= y 3) (= z 2))
"x=y+6"																			# (= x (call + y 6))
"x,y=y+6,x*2"																# (= (tuple x y) (tuple (call + y 6) (call * x 2)))
"x::Int,y::Float32=(y+6)::Int,x*2"					# (= (tuple (:: x Int) (:: y Float32)) (tuple (:: (call + y 6) Int) (call * x 2)))
"x::Array{Float32,3},y=y+6,x*2"							# (= (tuple (:: x (curly Array Float32 3)) y) (tuple (call + y 6) (call * x 2)))
"(x,z)=y+6"																	# (= (tuple x z) (call + y 6))
"x::Float32=y+6"														# (= (:: x Float32) (call + y 6))
"x::Vector{Array{Float32,4}}=y+6"						# (= (:: x (curly Vector (curly Array Float32 4))) (call + y 6))
"x::Tuple{Int,Float32,Array{Float32,4}}=y+6"# (= (:: x (curly Tuple Int Float32 (curly Array Float32 4))) (call + y 6))
"f(x)"																			# (call f x)
"g(x)= 6"																		# (= (call g x) (block 6))
"h(x) = begin 6 end"												# (= (call h x) (block 6))
"i(x,y,z) = begin 6 end"										# (= (call i x y z) (6))
"function i(x) 6 end"												# (function (call i x) (block 6))
"function j(x::N) where N 6 end"						# (function (where (call j (:: x N)) N) (block 6))
"function k(x::N) where {N} 6 end"					# (function (where (call k (:: x N)) N) (block 6))
"(x) -> x+6"																# (-> x (block (call + x 6)))
"f(x, y=1, z=2)"													  # (call f x (kw y 1) (kw z 2))
"f(x; y=1)"																	# (call f (parameters (kw y 1)) x)
"f(x...)"																		# (call f (... x))
"1+2"																				# (call + 1 2)
"(x+x)+y"																		# (call + (call + x x) y)
"sqrt(5)"																		# (call sqrt 5)
"sqrt([3,5])"																# (call sqrt (vect 3 5))
"sqrt(x)"																		# (call sqrt x)
"5 |> sqrt"																	# (call |> 5 sqrt)
"x |> sqrt"																	# (call |> x sqrt)
"[3,5] .|> sqrt"														# (call .|> (vect 3 5) sqrt)
"x .|> sqrt"																# (call .|> x sqrt)
"sqrt.(5)"																	# (. sqrt (tuple 5))
"sqrt.([3,5])"															# (. sqrt (tuple (vect 3 5)))
"sqrt.(x)"																	# (. sqrt (tuple x))
"enumerate(x)"															# (call enumerate x)
"x+y"																				# (call + x y)
"x.+y"																			# (call .+ x y)
"x*y"																				# (call * x y)
"x.*y"																			# (call .* x y)
"a+b+c+d"																		# (call + a b c d)
"2x"																				# (call * 2 x)
"a&&b"																			# (&& a b)
"x += 1"																		# (+= x 1)
"x .+= 1"																		# (.+= x 1)
"a ? 1 : 2"																	# (if a 1 2)
"if 2==1 b end"															# (if (call == 2 1) (block b))
"if 2==1 b else c end"											# (if (call == 2 1) (block b) (block c))
"if 2==1 b elseif c d end"									# (if (call == 2 1) (block b) (elseif (block c) (block d)))
"if 2==1 b elseif c d else e end"						# (if (call == 2 1) (block b) (elseif (block c) (block d) (block e)))
"for i in 1:10 b = d end"										# (for (= i (call : 1 10)) (block (= b d)))
"for i in lists b = d end"									# (for (= i lists) (block (= b d)))
"a:b"																				# (call : a b)
"a:b:c"																			# (call : a b c)
"a,b"																				# (tuple a b)
"a==b"																			# (call == a b)
"1<i<=n"																		# (comparison 1 < i <= n)
"add.(b,b)"																	# (. add (tuple b b))
"a.b"																				# (. a b)
"a[i]"																			# (ref a i)
"a[2:5]"																		# (ref a (call : 2 5))
"a[3:end]"																	# (ref a (call : 3 end))
"a::Float32"																# (:: a Float32)
"T[i;j]"																		# (typed_vcat T i j)
"T[i j]"																		# (typed_hcat T i j)
"T[a b; c d]"																# (typed_vcat T (row a b) (row c d))
"Type{b}"																		# (curly Type b)
"Type{b;c}"																	# (curly Type (parameters c) b)
"[x]"																				# (vect x)		
"[x,y]"																			# (vect x y)
"[x;y]"																			# (vcat x y)
"[x y]"																			# (hcat x y)
# "[x y; z t]"															# (vcat (row x y) (row z t))
"[y for y in 1:10]"													# (comprehension (generator y (= y (call : 1 10))))
"[y for y in z]"														# (comprehension (generator y (= y z)))
"[y + y for y in z]"												# (comprehension (generator (call + y y) (= y z)))
"[y for y in z, a in b]"										# (comprehension (generator y (= y z) (= a b)))
"T[y for y in z]"														# (typed_comprehension T (generator y (= y z)))
"T[y + y for y in z]"												# (typed_comprehension T (generator (call + y y) (= y z)))
"T[i,b]"																		# (ref T i b)
"(a, b, c)"																	# (tuple a b c)
"(a; b; c)"																	# (block a (block b c))
"@m x y	"																		# (macrocall @m x y)

]


merge_dict(a::Vector,b::Vector) = a = b
merge_dict(a::Symbol,b::Dict{Any,Any}) = a = b
merge_dict(a::Dict{Any,Any},b::Dict{Any,Any}) = begin 
	for (k,v) in b 
		if haskey(a,k) 
			merge_dict(a[k],v)
		else
			a[k] = v
		end
	end
end
function show_vector_sans_type(io, v::AbstractVector)
	print(io, "(")
	for (i, elt) in enumerate(v)
			i > 1 && print(io, " ")
			if elt isa AbstractVector
				show_vector_sans_type(io, elt)
			else
				print(io, elt)
			end
	end
	print(io, ")")
end
show_vector_sans_type(v::AbstractVector) = show_vector_sans_type(stdout, v)


for exa in examples
	parsed = pars(exa)
	show_vector_sans_type(parsed)
	println()
	!(haskey(AST_map, parsed[1])) &&	(AST_map[parsed[1]] = [])
	push!(AST_map[parsed[1]] ,(exa, parsed[2:end]))
end
using Printf
for (ast_key, ast_value) in AST_map
	for (exa,a) in ast_value
		@printf("%34s  %17s  ", exa, String(ast_key))
		show_vector_sans_type(a)
		println()
	end
end
# print_tree(AST_map)
# easy_print_tree(AST_map)


#%%
# print_tree(Dict("a"=>"b","b"=>[Dict("a"=>"b","b"=>['c','d'],"q"=>['c','d']),'d']))
# easy_print_tree(Dict("a"=>"b","b"=>[Dict("a"=>"b","b"=>['c','d',"t"],"q"=>['c','d',Dict("e"=>2,"w"=>Dict("e"=>2,"w"=>4),"y"=>4)],"z"=>6),'d',Dict("e"=>2,"q"=>[5,7,5,3],"w"=>5)]))
