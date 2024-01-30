defmodule Supermarket.Model.ShoppingCart do
  require IEx
  alias Supermarket.Model.Discount
  alias Supermarket.Model.Discount.ThreeForTwo
  alias Supermarket.Model.ProductQuantity
  alias Supermarket.Model.Receipt
  alias Supermarket.Model.SupermarketCatalog

  defstruct [:items, :product_quantities]

  def new, do: %__MODULE__{items: [], product_quantities: %{}}

  def add_item(cart, product) do
    add_item_quantity(cart, product, 1.0)
  end

  def add_item_quantity(cart, product, quantity) do
    cart
    |> Map.update!(:items, &[ProductQuantity.new(product, quantity) | &1])
    |> Map.update!(:product_quantities, fn product_quantities ->
      if Map.has_key?(product_quantities, product) do
        Map.put(product_quantities, product, product_quantities[product] + quantity)
      else
        Map.put(product_quantities, product, quantity)
      end
    end)
  end

  def handle_offers(cart, receipt, offers, catalog) do
    cart.product_quantities
    |> Map.keys()
    |> Enum.reduce(receipt, fn product, receipt ->
      quantity = cart.product_quantities[product]

      case offers[product] do
        nil ->
          receipt

        offer ->
          unit_price = SupermarketCatalog.get_unit_price(catalog, product)
          discount = calculate_discount(unit_price, offer, product, quantity)
          apply_offer(receipt, discount)
      end
    end)
  end

  defp apply_offer(receipt, nil), do: receipt
  defp apply_offer(receipt, discount), do: Receipt.add_discount(receipt, discount)

  defp calculate_discount(unit_price, %{offer_type: :three_for_two}, product, quantity)
       when quantity >= 3 do
    ThreeForTwo.calculate_discount(unit_price, product, quantity)
  end

  defp calculate_discount(unit_price, %{offer_type: :two_for_amount} = offer, product, quantity)
       when quantity >= 2 do
    n_for_amount_discount(unit_price, offer, product, quantity, 2)
  end

  defp calculate_discount(unit_price, %{offer_type: :five_for_amount} = offer, product, quantity)
       when quantity >= 5 do
    n_for_amount_discount(unit_price, offer, product, quantity, 5)
  end

  defp calculate_discount(
         unit_price,
         %{offer_type: :ten_percent_discount} = offer,
         product,
         quantity
       ) do
    Discount.new(
      product,
      "#{offer.argument}% off",
      -quantity * unit_price * offer.argument / 100.0
    )
  end

  defp calculate_discount(_unit_price, _offer, _product, _quantity), do: nil

  defp n_for_amount_discount(unit_price, offer, product, quantity, qualifying_quantity) do
    quantity_as_int = trunc(quantity)
    discount_count = div(quantity_as_int, qualifying_quantity)

    discount_total =
      unit_price * quantity -
        (offer.argument * discount_count +
           Integer.mod(quantity_as_int, qualifying_quantity) * unit_price)

    Discount.new(product, "#{qualifying_quantity} for #{offer.argument}", -discount_total)
  end
end
