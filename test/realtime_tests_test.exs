defmodule RealtimeTestsTest do
  use ExUnit.Case
  doctest RealtimeTests

  test "greets the world" do
    assert RealtimeTests.hello() == :world
  end
end
