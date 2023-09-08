module Sqids

export encode, decode

using Base.Checked: mul_with_overflow, add_with_overflow

include("Blocklists.jl")

const DEFAULT_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
const MIN_VALUE = 0
const MIN_LENGTH_LIMIT = 255  # Int(typemax(UInt8))

_shuffle(alphabet::AbstractString) = String(_shuffle!(collect(alphabet)))
function _shuffle!(chars::Vector{Char})
    L = length(chars)
    for i = 0:L-2
        j = L - i - 1
        r = (i * j + Int(chars[i + 1]) + Int(chars[j + 1])) % L
        chars[i + 1], chars[r + 1] = chars[r + 1], chars[i + 1]
    end
    chars
end

"""
    Sqids.Configuration

Sqids' parameter-configuration.  
Be sure to place the instance as the 1st argument of [`encode`](@ref) and [`decode`](@ref).

See also: [`configure`](@ref)
"""
struct Configuration{S}
    alphabet::String
    minLength::Int
    blocklist::Set{String}
    function Configuration(alphabet::AbstractString, minLength::Int, blocklist, strict::Bool = true)
        # @assert blocklist isa Union{AbstractSet{<:AbstractString}, AbstractArray{<:AbstractString}}
        sizeof(alphabet) == length(alphabet) || throw(ArgumentError("Alphabet cannot contain multibyte characters."))
        length(alphabet) < 3 && throw(ArgumentError("Alphabet length must be at least 3."))
        length(unique(alphabet)) == length(alphabet) || throw(ArgumentError("Alphabet must contain unique characters."))
        0 ≤ minLength ≤ MIN_LENGTH_LIMIT || throw(ArgumentError("Minimum length has to be between 0 and $(MIN_LENGTH_LIMIT)."))

        # clean up blocklist:
        # 1. all blocklist words should be lowercase
        # 2. no words less than 3 chars
        # 3. if some words contain chars that are not in the alphabet, remove those
        alphabet_chars = Set(lowercase(alphabet))
        filteredBlocklist = Set(filter(blocklist .|> lowercase) do word
            length(word) ≥ 3 && issetequal(word ∩ alphabet_chars, word)
        end)
        new{strict}(_shuffle(alphabet), minLength, filteredBlocklist)
    end
end
Configuration(; alphabet::AbstractString = DEFAULT_ALPHABET, minLength::Int = 0, blocklist = Blocklists.blocklist, strict::Bool = true) = 
    Configuration(alphabet, minLength, blocklist, strict)

"""
    Sqids.configure()  
    Sqids.configure(alphabet=DEFAULT_ALPHABET, minLength=0, blocklist=Blocklists.blocklist, strict=false)

Configure Sqids with parameters, and return [`Sqids.Configuration`](@ref) instance.  
`Sqids.configure()` returns default-configuration.

# Example
```julia-repl
julia> config = Sqids.configure();

julia> config = Sqids.configure(alphabet="abcdefghijklmnopqrstuvwxyz", minLength=16, blocklist=["foo", "bar"]);

```

See also: [`Configuration`](@ref)
"""
configure(; kwargs...) = Configuration(; kwargs...)

isstrict(::Configuration{S}) where {S} = (S::Bool)

function _checked_muladd(x::T, y::Integer, z::Integer) where {T<:Integer}
    _checked_muladd(promote(x, y, z)...)::Union{T, Nothing}
end
function _checked_muladd(x::T, y::T, z::T) where {T<:Integer}
    xy, overflow = mul_with_overflow(x, y)
    overflow && return nothing
    result, overflow = add_with_overflow(xy, z)
    overflow && return nothing
    result
end
_checked_muladd(x::BigInt, y::Integer, z::Integer) = muladd(x, y, z)

