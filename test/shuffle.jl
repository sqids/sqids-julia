module ShuffleTests

using Sqids
using Test

@testset "Shuffle" begin

    @testset "default shuffle, checking for randomness" begin
        @test Sqids._shuffle(Sqids.DEFAULT_ALPHABET) == "fwjBhEY2uczNPDiloxmvISCrytaJO4d71T0W3qnMZbXVHg6eR8sAQ5KkpLUGF9"

        # In Julia, for performance reasons, we provide a `_shuffle!()` function that destructively manipulates arrays of `Char` type.
        chars = collect(Sqids.DEFAULT_ALPHABET)
        @assert chars isa AbstractVector{Char}
        Sqids._shuffle!(chars)
        @test chars == collect("fwjBhEY2uczNPDiloxmvISCrytaJO4d71T0W3qnMZbXVHg6eR8sAQ5KkpLUGF9")
    end

    @testset "numbers in the front, another check for randomness" begin
        i = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        o = "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf"
        @test Sqids._shuffle(i) == o
    end

    @testset "swapping front 2 characters" begin
        i1 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        i2 = "1023456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

        o1 = "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf"
        o2 = "xI3RUayk1MSolQK7e09zYmFpVXPwHiNrdfBJ6ZAT5uCWbntgcDsEqjv4hLG28O"

        @test Sqids._shuffle(i1) == o1
        @test Sqids._shuffle(i2) == o2
    end

    @testset "swapping last 2 characters" begin
        i1 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        i2 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY"

        o1 = "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf"
        o2 = "x038UaykZMSolIK7RzcbYmFpgXEPHiNr1d2VfGAT5uJWQetjvDswqn94hLC6BO"

        @test Sqids._shuffle(i1) == o1
        @test Sqids._shuffle(i2) == o2
    end

    @testset "short alphabet" begin
        @test Sqids._shuffle("0123456789") == "4086517392"
    end

    @testset "really short alphabet" begin
        @test Sqids._shuffle("12345") == "24135"
    end

    @testset "lowercase alphabet" begin
        i = "abcdefghijklmnopqrstuvwxyz"
        o = "lbfziqvscptmyxrekguohwjand"
        @test Sqids._shuffle(i) == o
    end

    @testset "uppercase alphabet" begin
        i = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        o = "ZXBNSIJQEDMCTKOHVWFYUPLRGA"
        @test Sqids._shuffle(i) == o
    end

    @testset "bars" begin
        @test Sqids._shuffle("▁▂▃▄▅▆▇█") == "▂▇▄▅▆▃▁█"
    end

    @testset "bars with numbers" begin
        @test Sqids._shuffle("▁▂▃▄▅▆▇█0123456789") == "14▅▂▇320▆75▄█96▃8▁"
    end

end

end  # module ShuffleTests