x = 2
#%%
:(1 + $x)
#%%
let y = :x
	:(1 + y), :(1 + $y)
end
#%%
(
    :(1 + $x),                        # Quasiquotation
    Expr(:call, :+, 1, Expr(:$, :x)), # True quotation
)
#%%
:x, typeof(:(x))
#%%
:(:x), typeof(:(:x))
#%%
macro true_quote(e)
	QuoteNode(e)
end
#%%
let y = :x
	(
			@true_quote(1 + $y),
			:(1 + $y),
	)
end
#%%
macro bad_macro()
x = rand()
:($x)
end
#%%
for i in 1:10
	println((i, @bad_macro()))
end
#%%
@macroexpand @bad_macro()
#%%
macro assign(name, e)
	Expr(:(=), name, e)
end
@assign(z, 1)
#%%
z
#%%
@macroexpand(@assign(z, 1))
#%%
let name = :z, e = :(1)
	Expr(:(=), name, e)
end
#%%
esc(:x)
esc(:(1 + x))
#%%
macro assign(name, e)
	Expr(:(=), esc(name), e)
end
@assign(z, 1)
#%%
z
#%%
macro assign(name, e)
	esc(Expr(:(=), name, e))
end
@assign(as, 1)
#%%
as
#%%

macro foo(e)
	println("In foo")
	e
end

macro bar(e)
	println("In bar")
	e
end
@foo(@bar(1))
#%%

