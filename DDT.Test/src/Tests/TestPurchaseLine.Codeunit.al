codeunit 90104 "Test Purchase Line"
{
    Subtype = Test;

    [Test]
    procedure TestPurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
        TestInput: Codeunit "Test Input";
        Amount: Decimal;
        Quantity: Decimal;
        TotalAmount: Decimal;
    begin
        Amount := TestInput.GetTestInput().Element('amount').ValueAsDecimal();
        Quantity := TestInput.GetTestInput().Element('quantity').ValueAsDecimal();
        TotalAmount := TestInput.GetTestInput().Element('total').ValueAsDecimal();

        PurchaseLine."Unit Price (LCY)" := Amount;
        PurchaseLine.Validate("Quantity", Quantity);

        if TotalAmount <> PurchaseLine.Amount then
            Error('Total Amount is not correct');
    end;
}
