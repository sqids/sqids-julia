module MinLengthTests

using Sqids
using Test

@testset "minLength" begin

    @testset "simple" begin
        config = Sqids.configure(minLength=length(Sqids.DEFAULT_ALPHABET))

        numbers = [1, 2, 3]
        id = "75JILToVsGerOADWmHlY38xvbaNZKQ9wdFS0B6kcMEtnRpgizhjU42qT1cd0dL"

        @test Sqids.encode(config, numbers) == id
        @test Sqids.decode(config, id) == numbers
    end    

    @testset "incremental numbers" begin
        config = Sqids.configure(minLength=length(Sqids.DEFAULT_ALPHABET))

        ids = Dict(
            "jf26PLNeO5WbJDUV7FmMtlGXps3CoqkHnZ8cYd19yIiTAQuvKSExzhrRghBlwf" => [0, 0],
            "vQLUq7zWXC6k9cNOtgJ2ZK8rbxuipBFAS10yTdYeRa3ojHwGnmMV4PDhESI2jL" => [0, 1],
            "YhcpVK3COXbifmnZoLuxWgBQwtjsSaDGAdr0ReTHM16yI9vU8JNzlFq5Eu2oPp" => [0, 2],
            "OTkn9daFgDZX6LbmfxI83RSKetJu0APihlsrYoz5pvQw7GyWHEUcN2jBqd4kJ9" => [0, 3],
            "h2cV5eLNYj1x4ToZpfM90UlgHBOKikQFvnW36AC8zrmuJ7XdRytIGPawqYEbBe" => [0, 4],
            "7Mf0HeUNkpsZOTvmcj836P9EWKaACBubInFJtwXR2DSzgYGhQV5i4lLxoT1qdU" => [0, 5],
            "APVSD1ZIY4WGBK75xktMfTev8qsCJw6oyH2j3OnLcXRlhziUmpbuNEar05QCsI" => [0, 6],
            "P0LUhnlT76rsWSofOeyRGQZv1cC5qu3dtaJYNEXwk8Vpx92bKiHIz4MgmiDOF7" => [0, 7],
            "xAhypZMXYIGCL4uW0te6lsFHaPc3SiD1TBgw5O7bvodzjqUn89JQRfk2Nvm4JI" => [0, 8],
            "94dRPIZ6irlXWvTbKywFuAhBoECQOVMjDJp53s2xeqaSzHY8nc17tmkLGwfGNl" => [0, 9],
        )

        for (id, numbers) in ids
            @test Sqids.encode(config, numbers) == id
            @test Sqids.decode(config, id) == numbers
        end
    end

    @testset "min lengths" begin
        _config = Sqids.configure()
        for minLength in [0, 1, 5, 10, length(Sqids.DEFAULT_ALPHABET)]
            for numbers in [
                [Sqids.minValue(_config)],
                [0, 0, 0, 0, 0],
                [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                [100, 200, 300],
                [1_000, 2_000, 3_000],
                [1_000_000],
                # [Sqids.maxValue()],
                [typemax(Int)],
            ]
                config = Sqids.configure(minLength=minLength)

                id = Sqids.encode(config, numbers)
                @test length(id) >= minLength
                @test Sqids.decode(config, id) == numbers
            end
        end
    end

    @testset "out-of-range invalid min length" begin
        @test_throws ArgumentError Sqids.configure(minLength=-1)
        @test_throws ArgumentError Sqids.configure(minLength=length(Sqids.DEFAULT_ALPHABET) + 1)
    end

end

end  # module MinLengthTests