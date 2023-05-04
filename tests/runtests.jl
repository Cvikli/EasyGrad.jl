using Test
using Logging

disable_logging(Logging.BelowMinLevel)


@testset "∑" begin
	for testcase in [
		"test_1.1.basic.jl",
		"test.2.1.mutable_3.jl",
		"test.2.2.mutable_func.jl",
		"test.3.1.for.jl",
		"test.3.2.for.refalloc.jl",
		"test.3.3.for.jl",
		"test.3.4.operations.jl",
		# "test.3.4.sum_avx.jl",
		"test.3.5.for_comprehension.jl",
		"test.3.6.for_pb_func.jl",
		"test.3.7.for_nested_pb_func.jl",
		"test.3.8.1.forcompreh_pb_func.jl",
		"test.3.9.for_arrayfill.jl",
		"test.4.indexing.jl",
		"test.4.2.nested_index.jl",
		"test.5.1.if.jl",
		"test.5.2.ternary.jl",
		"test.6.1.func.jl",
		"test.6.2.func.jl",
		"test.6.3.func_variations.jl",
		"test.6.8.func_input.jl",
		"test.7.1.type.jl",
		"test.7.2.where_type.jl",
		# "test.8.1.assignment.jl",
		"test.8.2.tuple_assign.jl",
		"test.9.1.get_field.jl",
		"test.11.secondorder.jl"
	]
		@testset "$testcase" begin
			include("$testcase")
		end
	println("Runnin test of .jl...")
	end
end

;