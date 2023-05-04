
a, b = randn(1024),randn(1024)
swap_m(a, b) = begin
	t1, t2 = a, b .+ a
	a, b = t1, t2
	# a .= t1
	# b .= t2
	a, b
end
swap(a, b) = a, b = a, b.+a
# @time swap_m(a, b)
# @time swap_m(1, 2)
@btime swap_m($a, $b)
# @time swap(a, b)
# @time swap(a, b)
# @code_native swap(a, b, a)
;
#%%
a, b = randn(1024),randn(1024)
async_tuple(a, b) = begin
	t1, t2 = a, b .+ a
	res = (similar(t1), similar(t2))
	res[1] .+= t1
	res[2] .+= t2
	# a .= t1
	# b .= t2
	res
end
async_tuple_s(a, b) = begin
	res = a, b.+a
end

@btime async_tuple_s($a, $b)
@btime async_tuple($a, $b)
;
