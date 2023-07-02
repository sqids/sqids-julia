module BlacklistTests

using Sqids
using Test

@testset "blacklist" begin

    @testset "if no custom blacklist param, use the default blacklist" begin
        config = Sqids.configure()
        @test Sqids.decode(config, "sexy") == [200044]
        @test Sqids.encode(config, [200044]) == "d171vI"
    end

    @testset "if an empty blacklist param passed, don't use any blacklist" begin
        config = Sqids.configure(blacklist=[])
        @test Sqids.decode(config, "sexy") == [200044]
        @test Sqids.encode(config, [200044]) == "sexy"
    end

    @testset "if a non-empty blacklist param passed, use only that" begin
        config = Sqids.configure(blacklist=["AvTg"])
        @test Sqids.decode(config, "sexy") == [200044]
        @test Sqids.encode(config, [200044]) == "sexy"
        @test Sqids.decode(config, "AvTg") == [100000]
        @test Sqids.encode(config, [100000]) == "7T1X8k"
        @test Sqids.decode(config, "7T1X8k") == [100000]
    end

    @testset "blacklist" begin
        config = Sqids.configure(blacklist=[
            "8QRLaD",  # normal result of 1st encoding, let's block that word on purpose
            "7T1cd0dL",  # result of 2nd encoding
            "UeIe",  # result of 3rd encoding is `RA8UeIe7`, let's block a substring
            "imhw",  # result of 4th encoding is `WM3Limhw`, let's block the postfix
            "LfUQ",  # result of 4th encoding is `LfUQh4HN`, let's block the prefix
        ])
        @test Sqids.encode(config, [1, 2, 3]) == "TM0x1Mxz"
        @test Sqids.decode(config, "TM0x1Mxz") == [1, 2, 3]
    end

    @testset "decoding blacklisted words should still work" begin
        config = Sqids.configure(blacklist=["8QRLaD", "7T1cd0dL", "RA8UeIe7", "WM3Limhw", "LfUQh4HN"])
        @test Sqids.decode(config, "8QRLaD") == [1, 2, 3]
        @test Sqids.decode(config, "7T1cd0dL") == [1, 2, 3]
        @test Sqids.decode(config, "RA8UeIe7") == [1, 2, 3]
        @test Sqids.decode(config, "WM3Limhw") == [1, 2, 3]
        @test Sqids.decode(config, "LfUQh4HN") == [1, 2, 3]
    end

    @testset "match against a short blacklisted word" begin
        config = Sqids.configure(blacklist=["pPQ"])
        @test Sqids.decode(config, Sqids.encode(config, [1000])) == [1000]
    end

end

end  # module BlacklistTests