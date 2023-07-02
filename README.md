# [Sqids Julia](https://sqids.org/julia)

Sqids (pronounced "squids") is a small library that lets you generate YouTube-looking IDs from numbers. It's good for link shortening, fast & URL-safe ID generation and decoding back into numbers for quicker database lookups.

## Getting started

Install Sqids via:

```julia
# @todo
```

## Examples

Simple encode & decode:

```julia
config = Sqids.configure()
id = Sqids.encode(config, [1, 2, 3]) # "8QRLaD"
numbers = Sqids.decode(config, id) # [1, 2, 3]
```

Randomize IDs by providing a custom alphabet:

```julia
config = Sqids.configure(alphabet="FxnXM1kBN6cuhsAvjW3Co7l2RePyY8DwaU04Tzt9fHQrqSVKdpimLGIJOgb5ZE")
id = Sqids.encode(config, [1, 2, 3]) # "B5aMa3"
numbers = Sqids.decode(config, id) # [1, 2, 3]
```

Enforce a *minimum* length for IDs:

```julia
config = Sqids.configure(minLength=10)
id = Sqids.encode(config, [1, 2, 3]) # "75JT1cd0dL"
numbers = Sqids.decode(config, id) # [1, 2, 3]
```

Prevent specific words from appearing anywhere in the auto-generated IDs:

```julia
config = Sqids.configure(blacklist=["word1","word2"])
id = Sqids.encode(config, [1, 2, 3]) # "8QRLaD"
numbers = Sqids.decode(config, id) # [1, 2, 3]
```

## Notes

@todo

## License

[MIT](LICENSE)
