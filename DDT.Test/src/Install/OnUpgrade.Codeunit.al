codeunit 90102 "On Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        ImportTestCases: Codeunit "Import Test Cases";
    begin
        ImportTestCases.ImportTestCases();
    end;
}