"""
    encode(config::Sqids.Configuration, numbers::Array{<:Integer})  

Encode the passed `numbers` to an id.

# Example
```julia-repl
julia> encode(Sqids.configure(), [1, 2, 3])
"86Rf07"

```
"""
function encode(config::Configuration, numbers::AbstractArray{<:Integer})
    isempty(numbers) && return ""
    # don't allow out-of-range numbers [might be lang-specific]
    all(≥(MIN_VALUE), numbers) || throw(ArgumentError("Encoding supports numbers greater than or equal to $(MIN_VALUE)."))
    _encode_numbers(config, numbers, 0)
end
function encode(config::Configuration{true}, numbers::AbstractArray{<:Integer})
    isempty(numbers) && return ""
    # don't allow out-of-range numbers [might be lang-specific]
    all(numbers) do num
        MIN_VALUE ≤ num ≤ maxValue(config)
    end || throw(ArgumentError("Encoding supports numbers between $(MIN_VALUE) and $(maxValue(config))."))
    _encode_numbers(config, numbers, 0)
end
function _encode_numbers(config::Configuration, numbers::AbstractArray{<:Integer}, increment::Int = 0)
    # if increment is greater than alphabet length, we've reached max attempts
    if increment > length(config.alphabet)
        throw(ArgumentError("Reached max attempts to re-generate the ID."))
    end

    # get a semi-random offset from input numbers
    # offset = foldl((a, (i, v)) -> a + Int(config.alphabet[v % length(config.alphabet) + 1]) + i, enumerate(numbers), init=increment) % length(config.alphabet)
    # ↓ a little faster
    offset = increment
    for (i, v) in pairs(numbers)
        offset += Int(config.alphabet[v % length(config.alphabet) + 1]) + i
    end
    offset %= length(config.alphabet)

    # prefix is the first character in the generated ID, used for randomization
    # reverse alphabet (otherwise for [0, x] `offset` and `separator` will be the same char)
    alphabet_chars = collect(config.alphabet)[[offset+1:end; begin:offset]]
    prefix = alphabet_chars[begin]
    reverse!(alphabet_chars)

    id = sprint(sizehint=2*length(numbers)) do io
        print(io, prefix)
        # encode input array
        for (i, num) in pairs(numbers)
            # the first character of the alphabet is going to be reserved for the `separator`
            alphabetWithoutSeparator = @view alphabet_chars[begin+1:end]
            print(io, _to_id(num, alphabetWithoutSeparator))
            if i < length(numbers)
                # `separator` character is used to isolate numbers within the ID
                print(io, alphabet_chars[begin])

                # shuffle on every iteration
                _shuffle!(alphabet_chars)
            end
        end
    end

    # handle `minLength` requirement, if the ID is too short
    if config.minLength > length(id)
        # append a separator
        id *= alphabet_chars[begin]

        # keep appending `separator` + however much alphabet is needed
        # for decoding: two separators next to each other is what tells us the rest are junk characters
        while length(id) < config.minLength
            _shuffle!(alphabet_chars)
            id *= join(alphabet_chars[begin:min(config.minLength - length(id), length(alphabet_chars))])
        end
    end

    # if ID has a blocked word anywhere, restart with a +1 increment
    if _is_blocked_id(config, id)
        id = _encode_numbers(config, numbers, increment + 1)
    end

    return id
end

_to_id(num:: Integer, alphabet::AbstractString) = _to_id(num, collect(alphabet))
function _to_id(num:: Integer, chars::AbstractVector{Char})
    L = length(chars)
    id = Char[]
    result = num
    while true
        pushfirst!(id, chars[result % L + 1])
        result = result ÷ L
        result == 0 && break
    end
    # id = @view chars[reverse(digits(num, base=L)) .+ 1]
    # id = chars[reverse(digits(num, base=L)) .+ 1]
    return String(id)
end

function _is_blocked_id(config::Configuration, id::AbstractString)
    id = lowercase(id)
    any(config.blocklist) do word
        # no point in checking words that are longer than the ID
        length(word) <= length(id) || return false
        # short words have to match completely; otherwise, too many matches 
        if length(id) ≤ 3 && length(word) ≤ 3
            id == word
        elseif occursin(r"\d", word)
            # words with leet speak replacements are visible mostly on the ends of the ID
            startswith(id, word) || endswith(id, word)
        else
            # otherwise, check for blocked word anywhere in the string
            contains(id, word)
        end
    end
