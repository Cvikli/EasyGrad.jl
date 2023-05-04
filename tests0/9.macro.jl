module MacroTests
using CodeTracking
using FastClosures
import EasyGrad
fn() = begin
	x = 1
	@closure () -> x*2 
end

Meta.show_sexpr(Meta.parse(@code_string fn()))
end