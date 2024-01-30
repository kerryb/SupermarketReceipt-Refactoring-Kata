defmodule Supermarket.Model.Discount.FiveForAmount do
  alias Supermarket.Model.Discount.NForAmount

  def calculate_discount(unit_price, offer, product, quantity)
      when quantity >= 5 do
    NForAmount.calculate_discount(unit_price, offer, product, quantity, 5)
  end

  def calculate_discount(_unit_price, _offer, _product, _quantity), do: nil
end
