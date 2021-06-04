defmodule AttributesTest do
  use ExUnit.Case

  defmodule Dummy, do: :ok

  describe "empty" do
    test "set raise" do
      assert_raise RuntimeError, fn ->
        defmodule EmptySetRaise do
          Attributes.set(__MODULE__, [], :value)
        end
      end
    end

    test "set! raise" do
      assert_raise RuntimeError, fn ->
        defmodule EmptySetBangRaise do
          Attributes.set!(__MODULE__, [], :value)
        end
      end
    end

    test "get raise" do
      assert_raise RuntimeError, fn ->
        Attributes.get(__MODULE__, [])
      end
    end

    test "get! raise" do
      assert_raise RuntimeError, fn ->
        Attributes.get!(__MODULE__, [])
      end
    end

    test "delete raise" do
      assert_raise RuntimeError, fn ->
        Attributes.delete(__MODULE__, [])
      end
    end

    test "delete! raise" do
      assert_raise RuntimeError, fn ->
        Attributes.delete!(__MODULE__, [])
      end
    end

    test "update raise" do
      assert_raise RuntimeError, fn ->
        defmodule EmptyUpdateRaise do
          Attributes.update(__MODULE__, [], & &1)
        end
      end
    end

    test "update! raise" do
      assert_raise RuntimeError, fn ->
        defmodule EmptyUpdateBangRaise do
          Attributes.update!(__MODULE__, [], & &1)
        end
      end
    end
  end

  describe "shallow" do
    test "set different keys" do
      defmodule ShallowSetDifferentKeys do
        Attributes.set(__MODULE__, [:key], :value)
        Attributes.set(__MODULE__, [:key2], :value2)
      end

      assert get_attrs(ShallowSetDifferentKeys) == [key2: :value2, key: :value]
    end

    test "set override" do
      defmodule ShallowSetOverride do
        Attributes.set(__MODULE__, [:key], :value)
        Attributes.set(__MODULE__, [:key], :new_value)
      end

      assert get_attrs(ShallowSetOverride) == [key: :new_value]
    end

    test "set! different keys" do
      defmodule ShallowSetBangDifferentKeys do
        Attributes.set!(__MODULE__, [:key], :value)
        Attributes.set!(__MODULE__, [:key2], :value2)
      end

      assert get_attrs(ShallowSetBangDifferentKeys) == [key2: :value2, key: :value]
    end

    test "set! raise on override" do
      assert_raise RuntimeError, fn ->
        defmodule ShallowSetRaise do
          Attributes.set!(__MODULE__, [:key], :value)
          Attributes.set!(__MODULE__, [:key], :new_value)
        end
      end
    end

    test "get" do
      defmodule ShallowGet do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value]
      end

      assert Attributes.get(ShallowGet, [:key]) == :value
    end

    test "get nil" do
      assert Attributes.get(Dummy, [:key]) == nil
    end

    test "get default" do
      assert Attributes.get(Dummy, [:key], :default) == :default
    end

    test "get!" do
      defmodule ShallowGetBang do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value]
      end

      assert Attributes.get!(ShallowGetBang, [:key]) == :value
    end

    test "get! raises on nil" do
      assert_raise RuntimeError, fn ->
        Attributes.get!(Dummy, [:key])
      end
    end

    test "delete" do
      defmodule ShallowDelete do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value, key2: :value2]
        Attributes.delete(ShallowDelete, [:key])
      end

      assert get_attrs(ShallowDelete) == [key2: :value2]
    end

    test "delete not existing" do
      defmodule ShallowDeleteNotExisting do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ []

        Attributes.delete(ShallowDeleteNotExisting, [:key])
      end

      assert get_attrs(ShallowDeleteNotExisting) == []
    end

    test "delete!" do
      defmodule ShallowDeleteBang do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value, key2: :value2]
        Attributes.delete!(ShallowDeleteBang, [:key])
      end

      assert get_attrs(ShallowDeleteBang) == [key2: :value2]
    end

    test "delete! raise on nil" do
      assert_raise RuntimeError, fn ->
        defmodule ShallowDeleteBangRaise do
          Module.register_attribute(__MODULE__, :__attributes__, persist: true)
          @__attributes__ []
          Attributes.delete!(ShallowDeleteBangRaise, [:key])
        end
      end
    end

    test "update" do
      defmodule ShallowUpdate do
        Attributes.set(__MODULE__, [:key], 41)
        Attributes.update(__MODULE__, [:key], &(&1 + 1))
      end

      assert get_attrs(ShallowUpdate) == [key: 42]
    end

    test "update!" do
      defmodule ShallowUpdateBang do
        Attributes.set(__MODULE__, [:key], 41)
        Attributes.update!(__MODULE__, [:key], &(&1 + 1))
      end

      assert get_attrs(ShallowUpdateBang) == [key: 42]
    end

    test "set! raise on nil" do
      assert_raise RuntimeError, fn ->
        defmodule ShallowUpdateBangRaise do
          Attributes.set(__MODULE__, [:key], nil)
          Attributes.update!(__MODULE__, [:key], &(&1 + 1))
        end
      end
    end
  end

  describe "nested" do
    test "set different keys" do
      defmodule NestedSetDifferentKeys do
        Attributes.set(__MODULE__, [:key, :subkey], :value)
        Attributes.set(__MODULE__, [:key, :subkey2], :value2)
      end

      assert get_attrs(NestedSetDifferentKeys) == [key: [subkey2: :value2, subkey: :value]]
    end

    test "set override" do
      defmodule NestedSetOverride do
        Attributes.set(__MODULE__, [:key, :subkey], :value)
        Attributes.set(__MODULE__, [:key, :subkey], :new_value)
      end

      assert get_attrs(NestedSetOverride) == [key: [subkey: :new_value]]
    end

    test "set! different keys" do
      defmodule NestedSetBangDifferentKeys do
        Attributes.set!(__MODULE__, [:key, :subkey], :value)
        Attributes.set!(__MODULE__, [:key, :subkey2], :value2)
      end

      assert get_attrs(NestedSetBangDifferentKeys) == [key: [subkey2: :value2, subkey: :value]]
    end

    test "set! raise on override" do
      assert_raise RuntimeError, fn ->
        defmodule NestedSetRaise do
          Attributes.set!(__MODULE__, [:key, :subkey], :value)
          Attributes.set!(__MODULE__, [:key, :subkey], :new_value)
        end
      end
    end

    test "get" do
      defmodule NestedGet do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: [subkey: :value]]
      end

      assert Attributes.get(NestedGet, [:key, :subkey]) == :value
    end

    test "get nil" do
      assert Attributes.get(Dummy, [:key, :subkey]) == nil
    end

    test "get default" do
      assert Attributes.get(Dummy, [:key, :subkey], :default) == :default
    end

    test "get!" do
      defmodule NestedGetBang do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value]
      end

      assert Attributes.get!(NestedGetBang, [:key]) == :value
    end

    test "get! raises on nil" do
      assert_raise RuntimeError, fn ->
        Attributes.get!(Dummy, [:key, :subkey])
      end
    end

    test "delete" do
      defmodule NestedDelete do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: [subkey: :value, subkey2: :value2]]
        Attributes.delete(NestedDelete, [:key, :subkey])
      end

      assert get_attrs(NestedDelete) == [key: [subkey2: :value2]]
    end

    test "delete not existing" do
      defmodule NestedDeleteNotExisting do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ []

        Attributes.delete(NestedDeleteNotExisting, [:key, :subkey])
      end

      assert get_attrs(NestedDeleteNotExisting) == []
    end

    test "delete!" do
      defmodule NestedDeleteBang do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: [subkey: :value, subkey2: :value2]]
        Attributes.delete!(NestedDeleteBang, [:key, :subkey])
      end

      assert get_attrs(NestedDeleteBang) == [key: [subkey2: :value2]]
    end

    test "delete! raise on nil" do
      assert_raise RuntimeError, fn ->
        defmodule NestedDeleteBangRaise do
          Module.register_attribute(__MODULE__, :__attributes__, persist: true)
          @__attributes__ []
          Attributes.delete!(NestedDeleteBangRaise, [:key, :subkey])
        end
      end
    end

    test "update" do
      defmodule NestedUpdate do
        Attributes.set(__MODULE__, [:key], 41)
        Attributes.update(__MODULE__, [:key], &(&1 + 1))
      end

      assert get_attrs(NestedUpdate) == [key: 42]
    end

    test "update!" do
      defmodule NestedUpdateBang do
        Attributes.set(__MODULE__, [:key], 41)
        Attributes.update!(__MODULE__, [:key], &(&1 + 1))
      end

      assert get_attrs(NestedUpdateBang) == [key: 42]
    end

    test "set! raise on nil" do
      assert_raise RuntimeError, fn ->
        defmodule NestedUpdateBangRaise do
          Attributes.set(__MODULE__, [:key], nil)
          Attributes.update!(__MODULE__, [:key], &(&1 + 1))
        end
      end
    end
  end

  describe "hybrid" do
    test "set override inside keyword" do
      defmodule HybridSetOverrideInsideKeyword do
        Attributes.set(__MODULE__, [:key], [])
        Attributes.set(__MODULE__, [:key, :subkey], :value)
      end

      assert get_attrs(HybridSetOverrideInsideKeyword) == [key: [subkey: :value]]
    end

    test "set override inside map" do
      defmodule HybridSetOverrideInsideMap do
        Attributes.set(__MODULE__, [:key], %{})
        Attributes.set(__MODULE__, [:key, :subkey], :value)
      end

      assert get_attrs(HybridSetOverrideInsideMap) == [key: %{subkey: :value}]
    end

    test "set raise on value override when is not a map/keyword" do
      assert_raise RuntimeError, fn ->
        defmodule HybridSetRaiseOnValue do
          Attributes.set(__MODULE__, [:key], :value)
          Attributes.set(__MODULE__, [:key, :subkey], :value2)
        end
      end
    end

    test "set override outer keyword" do
      defmodule HybridSetOverrideOuterKeyword do
        Attributes.set(__MODULE__, [:key, :subkey], :value)
        Attributes.set(__MODULE__, [:key], data: :new)
      end

      assert get_attrs(HybridSetOverrideOuterKeyword) == [key: [data: :new]]
    end

    test "set override outer map" do
      defmodule HybridSetOverrideOuterMap do
        Attributes.set(__MODULE__, [:key, :subkey], :value)
        Attributes.set(__MODULE__, [:key], %{data: :new})
      end

      assert get_attrs(HybridSetOverrideOuterMap) == [key: %{data: :new}]
    end
  end

  describe "already compiled" do
    test "set raise" do
      assert_raise RuntimeError, fn ->
        Attributes.set(Dummy, [:key], :value2)
      end
    end

    test "set! raise" do
      assert_raise RuntimeError, fn ->
        Attributes.set!(Dummy, [:key], :value2)
      end
    end
  end

  defp get_attrs(module), do: module.__info__(:attributes)[:__attributes__]
end
