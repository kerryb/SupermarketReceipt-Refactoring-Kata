defmodule Supermarket.Model.Discount.TenPercent do
  alias Supermarket.Model.Discount

  def calculate_discount(unit_price, offer, product, quantity) do
    Discount.new(
      product,
      "#{offer.argument}% off",
      -quantity * unit_price * offer.argument / 100.0
    )
  end
end
