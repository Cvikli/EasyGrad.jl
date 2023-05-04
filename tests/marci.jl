using CodeTracking
using CodeTracking: @which, whereis
using EasyGrad: @easygrad, @code_expr_easy, process_body

using InteractiveUtils

fn(x, y) = begin
	# y=y*y*3+y*x
	x= 6 .* x
end

# @easygrad fn(9)
a,b = [1f0], [2f0]
println("--------------")
println(@code_warntype fn(a,b))
println(@code_lowered fn(a,b))
println(@code_typed fn(a,b))
;

#%%
using FastClosures

# code_warntype problem
function f1()
	if true
	end
	r = 1
	r -= 1
	cb = ()-> begin
		# r -= 1
		r
	end
  cb
end

# code_warntype clean
function f2()
	if true
	end
	r = 1
	r -= 1
	cb = @closure ()-> begin
		# r -= 1
		r
	end
	cb
end

@code_warntype f1()()
@code_warntype f2()()
# @code_warntype f3()()
#%%
using EasyGrad: RefClosures
# # code_warntype clean
function f3()
    if true
    end
    r = 1
		a = f2()
    cb = @refclosure ()-> begin
			r -= 1
			r
		end
		cb
end
@code_warntype f3()()
#%%
cb = f3()

@show cb()
@show cb()
@show cb()

function genfunctions()
	preallocated = zeros(100)
	f3() = begin
		cb = @refclosure ()-> begin
		preallocated .-= 1
	end
	end
end