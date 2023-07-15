# [Sqids.jl](https://sqids.org/julia)

[![Github Actions](https://img.shields.io/github/actions/workflow/status/sqids/sqids-julia/CI.yml)](https://github.com/sqids/sqids-julia/actions)

Sqids (pronounced "squids") is a small library that lets you generate YouTube-looking IDs from numbers. It's good for link shortening, fast & URL-safe ID generation and decoding back into numbers for quicker database lookups.

## Getting started

Install Sqids via (on the Julia REPL):

```julia
julia> ]  # enter Pkg REPL-mode

pkg> add Sqids
```

## Examples

Start using Sqids:

```julia
using Sqids
```

Simple encode & decode:

```julia
config = Sqids.configure()
id = Sqids.encode(config, [1, 2, 3])  #> "8QRLaD"
numbers = Sqids.decode(config, id)  #> [1, 2, 3]
```

Randomize IDs by providing a custom alphabet:

```julia
config = Sqids.configure(alphabet="FxnXM1kBN6cuhsAvjW3Co7l2RePyY8DwaU04Tzt9fHQrqSVKdpimLGIJOgb5ZE")
id = Sqids.encode(config, [1, 2, 3])  #> "B5aMa3"
numbers = Sqids.decode(config, id)  #> [1, 2, 3]
```

Enforce a *minimum* length for IDs:

```julia
config = Sqids.configure(minLength=10)
id = Sqids.encode(config, [1, 2, 3])  #> "75JT1cd0dL"
numbers = Sqids.decode(config, id)  #> [1, 2, 3]
```

Prevent specific words from appearing anywhere in the auto-generated IDs:

```julia
config = Sqids.configure(blocklist=["word1","word2"])
id = Sqids.encode(config, [1, 2, 3])  #> "8QRLaD"
numbers = Sqids.decode(config, id)  #> [1, 2, 3]
```

### Julia-specific

If `strict=false` is set when configuring, it enables handling of limitless values using `Int128` or `BigInt`, integer types larger than 64 bits.

```julia
config = Sqids.configure(strict=false)  # not-strict mode
id = Sqids.encode(config, Int128[9223372036854775808])  #> "piF3yT7tOtoO"
numbers = Sqids.decode(config, id)  #> Int128[9223372036854775808]
```

Note that while this setting allows for automatic type selection of the decoded value, it may cause type instability and minor performance slowdowns.

## Notes

- **Do not encode sensitive data.** These IDs can be easily decoded.
- **Default blocklist is auto-enabled.** It's configured for the most common profanity words. Create your own custom list by using the `blocklist` parameter, or pass an empty array to allow all words.
- Read more at <https://sqids.org/julia>

## License

[MIT](LICENSE)
