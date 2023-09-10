module AlphabetTests

using Sqids
using Test

@testset "Alphabet" begin
    
    @testset "simple" begin
        config = Sqids.configure(alphabet="0123456789abcdef")

        numbers = [1, 2, 3]
        id = "489158"

        @test Sqids.encode(config, numbers) == id
        @test Sqids.decode(config, id) == numbers
    end

    @testset "short alphabet" begin
        config = Sqids.configure(alphabet="abc")

        numbers = [1, 2, 3]
        @test Sqids.decode(config, Sqids.encode(config, numbers)) == numbers
    end

    @testset "long alphabet" begin
        config = Sqids.configure(alphabet="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_+|{}[];:\'\"/?.>,<`~")

        numbers = [1, 2, 3]
        @test Sqids.decode(config, Sqids.encode(config, numbers)) == numbers
    end

    @testset "multibyte characters" begin
        @test_throws ArgumentError begin
            Sqids.configure(alphabet="ë1092")
        end
        @static if VERSION ≥ v"1.8.0"
            @test_throws "Alphabet cannot contain multibyte characters" begin
                Sqids.configure(alphabet="ë1092")
            end
        end
    end
    
    @testset "repeating alphabet characters" begin
        @test_throws ArgumentError begin
            Sqids.configure(alphabet="aabcdefg")
        end
        @static if VERSION ≥ v"1.8.0"
            @test_throws "Alphabet must contain unique characters" begin
                Sqids.configure(alphabet="aabcdefg")
            end
        end
    end

    @testset "too short of an alphabet" begin
        @test_throws ArgumentError begin
            Sqids.configure(alphabet="ab")
        end
        @static if VERSION ≥ v"1.8.0"
            @test_throws "Alphabet length must be at least 3" begin
                Sqids.configure(alphabet="ab")
            end
        end
    end

end

end  # module AlphabetTests