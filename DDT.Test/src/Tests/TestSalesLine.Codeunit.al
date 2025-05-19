codeunit 90100 "Test Sales Line"
{
    Subtype = Test;

    [Test]
    procedure TestSalesLine()
    var
        SalesLine: Record "Sales Line";
        TestInput: Codeunit "Test Input";
        Amount: Decimal;
        Quantity: Decimal;
        TotalAmount: Decimal;
    begin
        Amount := TestInput.GetTestInput().Element('amount').ValueAsDecimal();
        Quantity := TestInput.GetTestInput().Element('quantity').ValueAsDecimal();
        TotalAmount := TestInput.GetTestInput().Element('total').ValueAsDecimal();


        SalesLine."Unit Price" := Amount;
        SalesLine.Validate("Quantity", Quantity);

        if TotalAmount <> SalesLine.Amount then
            Error('Total Amount is not correct');
    end;

    [Test]
    procedure TestSalesLine2()
    var
        SalesLine: Record "Sales Line";
        TestInput: Codeunit "Test Input";
        Amount: Decimal;
        Quantity: Decimal;
        TotalAmount: Decimal;
    begin
        Amount := TestInput.GetTestInput().Element('amount').ValueAsDecimal();
        Quantity := TestInput.GetTestInput().Element('quantity').ValueAsDecimal();
        TotalAmount := TestInput.GetTestInput().Element('total').ValueAsDecimal();


        SalesLine."Unit Price" := Amount;
        SalesLine.Validate("Quantity", Quantity);

        if TotalAmount <> SalesLine.Amount then
            Error('Total Amount is not correct');
    end;
}