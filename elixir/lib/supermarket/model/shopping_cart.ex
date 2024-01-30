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
          unit_price = SupermarketCatalog.get_unit_price(catalog, product)
          calculator = Discount.calculator(offer.offer_type)
          discount = calculator.calculate_discount(unit_price, offer, product, quantity)
          apply_offer(receipt, discount)
      end
    end)
  end

  defp apply_offer(receipt, nil), do: receipt
  defp apply_offer(receipt, discount), do: Receipt.add_discount(receipt, discount)
end
