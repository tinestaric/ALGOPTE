codeunit 90101 "On Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        ImportTestCases: Codeunit "Import Test Cases";
    begin
        ImportTestCases.ImportTestCases();
    end;


}