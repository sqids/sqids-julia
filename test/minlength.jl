module MinLengthTests

using Sqids
using Test

@testset "minLength" begin

    @testset "simple" begin
        config = Sqids.configure(minLength=length(Sqids.DEFAULT_ALPHABET))

        numbers = [1, 2, 3]
        id = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM"

        @test Sqids.encode(config, numbers) == id
        @test Sqids.decode(config, id) == numbers
    end    

    @testset "incremental" begin
        numbers = [1, 2, 3]
        length_map = Dict(
            6 => "86Rf07",
            7 => "86Rf07x",
            8 => "86Rf07xd",
            9 => "86Rf07xd4",
            10 => "86Rf07xd4z",
            11 => "86Rf07xd4zB",
            12 => "86Rf07xd4zBm",
            13 => "86Rf07xd4zBmi",
            length(Sqids.DEFAULT_ALPHABET) + 0 =>
                "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM",
            length(Sqids.DEFAULT_ALPHABET) + 1 =>
                "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy",
            length(Sqids.DEFAULT_ALPHABET) + 2 =>
                "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf",
            length(Sqids.DEFAULT_ALPHABET) + 3 =>
                "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1",
        )

        for (minLength, id) in length_map
            config = Sqids.configure(minLength=minLength)

            @test Sqids.encode(config, numbers) == id
            @test length(Sqids.encode(config, numbers)) == minLength
            @test Sqids.decode(config, id) == numbers
        end
    end    

    @testset "incremental numbers" begin
        config = Sqids.configure(minLength=length(Sqids.DEFAULT_ALPHABET))

        ids = Dict(
            "SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu" => [0, 0],
            "n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc" => [0, 1],
            "tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ" => [0, 2],
            "eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE" => [0, 3],
            "rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX" => [0, 4],
            "sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2" => [0, 5],
            "uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0" => [0, 6],
            "74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy" => [0, 7],
            "30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS" => [0, 8],
            "moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin" => [0, 9],
        )

        for (id, numbers) in ids
            @test Sqids.encode(config, numbers) == id
            @test Sqids.decode(config, id) == numbers
        end
    end

    @testset "min lengths" begin
        for minLength in [0, 1, 5, 10, length(Sqids.DEFAULT_ALPHABET)]
            for numbers in [
                [0],
                [0, 0, 0, 0, 0],
                [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                [100, 200, 300],
                [1_000, 2_000, 3_000],
                [1_000_000],
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
        @test_throws ArgumentError Sqids.configure(minLength=1_000 + 1)
        @static if VERSION ≥ v"1.8.0"
            @test_throws r"Minimum length has to be between 0 and \d+" Sqids.configure(minLength=-1)
            @test_throws "Minimum length has to be between 0 and $(Sqids.MIN_LENGTH_LIMIT)" Sqids.configure(minLength=Sqids.MIN_LENGTH_LIMIT + 1)
        end
    end

end

end  # module MinLengthTests