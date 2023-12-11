defmodule ReceiptPrinterTest do
  use ExUnit.Case, async: true
  import Approvals

  alias Supermarket.Discount
  alias Supermarket.Product
  alias Supermarket.Receipt

  @toothbrush %Product{name: "toothbrush", unit: :each}
  @apples %Product{name: "apples", unit: :kilo}

  setup do
    %{receipt: %Receipt{}}
  end

  approve "one line item", %{receipt: receipt} do
    receipt = Receipt.add_product(receipt, @toothbrush, 1, 0.99, 0.99)
    verify(ReceiptPrinter.print_receipt(receipt, 40))
  end

  approve "quantity two", %{receipt: receipt} do
    receipt = Receipt.add_product(receipt, @toothbrush, 2, 0.99, 0.99 * 2)
    verify(ReceiptPrinter.print_receipt(receipt, 40))
  end

  approve "loose weight", %{receipt: receipt} do
    receipt = Receipt.add_product(receipt, @apples, 2.3, 1.99, 1.99 * 2.3)
    verify(ReceiptPrinter.print_receipt(receipt, 40))
  end

  approve "total", %{receipt: receipt} do
    receipt =
      receipt
      |> Receipt.add_product(@toothbrush, 1, 0.99, 2 * 0.99)
      |> Receipt.add_product(@apples, 0.75, 1.99, 1.99 * 0.75)

    verify(ReceiptPrinter.print_receipt(receipt, 40))
  end

  approve "discounts", %{receipt: receipt} do
    receipt =
      Receipt.add_discount(receipt, %Discount{
        product: @apples,
        description: "3 for 2",
        discount_amount: -0.99
      })

    verify(ReceiptPrinter.print_receipt(receipt, 40))
  end

  approve "print whole receipt", %{receipt: receipt} do
    receipt =
      receipt
      |> Receipt.add_product(@toothbrush, 1, 0.99, 0.99)
      |> Receipt.add_product(@toothbrush, 2, 0.99, 0.99 * 2)
      |> Receipt.add_product(@apples, 0.75, 1.99, 1.99 * 0.75)
      |> Receipt.add_discount(%Discount{
        product: @toothbrush,
        description: "3 for 2",
        discount_amount: -0.99
      })

    verify(ReceiptPrinter.print_receipt(receipt, 40))
  end
end