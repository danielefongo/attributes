defmodule Attributes do
  @moduledoc false
  @attributes_field :__attributes__

  def get!(module, where) do
    case get(module, where) do
      nil -> raise_error(where, "not found")
      value -> value
    end
  end

  def get(module, where) do
    module
    |> attributes()
    |> get_in(filter(where))
  end

  def set!(module, where, value) do
    case get(module, where) do
      nil -> set(module, where, value)
      _ -> raise_error(where, "already defined")
    end
  end

  def set(module, where, value) do
    if not editable?(module) do
      raise "#{module} already compiled."
    end

    if is_nil(Module.get_attribute(module, @attributes_field)) do
      Module.register_attribute(module, @attributes_field, persist: true)
    end

    new_attributes =
      module
      |> attributes()
      |> put_in(filter(where), value)

    Module.put_attribute(module, @attributes_field, new_attributes)
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

  defp filter(where), do: Enum.flat_map(where, fn key -> [&handle_empty/3, key] end)

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
