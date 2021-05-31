# Attributes

**TODO: Add description**

## Installation

The package can be installed by adding `attributes` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:attributes, "~> 0.1.0"}
  ]
end
```

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

After defining an attribute, you can obtain its value using `Attributes.get/2` and `Attributes.get!/2` methods.

```elixir
iex> Attributes.get(MyModule, [:path, :to, :attr])
iex> :value
```

```elixir
iex> Attributes.get(MyModule, [:path, :to])
iex> [attr: :value]
```
