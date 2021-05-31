defmodule Attributes do
  @moduledoc """
  Attributes offers utility functions to set and get complex attributes on modules.

  ## Example
      defmodule MyModule do
        Attributes.set(__MODULE__, [:path, :to, :attr], :value)
      end

  Attributes supports nested maps and keyword.
  The previous assignment could be rewritten as follow:

  ### Example
    Attributes.set(__MODULE__, [:path], [to: [attr: :value]])

  ### Example
    Attributes.set(__MODULE__, [:path], %{to: %{attr: :value}})

  After defining an attribute, you can obtain its value using `get/2` and `get!/2` methods.

  ### Example
      iex> Attributes.get(MyModule, [:path, :to, :attr])
      iex> :value

  ### Example
      iex> Attributes.get(MyModule, [:path, :to])
      iex> [attr: :value]
  """

  @attributes_field :__attributes__

  @doc """
  Gets attribute by path and raises if not found.

  It is the extension of `get/2` that requires the value or the path to be defined:
  - path should exist
  - value should not be `nil`

  ## Example
      Attributes.get!(MyModule, [:path])
  """
  def get!(module, path) do
    case get(module, path) do
      nil -> raise_error(path, "not found")
      value -> value
    end
  end

  @doc """
  Gets attribute by path.

  It returns nil if path is not found.

  ## Example
      Attributes.get(MyModule, [:path])
  """
  def get(module, []) do
    raise "No path provided when getting attributes from #{module}."
  end

  def get(module, path) do
    module
    |> attributes()
    |> get_in(filter(path))
  end

  @doc """
  Sets attribute to path and raise error if already defined.

  Available at compile time only.
  It is the extension of `set/3` that requires the path to don't have a value.

  ## Example
      Attributes.set!(MyModule, [:path], :value)
  """
  def set!(module, path, value) do
    case get(module, path) do
      nil -> set(module, path, value)
      _ -> raise_error(path, "already defined")
    end
  end

  @doc """
  Sets attribute to path.

  Available at compile time only.

  ## Example
      Attributes.get(MyModule, [:path], :value)
  """
  def set(module, [], value) do
    raise "No path provided when assigning #{value} on #{module}."
  end

  def set(module, path, value) do
    if not editable?(module) do
      raise "#{module} already compiled."
    end

    if is_nil(Module.get_attribute(module, @attributes_field)) do
      Module.register_attribute(module, @attributes_field, persist: true)
    end

    try do
      new_attributes =
        module
        |> attributes()
        |> put_in(filter(path), value)

      Module.put_attribute(module, @attributes_field, new_attributes)
    rescue
      FunctionClauseError ->
        reraise "Cannot set on path #{inspect(path)}", System.stacktrace()
    end
  end

  defp attributes(module) do
    if editable?(module) do
      Module.get_attribute(module, @attributes_field, [])
    else
      :attributes
      |> module.__info__()
      |> Keyword.get(@attributes_field, [])
    end
  end

  defp filter(path), do: Enum.flat_map(path, fn key -> [&handle_empty/3, key] end)

  defp handle_empty(_, nil, next), do: next.([])
  defp handle_empty(_, data, next), do: next.(data)

  defp editable?(module), do: :elixir_module.mode(module) == :all

  defp raise_error(keys, message) do
    path = keys |> Enum.drop(-1) |> Enum.join(" -> ")
    key = List.last(keys)

    if path != "" do
      raise "#{key} #{message} in #{path}."
    else
      raise "#{key} #{message}."
    end
  end
end