end

"""
    decode(config::Sqids.Configuration, id::AbstractString)

Restore a numbers list from the passed `id`.

# Example
```julia-repl
julia> decode(Sqids.configure(), "86Rf07")
3-element Array{Int64,1}:
 1
 2
 3

```
"""
function decode(config::Configuration, id::AbstractString)
    isempty(id) && return Int[]

    # if a character is not in the alphabet, return an empty array
    id ⊆ config.alphabet || return Int[]

    # ret = Vector{Integer}()
    ret = Int[]
    sizehint!(ret, length(id))
    T = Int

    # first character is always the `prefix`
    prefix = id[begin]

    # `offset` is the semi-random position that was generated during encoding
    offset = findfirst(==(prefix), config.alphabet)

    # re-arrange alphabet back into it's original form
    # reverse alphabet
    alphabet_chars = collect(config.alphabet)[[offset:end; begin:offset-1]]
    reverse!(alphabet_chars)

    # now it's safe to remove the prefix character from ID, it's not needed anymore
    id_wk = @view id[begin+1:end]

    # decode
    while !isempty(id_wk)
        separator = alphabet_chars[begin]
        chunks = split(id_wk, separator, limit=2)
        # if chunk is empty, we are done (the rest are junk characters)
        isempty(chunks[1]) && return ret
        # decode the number without using the `separator` character
        # # but also check that ID can be decoded (eg: does not contain any non-alphabet characters)
        alphabetWithoutSeparator = @view alphabet_chars[begin+1:end]
        # chunks[1] ⊆ alphabetWithoutSeparator || return Int[]
        # push!(ret, _to_number(config, chunks[1], alphabetWithoutSeparator))
        num = _to_number(config, chunks[1], alphabetWithoutSeparator)
        if !isstrict(config)
            T = promote_type(T, typeof(num))
            if T !== eltype(ret)
                ret = T.(ret)
                sizehint!(ret, length(id))
            end
        end
        push!(ret, num)
        # if this ID has multiple numbers, shuffle the alphabet because that's what encoding function did
        length(chunks) < 2 && break
        alphabet_chars = _shuffle!(alphabet_chars)
        id_wk = chunks[2]
    end

    return ret
end

_to_number(config::Configuration, id::AbstractString, alphabet::AbstractString) = _to_number(config, id, collect(alphabet))
# function _to_number(config::Configuration, id::AbstractString, chars::AbstractVector{Char})
#     L = length(chars)
#     foldl(collect(id), init=0) do a, v
#         a * L + findfirst(==(v), chars) - 1
#     end
#     result
# end
_to_number(config::Configuration, id::AbstractString, chars::AbstractVector{Char}) = _to_number(config, id, 0, Dict(c=>i for (i, c) in pairs(chars)))
function _to_number(::Configuration{true}, id::AbstractString, init::Int, alphabet_dic::Dict{Char, Int})
    L = length(alphabet_dic)
    foldl(id, init=init) do a, c
        _number = _checked_muladd(a, L, alphabet_dic[c] - 1)
        isnothing(_number) && throw(ArgumentError("Ran out of range decoding id($(id))"))
        _number::Int
    end
end
function _to_number(config::Configuration, id::AbstractString, init::I, alphabet_dic::Dict{Char, Int}) where {I <: Integer}
    L = length(alphabet_dic)
    result::I = init
    for (i, c) in pairs(id)
        # result = result * L + alphabet_dic[c] - 1
        _number = _checked_muladd(result, L, alphabet_dic[c] - 1)
        isnothing(_number) && return _to_number(config, id[i:end], widen(result), alphabet_dic)
        result = _number
    end
    result
end

"""
    maxValue(config::Sqids.Configuration)

Return the maximum value available with Sqids.  
Returns `typemax(Int)` if Strict mode, or throws an `MethodError` otherwise.
"""
maxValue(::Configuration{true}) = typemax(Int)

end # module Sqids