defmodule FantasyTest do
  use ExUnit.Case
  doctest Fantasy

  test "greets the world" do
    assert Fantasy.hello() == :world
  end
end
