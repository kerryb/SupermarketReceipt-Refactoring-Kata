defmodule Supermarket.Model.Discount do
  alias Supermarket.Model.Discount.TenPercent
  alias Supermarket.Model.Discount.FiveForAmount
  alias Supermarket.Model.Discount.TwoForAmount
  alias Supermarket.Model.Discount.ThreeForTwo
  defstruct [:product, :description, :discount_amount]

  def new(product, description, discount_amount) do
    %__MODULE__{product: product, description: description, discount_amount: discount_amount}
  end

  @calculators %{
    three_for_two: ThreeForTwo,
    two_for_amount: TwoForAmount,
    five_for_amount: FiveForAmount,
    ten_percent_discount: TenPercent
  }
  def calculator(offer_type), do: @calculators[offer_type]
end
