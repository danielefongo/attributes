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
        defmodule EmptySetRaise do
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

  defp get_attrs(module), do: module.__info__(:attributes)[:__attributes__]
end
