module EncodingTests

using Sqids
using Test

@testset "Encoding" begin

    @testset "simple" begin
        config = Sqids.configure()

        numbers = [1, 2, 3]
        id = "86Rf07"

        @test Sqids.encode(config, numbers) == id
        @test Sqids.decode(config, id) == numbers
    end

    @testset "different inputs" begin
        config = Sqids.configure()

        numbers = [0, 0, 0, 1, 2, 3, 100, 1_000, 100_000, 1_000_000, typemax(Int)]
        @test Sqids.decode(config, Sqids.encode(config, numbers)) == numbers
    end

    @testset "incremental numbers" begin
        config = Sqids.configure()

        ids = Dict(
            "bM" => [0],
            "Uk" => [1],
            "gb" => [2],
            "Ef" => [3],
            "Vq" => [4],
            "uw" => [5],
            "OI" => [6],
            "AX" => [7],
            "p6" => [8],
            "nJ" => [9],
        )

        for (id, numbers) in ids
            @test Sqids.encode(config, numbers) == id
            @test Sqids.decode(config, id) == numbers
        end
    end

    @testset "incremental numbers, same index 0" begin
        config = Sqids.configure()

        ids = Dict(
            "SvIz" => [0, 0],
            "n3qa" => [0, 1],
            "tryF" => [0, 2],
            "eg6q" => [0, 3],
            "rSCF" => [0, 4],
            "sR8x" => [0, 5],
            "uY2M" => [0, 6],
            "74dI" => [0, 7],
            "30WX" => [0, 8],
            "moxr" => [0, 9],
        )

        for (id, numbers) in ids
            @test Sqids.encode(config, numbers) == id
            @test Sqids.decode(config, id) == numbers
        end
    end

    @testset "incremental numbers, same index 1" begin
        config = Sqids.configure()

        ids = Dict(
            "SvIz" => [0, 0],
            "nWqP" => [1, 0],
            "tSyw" => [2, 0],
            "eX68" => [3, 0],
            "rxCY" => [4, 0],
            "sV8a" => [5, 0],
            "uf2K" => [6, 0],
            "7Cdk" => [7, 0],
            "3aWP" => [8, 0],
            "m2xn" => [9, 0],
        )

        for (id, numbers) in ids
            @test Sqids.encode(config, numbers) == id
            @test Sqids.decode(config, id) == numbers
        end
    end

    @testset "multi input" begin
        config = Sqids.configure()

        numbers = collect(0:99)  # == [0, 1, … , 99]
        output = Sqids.decode(config, Sqids.encode(config, numbers))
        @test numbers == output
    end

    @testset "multi input 2 (input range object)" begin
        config = Sqids.configure()

        numbers = 0:99  # ≒ [0, 1, … , 99]
        output = Sqids.decode(config, Sqids.encode(config, numbers))
        @test numbers == output
    end

    @testset "encoding no numbers" begin
        config = Sqids.configure()

        @test Sqids.encode(config, Int[]) == ""
    end

    @testset "decoding empty string" begin
        config = Sqids.configure()

        @test Sqids.decode(config, "") == Int[]
    end

    @testset "decoding an ID with an invalid character" begin
        config = Sqids.configure()

        @test Sqids.decode(config, "*") == Int[]
    end

    @testset "encode out-of-range numbers" begin
        config = Sqids.configure()

        @test_throws ArgumentError Sqids.encode(config, [-1])
        # @test_throws ArgumentError Sqids.encode(config, [typemax(Int) + 1])
        @test_throws ArgumentError Sqids.encode(config, [widen(typemax(Int)) + 1])
        @static if VERSION ≥ v"1.8.0"
            @test_throws r"Encoding supports numbers between 0 and \d+" Sqids.encode(config, [-1])
            @test_throws "Encoding supports numbers between 0 and $(typemax(Int))" Sqids.encode(config, [widen(typemax(Int)) + 1])
        end
    end

    # TODO: Check to activate or not to activate this test
    # @testset "decode to out-of-range numbers" begin
    #     config = Sqids.configure()

    #     @test_throws ArgumentError Sqids.decode(config, "piF3yT7tOtoO")  # decoded to Int128[9223372036854775808] if not-strict mode
    #     @test_throws ArgumentError Sqids.decode(config, "Vpe9SEjlSQreM3A2DNrRLZt")  # decoded to BigInt[170141183460469231731687303715884105728] if not-strict mode
    # end
end

end  # module EncodingTests