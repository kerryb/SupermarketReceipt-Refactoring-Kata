defmodule Supermarket.Model.Discount.ThreeForTwo do
  alias Supermarket.Model.Discount

  def calculate_discount(unit_price, _offer, product, quantity) when quantity >= 3 do
    quantity_as_int = trunc(quantity)
    discount_count = div(quantity_as_int, 3)

    discount_amount =
      (quantity - (discount_count * 2 + Integer.mod(quantity_as_int, 3))) * unit_price

    Discount.new(product, "3 for 2", -discount_amount)
  end

  def calculate_discount(_unit_price, _offer, _product, _quantity), do: nil
end
