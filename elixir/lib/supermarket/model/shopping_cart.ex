defmodule Supermarket.Model.ShoppingCart do
  require IEx
  alias Supermarket.Model.Discount
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
          discount = calculate_discount(catalog, offer, product, quantity)
          apply_offer(receipt, discount)
      end
    end)
  end

  defp apply_offer(receipt, nil), do: receipt
  defp apply_offer(receipt, discount), do: Receipt.add_discount(receipt, discount)

  defp calculate_discount(catalog, offer, product, quantity) do
    unit_price = SupermarketCatalog.get_unit_price(catalog, product)
    quantity_as_int = trunc(quantity)

    case offer.offer_type do
      _ ->
        discount = nil
        qualifying_quantity = 1

        {discount, qualifying_quantity} =
          cond do
            offer.offer_type == :three_for_two ->
              {discount, 3}

            offer.offer_type == :two_for_amount ->
              if quantity_as_int >= 2 do
                qualifying_quantity = 2
                int_division = div(quantity_as_int, qualifying_quantity)
                price_per_unit = offer.argument * int_division
                the_total = Integer.mod(quantity_as_int, 2) * unit_price
                total = price_per_unit + the_total
                discount_n = unit_price * quantity - total
                {Discount.new(product, "2 for #{offer.argument}", -discount_n), 2}
              else
                {discount, qualifying_quantity}
              end

            true ->
              {discount, 2}
          end

        qualifying_quantity =
          if offer.offer_type == :five_for_amount, do: 5, else: qualifying_quantity

        discount_count = div(quantity_as_int, qualifying_quantity)

        cond do
          offer.offer_type == :three_for_two and quantity_as_int > 2 ->
            discount_amount =
              quantity * unit_price -
                (discount_count * 2 * unit_price + Integer.mod(quantity_as_int, 3) * unit_price)

            Discount.new(product, "3 for 2", -discount_amount)

          offer.offer_type == :ten_percent_discount ->
            Discount.new(
              product,
              "#{offer.argument}% off",
              -quantity * unit_price * offer.argument / 100.0
            )

          offer.offer_type == :five_for_amount and quantity_as_int >= 5 ->
            discount_total =
              unit_price * quantity -
                (offer.argument * discount_count + Integer.mod(quantity_as_int, 5) * unit_price)

            Discount.new(product, "#{qualifying_quantity} for #{offer.argument}", -discount_total)

          true ->
            discount
        end
    end
  end
end
