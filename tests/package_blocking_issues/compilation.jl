
function asd1(X,Y)
	X .+= Y
	return
end
function asd2(X,Y)
	X .+= Y
	X .+= Y
	return
end
function asd3(X,Y)
	X .+= Y
	X .+= Y
	X .+= Y
	return
end
function rawasd3(X,Y)
	X += Y
	X += Y
	X += Y
	return
end

function asd32(X,Y)
	X .+= Y .+ Y .+ Y .+ Y
	X .+= Y .+ Y .+ Y .+ Y
	X .+= Y .+ Y .+ Y .+ Y
	return
end
function asd34(X,Y)
	X .+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
	X .+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
	X .+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
	return
end
function one_XY(X,Y)
	X.+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
end
function asd38X(X,Y)
	one_XY(X,Y)
	one_XY(X,Y)
	one_XY(X,Y)
end
function asd38(X,Y)
	X.+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
	X.+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
	X.+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
	return
end
function asd18(X,Y)
	X .+= Y .+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y.+ Y .+ Y .+ Y
end
function rawasd18(X,Y)
	X += Y + Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y
end
add(acc, val) = acc+val
function fnasd18(X,Y)
	e=Y
	for i in 1:21
		e.+=Y
	end
	X .+= e
end
function fnrawasd18(X,Y)
	e=Y
	for i in 1:21
		e+=Y
	end
	X += e
end
function asddot38(X,Y)
	@. X += Y + Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y
	@. X += Y + Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y
	@. X += Y + Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y
	return
end
function forasddot18(X,Y)
	for i in 1:3
		@. X += + Y + Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y
	end
end
function asddot18(X,Y)
	@. X += Y + Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y+ Y + Y + Y
end

x=randn(20)
y=randn(20)
# @time asd1(x,y)
# @time asd2(x,y)
# @time asd3(x,y)
# @time rawasd3(x,y)
# @time asd32(x,y)
# @time asd34(x,y)
# @time asd34(x,y)
@time asd38(x,y)
@time asd38(x,y)
@time one_XY(x,y)
@time asd38X(x,y)
@time asd38X(x,y)
# @time asddot38(x,y)
# @time asddot18(x,y)
# @time asddot18(x,y)
# @time fnasd18(x,y)
# @time fnasd18(x,y)
# @time fnrawasd18(x,y)
# @time fnrawasd18(x,y)
# @time forasddot18(x,y)
# @time forasddot18(x,y)
# @time asddot38(x,y)
# @time asddot38(x,y)
# @time rawasd18(x,y)
# @time rawasd18(x,y)
using InteractiveUtils
# @code_warntype rawasd18(x,y)
