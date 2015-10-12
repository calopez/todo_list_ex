defmodule Fraction do
  defstruct a: nil, b: nil

  def new(a, b) do
    # this is a simple wrapper around the %Fraction{} syntax. It makes the
    # client code cleaner and less coupled with the fact that structs are used
    %Fraction{a: a, b: b}
  end

  def value(%Fraction{a: a, b: b}) do
    a / b
  end

  def add(
        %Fraction{a: a1, b: b1},
        %Fraction{a: a2, b: b2}
      ) do
    new( a1 * b2 + a2 * b1, b2 * b1)
  end

  # this approach is a little bit slower but seems more cleaner
  # def value(fraction) do
  #   fraction.a / fraction.b
  # end
end

# A struct may exist only in a module, and a single module can define
# only one struct.

# c("fraction.ex")
# [Fraction]
# iex(37)> one_half = %Fraction{a: 1, b: 2}
# %Fraction{a: 1, b: 2}
# iex(38)> one_half.a
# 1

# This works because IO.inspect/1 prints the data structure and then
# returns that same data structure unchanged.

# Fraction.new(1, 4) |>
#   IO.inspect |>
#   Fraction.add(Fraction.new(1, 4)) |>
#   IO.inspect |>
#   Fraction.add(Fraction.new(1, 2)) |>
#   IO.inspect |>
#   Fraction.value
