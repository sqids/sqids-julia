module BlocklistTests

using Sqids
using Test

@testset "blocklist" begin

    @testset "if no custom blocklist param, use the default blocklist" begin
        config = Sqids.configure()
        @test Sqids.decode(config, "aho1e") == [4572721]
        @test Sqids.encode(config, [4572721]) == "JExTR"
    end

    @testset "if an empty blocklist param passed, don't use any blocklist" begin
        config = Sqids.configure(blocklist=[])
        @test Sqids.decode(config, "aho1e") == [4572721]
        @test Sqids.encode(config, [4572721]) == "aho1e"
    end

    @testset "if a non-empty blocklist param passed, use only that" begin
        config = Sqids.configure(blocklist=["ArUO"])
        @test Sqids.decode(config, "aho1e") == [4572721]
        @test Sqids.encode(config, [4572721]) == "aho1e"
        @test Sqids.decode(config, "ArUO") == [100000]
        @test Sqids.encode(config, [100000]) == "QyG4"
        @test Sqids.decode(config, "QyG4") == [100000]
    end

    @testset "blocklist" begin
        config = Sqids.configure(blocklist=[
            "JSwXFaosAN",  # normal result of 1st encoding, let's block that word on purpose
            "OCjV9JK64o",  # result of 2nd encoding
            "rBHf",  # result of 3rd encoding is `4rBHfOiqd3`, let's block a substring
            "79SM",  # result of 4th encoding is `dyhgw479SM`, let's block the postfix
            "7tE6",  # result of 4th encoding is `7tE6jdAHLe`, let's block the prefix
        ])
        @test Sqids.encode(config, [1_000_000, 2_000_000]) == "1aYeB7bRUt"
        @test Sqids.decode(config, "1aYeB7bRUt") == [1_000_000, 2_000_000]
    end

    @testset "decoding blocked words should still work" begin
        config = Sqids.configure(blocklist=["86Rf07", "se8ojk", "ARsz1p", "Q8AI49", "5sQRZO"])
        @test Sqids.decode(config, "86Rf07") == [1, 2, 3]
        @test Sqids.decode(config, "se8ojk") == [1, 2, 3]
        @test Sqids.decode(config, "ARsz1p") == [1, 2, 3]
        @test Sqids.decode(config, "Q8AI49") == [1, 2, 3]
        @test Sqids.decode(config, "5sQRZO") == [1, 2, 3]
    end

    @testset "match against a short blocked word" begin
        config = Sqids.configure(blocklist=["pnd"])
        @test Sqids.decode(config, Sqids.encode(config, [1000])) == [1000]
    end

    @testset "blocklist filtering in constructor" begin
        config = Sqids.configure(alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ", blocklist=["sxnzkl"])

        id = Sqids.encode(config, [1, 2, 3])
        numbers = Sqids.decode(config, id)

        @test id == "IBSHOZ"  # without blocklist, would've been "SXNZKL"
        @test numbers == [1, 2, 3]
    end

    @testset "max encoding attempts" begin
        config = Sqids.configure(alphabet="abc", minLength=3, blocklist=["cab", "abc", "bca"])
        @test_throws ArgumentError begin
            Sqids.encode(config, [0])
        end
        @static if VERSION ≥ v"1.8.0"
            @test_throws "Reached max attempts to re-generate the ID" begin
                Sqids.encode(config, [0])
            end
        end
    end
end

end  # module BlocklistTests