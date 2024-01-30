defmodule Supermarket.Model.Discount.TwoForAmount do
  alias Supermarket.Model.Discount.NForAmount

  def calculate_discount(unit_price, offer, product, quantity) do
    NForAmount.calculate_discount(unit_price, offer, product, quantity, 2)
  end
end
