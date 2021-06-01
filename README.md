# Attributes

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/danielefongo/attributes/ci)
![Coveralls](https://img.shields.io/coveralls/github/danielefongo/attributes/main)
[![Hex pm](http://img.shields.io/hexpm/v/attributes.svg?style=flat)](https://hex.pm/packages/attributes)
![Hex.pm](https://img.shields.io/hexpm/l/attributes)

Set and get complex attributes on modules

## Installation

The package can be installed by adding `attributes` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:attributes, "~> 0.1.0"}
  ]
end
```

## Documentation

Documentation can be found at [https://hexdocs.pm/attributes](https://hexdocs.pm/attributes).

## Usage

Attributes offers utility functions to set and get complex attributes on modules.

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
