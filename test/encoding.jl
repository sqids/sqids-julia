module EncodingTests

using Sqids
using Test

@testset "Encoding" begin

    @testset "simple" begin
        config = Sqids.configure()

        numbers = [1, 2, 3]
        id = "8QRLaD"

        @test Sqids.encode(config, numbers) == id
        @test Sqids.decode(config, id) == numbers
    end

    @testset "different inputs" begin
        config = Sqids.configure()

        # numbers = [0, 0, 0, 1, 2, 3, 100, 1_000, 100_000, 1_000_000, Sqids.maxValue()]
        numbers = [0, 0, 0, 1, 2, 3, 100, 1_000, 100_000, 1_000_000, typemax(Int)]
        @test Sqids.decode(config, Sqids.encode(config, numbers)) == numbers
    end

    @testset "incremental numbers" begin
        config = Sqids.configure()

        ids = Dict(
            "bV" => [0],
            "U9" => [1],
            "g8" => [2],
            "Ez" => [3],
            "V8" => [4],
            "ul" => [5],
            "O3" => [6],
            "AF" => [7],
            "ph" => [8],
            "n8" => [9]
        )

        for (id, numbers) in ids
            @test Sqids.encode(config, numbers) == id
            @test Sqids.decode(config, id) == numbers
        end
    end

    @testset "incremental numbers, same index 0" begin
        config = Sqids.configure()

        ids = Dict(
            "SrIu" => [0, 0],
            "nZqE" => [0, 1],
            "tJyf" => [0, 2],
            "e86S" => [0, 3],
            "rtC7" => [0, 4],
            "sQ8R" => [0, 5],
            "uz2n" => [0, 6],
            "7Td9" => [0, 7],
            "3nWE" => [0, 8],
            "mIxM" => [0, 9]
        )

        for (id, numbers) in ids
            @test Sqids.encode(config, numbers) == id
            @test Sqids.decode(config, id) == numbers
        end
    end

    @testset "incremental numbers, same index 1" begin
        config = Sqids.configure()

        ids = Dict(
            "SrIu" => [0, 0],
            "nbqh" => [1, 0],
            "t4yj" => [2, 0],
            "eQ6L" => [3, 0],
            "r4Cc" => [4, 0],
            "sL82" => [5, 0],
            "uo2f" => [6, 0],
            "7Zdq" => [7, 0],
            "36Wf" => [8, 0],
            "m4xT" => [9, 0]
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

    @testset "decoding an invalid ID with a repeating reserved character" begin
        config = Sqids.configure()

        @test Sqids.decode(config, "fff") == Int[]
    end

    @testset "encode out-of-range numbers" begin
        config = Sqids.configure()

        @test_throws ArgumentError Sqids.encode(config, [Sqids.minValue(config) - 1])
        # @test_throws ArgumentError Sqids.encode(config, [Sqids.maxValue(config) + 1])
        @test_throws ArgumentError Sqids.encode(config, [big(Sqids.maxValue(config)) + 1])
    end

    @testset "decode to out-of-range numbers" begin
        config = Sqids.configure()

        @test_throws ArgumentError Sqids.decode(config, "piF3yT7tOtoO")  # decoded to Int128[9223372036854775808] if not-strict mode
        @test_throws ArgumentError Sqids.decode(config, "Vpe9SEjlSQreM3A2DNrRLZt")  # decoded to BigInt[170141183460469231731687303715884105728] if not-strict mode
    end
end

end  # module EncodingTests