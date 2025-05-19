codeunit 90105 "Test Case Mapping"
{
    /// <summary>
    /// Assigns test cases to specific codeunits based on predefined mappings
    /// </summary>
    /// <param name="TestSuiteName">Name of the test suite</param>
    procedure AssignTestCasesToCodeunits(TestSuiteName: Code[10])
    begin
        // Map Codeunit "Test Sales Line" to test cases starting with 'SALES*'
        MapCodeunitToTestCases(TestSuiteName, Codeunit::"Test Sales Line", 'SALES*');

        // Map Codeunit "Test Purchase Line" to test cases starting with 'PURCH*'
        MapCodeunitToTestCases(TestSuiteName, Codeunit::"Test Purchase Line", 'PURCH*');

        // Example of additional mappings:
        // MapCodeunitToTestCases(TestSuiteName, Codeunit::"Test Inventory", 'INVENTORY*');
        // MapCodeunitToTestCases(TestSuiteName, Codeunit::"Test GL", 'GL*');
    end;

    /// <summary>
    /// Maps a specific codeunit to test cases matching a pattern
    /// </summary>
    /// <param name="TestSuiteName">Name of the test suite</param>
    /// <param name="CodeunitId">ID of the codeunit to map</param>
    /// <param name="TestCasePattern">Pattern to match test cases</param>
    local procedure MapCodeunitToTestCases(TestSuiteName: Code[10]; CodeunitId: Integer; TestCasePattern: Text)
    var
        TestMethodLine: Record "Test Method Line";
        TestInputGroup: Record "Test Input Group";
        ImportTestCases: Codeunit "Import Test Cases";
    begin
        // Get test methods for this codeunit
        TestMethodLine.SetRange("Test Suite", TestSuiteName);
        TestMethodLine.SetRange("Test Codeunit", CodeunitId);

        if TestMethodLine.FindFirst() then begin
            // Find matching test input groups
            TestInputGroup.SetFilter(Code, TestCasePattern);
            ImportTestCases.AssignTestCasesToTestMethods(TestInputGroup, TestMethodLine);
        end;
    end;
}