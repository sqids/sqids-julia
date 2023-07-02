module UniquesTests

using Sqids
using Test

const upper = 1_000_000

@testset "uniques" begin

    @testset "uniques, with padding" begin
        config = Sqids.configure(minLength=length(Sqids.DEFAULT_ALPHABET))
        set = Set{String}()

        for i = 0:upper-1
            numbers = [i]
            id = Sqids.encode(config, numbers)
            push!(set, id)
            @test Sqids.decode(config, id) == numbers
        end

        @test length(set) == upper
    end

    @testset "uniques, low ranges" begin
        config = Sqids.configure()
        set = Set{String}()

        for i = 0:upper-1
            numbers = [i]
            id = Sqids.encode(config, numbers)
            push!(set, id)
            @test Sqids.decode(config, id) == numbers
        end

        @test length(set) == upper
    end

    @testset "uniques, high ranges" begin
        config = Sqids.configure()
        set = Set{String}()

        for i = 100_000_000:100_000_000+upper-1
            numbers = [i]
            id = Sqids.encode(config, numbers)
            push!(set, id)
            @test Sqids.decode(config, id) == numbers
        end

        @test length(set) == upper
    end

    @testset "uniques, multi" begin
        config = Sqids.configure()
        set = Set{String}()

        for i = 0:upper-1
            numbers = [i, i, i, i, i]
            id = Sqids.encode(config, numbers)
            push!(set, id)
            @test Sqids.decode(config, id) == numbers
        end

        @test length(set) == upper
    end

end

end  # module UniquesTests