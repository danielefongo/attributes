defmodule AttributesTest do
  use ExUnit.Case

  defmodule Dummy, do: :ok

  describe "set" do
    test "empty path raise" do
      assert_raise RuntimeError, fn ->
        defmodule SetEmptyPathRaise do
          Attributes.set(__MODULE__, [], :value)
        end
      end
    end

    test "different keys" do
      defmodule SetDifferentKeys do
        Attributes.set(__MODULE__, [:key], :value)
        Attributes.set(__MODULE__, [:key2], :value2)
      end

      assert get_attrs(SetDifferentKeys) == [key2: :value2, key: :value]
    end

    test "different nested keys" do
      defmodule SetDifferentNestedKeys do
        Attributes.set(__MODULE__, [:key, :subkey], :value)
        Attributes.set(__MODULE__, [:key, :subkey2], :value2)
      end

      assert get_attrs(SetDifferentNestedKeys) == [key: [subkey2: :value2, subkey: :value]]
    end

    test "override" do
      defmodule SetOverride do
        Attributes.set(__MODULE__, [:key, :subkey], :value)
        Attributes.set(__MODULE__, [:key, :subkey], :new_value)
      end

      assert get_attrs(SetOverride) == [key: [subkey: :new_value]]
    end

    test "already compiled raise" do
      assert_raise RuntimeError, fn ->
        Attributes.set(Dummy, [:key], :value2)
      end
    end
  end

  describe "set!" do
    test "raise when already defined" do
      assert_raise RuntimeError, fn ->
        defmodule SetBangDefinedRaise do
          Attributes.set(__MODULE__, [:key], :value)
          Attributes.set!(__MODULE__, [:key], :value)
        end
      end
    end

    test "when nil" do
      defmodule SetBangNil do
        Attributes.set!(__MODULE__, [:key], :value)
      end

      assert get_attrs(SetBangNil) == [key: :value]
    end
  end

  describe "get" do
    test "empty path raise" do
      assert_raise RuntimeError, fn ->
        Attributes.get(Dummy, [])
      end
    end

    test "before compile" do
      defmodule GetBeforeCompile do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: [subkey: :value]]

        @value Attributes.get(GetBeforeCompile, [:key, :subkey])

        def gimme_value, do: @value
      end

      assert GetBeforeCompile.gimme_value() == :value
    end

    test "nested" do
      defmodule GetNested do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: [subkey: :value]]
      end

      assert Attributes.get(GetNested, [:key, :subkey]) == :value
    end

    test "nil" do
      assert Attributes.get(Dummy, [:key, :subkey]) == nil
    end

    test "default" do
      assert Attributes.get(Dummy, [:key, :subkey], :default) == :default
    end
  end

  describe "get!" do
    test "raise when not found" do
      assert_raise RuntimeError, fn ->
        Attributes.get!(Dummy, [:key])
      end
    end

    test "raise when nil" do
      assert_raise RuntimeError, fn ->
        defmodule GetBangNil do
          Module.register_attribute(__MODULE__, :__attributes__, persist: true)
          @__attributes__ [key: nil]
          Attributes.get!(Dummy, [:key])
        end
      end
    end

    test "when defined" do
      defmodule GetBangDefined do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value]
      end

      assert Attributes.get!(GetBangDefined, [:key]) == :value
    end
  end

  describe "delete" do
    test "empty path raise" do
      assert_raise RuntimeError, fn ->
        Attributes.delete(Dummy, [])
      end
    end

    test "nested" do
      defmodule DeleteNested do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: [subkey: :value, subkey2: :value2]]
        Attributes.delete(DeleteNested, [:key, :subkey2])
      end

      assert get_attrs(DeleteNested) == [key: [subkey: :value]]
    end

    test "not existing" do
      defmodule DeleteNotExisting do
        Attributes.delete(DeleteNotExisting, [:key])
      end

      assert get_attrs(DeleteNotExisting) == []
    end

    test "already compiled raise" do
      assert_raise RuntimeError, fn ->
        Attributes.delete(Dummy, [:key, :subkey])
      end
    end
  end

  describe "delete!" do
    test "raise when not found" do
      assert_raise RuntimeError, fn ->
        Attributes.delete!(Dummy, [:key])
      end
    end

    test "raise when nil" do
      assert_raise RuntimeError, fn ->
        defmodule DeleteBangNil do
          Module.register_attribute(__MODULE__, :__attributes__, persist: true)
          @__attributes__ [key: nil]
          Attributes.get!(Dummy, [:key])
        end
      end
    end

    test "when defined" do
      defmodule DeleteBangDefined do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value]
        Attributes.delete!(DeleteBangDefined, [:key])
      end

      assert get_attrs(DeleteBangDefined) == []
    end
  end

  describe "update" do
    test "empty path raise" do
      assert_raise RuntimeError, fn ->
        defmodule UpdateEmptyPathRaise do
          Attributes.update(__MODULE__, [], & &1)
        end
      end
    end

    test "nested" do
      defmodule UpdateNested do
        Attributes.set(__MODULE__, [:key, :subkey], 41)
        Attributes.update(__MODULE__, [:key, :subkey], &(&1 + 1))
      end

      assert get_attrs(UpdateNested) == [key: [subkey: 42]]
    end

    test "nil" do
      defmodule UpdateNil do
        Attributes.update(__MODULE__, [:key, :subkey], fn _ -> 42 end)
      end

      assert get_attrs(UpdateNil) == [key: [subkey: 42]]
    end

    test "already compiled raise" do
      assert_raise RuntimeError, fn ->
        Attributes.update(Dummy, [:key], fn _ -> :any end)
      end
    end
  end

  describe "update!" do
    test "raise when not found" do
      assert_raise RuntimeError, fn ->
        Attributes.update!(Dummy, [:key], & &1)
      end
    end

    test "raise when nil" do
      assert_raise RuntimeError, fn ->
        defmodule UpdateBangNil do
          Module.register_attribute(__MODULE__, :__attributes__, persist: true)
          @__attributes__ [key: nil]
          Attributes.update!(__MODULE__, [:key], & &1)
        end
      end
    end

    test "when defined" do
      defmodule UpdateBangDefined do
        Module.register_attribute(__MODULE__, :__attributes__, persist: true)
        @__attributes__ [key: :value]
        Attributes.update!(__MODULE__, [:key], fn _ -> :new_value end)
      end

      assert get_attrs(UpdateBangDefined) == [key: :new_value]
    end
  end

  describe "hybrid" do
    test "override inside keyword" do
      defmodule HybridSetOverrideInsideKeyword do
        Attributes.set(__MODULE__, [:key], [])
        Attributes.set(__MODULE__, [:key, :subkey], :value)
      end

      assert get_attrs(HybridSetOverrideInsideKeyword) == [key: [subkey: :value]]
    end

    test "override inside map" do
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
