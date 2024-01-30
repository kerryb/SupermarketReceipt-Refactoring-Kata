defmodule Supermarket.Model.Discount.FiveForAmount do
  alias Supermarket.Model.Discount.NForAmount

  def calculate_discount(unit_price, offer, product, quantity) do
    NForAmount.calculate_discount(unit_price, offer, product, quantity, 5)
  end
end
