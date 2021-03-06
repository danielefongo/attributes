defmodule Attributes do
  @moduledoc """
  Attributes offers utility functions to manipulate complex attributes on modules.

  A typical usage could be inside macros that need to enrich modules before their compilation.
  You can set, update, get or delete attributes' tree.

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

  After defining an attribute, you can obtain its value using `get/2`, `get/3` or `get!/2` methods.

  ### Example
      iex> Attributes.get(MyModule, [:path, :to, :attr])
      iex> :value

  ### Example
      iex> Attributes.get(MyModule, [:path, :to])
      iex> [attr: :value]
  """

  @attributes_field :__attributes__

  @doc """
  Gets attribute in path and raises if not found.

  It is the extension of `get/2` that requires the value and the path to be defined:
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
  Gets all attributes.

  ## Example
      Attributes.get(MyModule)
  """
  def get(module), do: get_attributes(module)

  @doc """
  Gets attribute in path.

  It returns `nil` if path is not found.

  ## Example
      Attributes.get(MyModule, [:path])
  """
  def get(module, path), do: get(module, path, nil)

  @doc """
  Gets attribute in path with default.

  It returns default if path is not found or the value is `nil`.

  ## Example
      Attributes.get(MyModule, [:path], :default)
  """
  def get(module, [], _default) do
    raise "No path provided when getting attributes from #{module}."
  end

  def get(module, path, default) do
    module
    |> get_attributes()
    |> get_in(filter(path))
    |> case do
      nil -> default
      val -> val
    end
  end

  @doc """
  Sets attribute in path and raise error if already defined.

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
  Sets attribute in path.

  Available at compile time only.

  ## Example
      Attributes.set(MyModule, [:path], :value)
  """
  def set(module, [], value) do
    raise "No path provided when assigning #{value} on #{module}."
  end

  def set(module, path, value) do
    edit_attributes(module, filter(path), "set", fn attributes, path ->
      put_in(attributes, path, value)
    end)
  end

  @doc """
  Updates attribute in path and raise error if not found.

  Available at compile time only.
  It is the extension of `update/3` that requires the value and the path to be defined:
  - path should exist
  - value should not be `nil`

  ## Example
      Attributes.update!(MyModule, [:path], :value)
  """
  def update!(module, path, lambda) do
    case get(module, path) do
      nil -> raise_error(path, "not found")
      _ -> update(module, path, lambda)
    end
  end

  @doc """
  Updates attribute in path.

  Available at compile time only.

  ## Example
      Attributes.update(MyModule, [:path], & &1 + 1)
  """
  def update(module, path, lambda), do: update(module, path, nil, lambda)

  @doc """
  Updates attribute in path with default lambda input value.

  Available at compile time only.

  ## Example
      Attributes.update(MyModule, [:path], 41, & &1 + 1)
  """
  def update(module, [], _default, _lambda) do
    raise "No path provided when updating #{module}."
  end

  def update(module, path, default, lambda) do
    update_lambda = fn
      nil -> {nil, lambda.(default)}
      value -> {value, lambda.(value)}
    end

    edit_attributes(module, filter(path), "update", fn attributes, path ->
      attributes
      |> get_and_update_in(path, update_lambda)
      |> elem(1)
    end)
  end

  @doc """
  Deletes attribute in path and raises if not found.

  Available at compile time only.
  It is the extension of `delete/2` that requires the value and the path to be defined:
  - path should exist
  - value should not be `nil`

  ## Example
      Attributes.delete!(MyModule, [:path])
  """
  def delete!(module, path) do
    case get(module, path) do
      nil -> raise_error(path, "not found")
      _ -> delete(module, path)
    end
  end

  @doc """
  Deletes all attributes.

  Available at compile time only.

  ## Example
      Attributes.delete(MyModule)
  """
  def delete(module) do
    validate_and_create(module)

    Module.put_attribute(module, @attributes_field, [])
  end

  @doc """
  Deletes attribute in path.

  Available at compile time only.
  It does not raise if the path is not found.

  ## Example
      Attributes.delete(MyModule, [:path])
  """
  def delete(module, []) do
    raise "No path provided when deleting attributes from #{module}."
  end

  def delete(module, path) do
    edit_attributes(module, filter(path), "delete", fn attributes, path ->
      attributes |> pop_in(path) |> elem(1)
    end)
  end

  defp get_attributes(module) do
    if editable?(module) do
      Module.get_attribute(module, @attributes_field, [])
    else
      :attributes
      |> module.__info__()
      |> Keyword.get(@attributes_field, [])
    end
  end

  defp edit_attributes(module, path, action_name, lambda) do
    validate_and_create(module)

    try do
      new_attributes =
        module
        |> get_attributes()
        |> lambda.(path)

      Module.put_attribute(module, @attributes_field, new_attributes)
    rescue
      FunctionClauseError ->
        reraise "Cannot #{action_name} on path #{inspect(path)}", System.stacktrace()
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

  defp validate_and_create(module) do
    if not editable?(module) do
      raise "#{module} already compiled."
    end

    if is_nil(Module.get_attribute(module, @attributes_field)) do
      Module.register_attribute(module, @attributes_field, persist: true)
    end
  end
end
