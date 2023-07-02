module AlphabetTests

using Sqids
using Test

@testset "Alphabet" begin
    
    @testset "simple" begin
        config = Sqids.configure(alphabet="0123456789abcdef")

        numbers = [1, 2, 3]
        id = "4d9fd2"

        @test Sqids.encode(config, numbers) == id
        @test Sqids.decode(config, id) == numbers
    end

    @testset "short alphabet" begin
        config = Sqids.configure(alphabet="abcde")

        numbers = [1, 2, 3]
        @test Sqids.decode(config, Sqids.encode(config, numbers)) == numbers
    end

    @testset "long alphabet" begin
        config = Sqids.configure(alphabet="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_+|{}[];:\'\"/?.>,<`~")

        numbers = [1, 2, 3]
        @test Sqids.decode(config, Sqids.encode(config, numbers)) == numbers
    end

    @testset "repeating alphabet characters" begin
        @test_throws ArgumentError begin
            Sqids.configure(alphabet="aabcdefg")
        end
    end

    @testset "too short of an alphabet" begin
        @test_throws ArgumentError begin
            Sqids.configure(alphabet="abcd")
        end
    end

end

end  # module AlphabetTests