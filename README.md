# Attributes

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/danielefongo/attributes/ci)
![Coveralls](https://img.shields.io/coveralls/github/danielefongo/attributes/main)
[![Hex pm](http://img.shields.io/hexpm/v/attributes.svg?style=flat)](https://hex.pm/packages/attributes)
![Hex.pm](https://img.shields.io/hexpm/l/attributes)

Manipulate complex attributes on modules.

## Installation

The package can be installed by adding `attributes` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:attributes, "~> 0.2.0"}
  ]
end
```

## Documentation

Full documentation can be found at [https://hexdocs.pm/attributes](https://hexdocs.pm/attributes).

## Usage

Attributes offers utility functions to manipulate complex attributes on modules.

A typical usage could be inside macros that need to enrich modules before their compilation.
You can set, get or delete attributes' tree using partial or full path.

```elixir
defmodule MyModule do
  Attributes.set(__MODULE__, [:path, :to, :attr], :value)
end
```

Attributes supports nested maps and keyword.
The previous assignment could be rewritten as follow:

```elixir
Attributes.set(__MODULE__, [:path], [to: [attr: :value]])
```

```elixir
Attributes.set(__MODULE__, [:path], %{to: %{attr: :value}})
```

After defining an attribute, you can obtain its value using `Attributes.get/2`, `Attributes.get/3` or `Attributes.get!/2` methods.

```elixir
iex> Attributes.get(MyModule, [:path, :to, :attr])
iex> :value
```

```elixir
iex> Attributes.get(MyModule, [:path, :to])
iex> [attr: :value]
```
