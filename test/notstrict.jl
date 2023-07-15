module NotStrictTests

using Sqids
using Test

# sqids-julia unique feature: `strict` parameter
# By specifying `strict=false`, the upper limit of values is eliminated.
# Then the integer type is automatically expanded and uses types such as `BigInt` a multi-precision integer type.

@testset "NotStrict" begin

    @testset "strict or not" begin
        config_default = Sqids.configure()
        config_strict = Sqids.configure(strict=true)
        config_not_strict = Sqids.configure(strict=false)

        @test Sqids.isstrict(config_default)
        @test Sqids.isstrict(config_strict)
        @test !Sqids.isstrict(config_not_strict)
    end

    @testset "simple" begin
        config = Sqids.configure(strict=false)

        numbers = [1, 2, 3]
        id = "8QRLaD"

        @test Sqids.encode(config, numbers) == id
        @test Sqids.decode(config, id) == numbers
    end

    @testset "encode/decode out-of-range numbers" begin
        config = Sqids.configure(strict=false)

        @test_throws ArgumentError Sqids.encode(config, [Sqids.minValue(config) - 1])
        @test_throws MethodError Sqids.maxValue(config)
        @test Sqids.encode(config, [widen(typemax(Int64)) + 1]) == "piF3yT7tOtoO"
        @test Sqids.decode(config, "piF3yT7tOtoO") == [widen(typemax(Int64)) + 1]
        @test Sqids.encode(config, [big(typemax(Int128)) + 1]) == "Vpe9SEjlSQreM3A2DNrRLZt"
        @test Sqids.decode(config, "Vpe9SEjlSQreM3A2DNrRLZt") == [big(typemax(Int128)) + 1]
    end

    @testset "different inputs" begin
        config = Sqids.configure(strict=false)

        numbers = BigInt[0, 0, 0, 1, 2, 3, 100, 1_000, 100_000, 1_000_000, big(typemax(Int)) + 1, big(typemax(Int128)) + 1]
        @test Sqids.decode(config, Sqids.encode(config, numbers)) == numbers
    end

end

end  # module ShuffleTests