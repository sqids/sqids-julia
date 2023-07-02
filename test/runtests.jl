using Sqids
using Test

@testset "Sqids.jl" begin
    include("encoding.jl")
    include("alphabet.jl")
    include("minlength.jl")
    include("blacklist.jl")
    include("shuffle.jl")
    include("uniques.jl")
end