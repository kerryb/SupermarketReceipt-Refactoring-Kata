defmodule Supermarket.Model.Discount.NForAmount do
  alias Supermarket.Model.Discount

  def calculate_discount(unit_price, offer, product, quantity, qualifying_quantity) do
    quantity_as_int = trunc(quantity)
    discount_count = div(quantity_as_int, qualifying_quantity)

    discount_total =
      unit_price * quantity -
        (offer.argument * discount_count +
           Integer.mod(quantity_as_int, qualifying_quantity) * unit_price)

    Discount.new(product, "#{qualifying_quantity} for #{offer.argument}", -discount_total)
  end
end
