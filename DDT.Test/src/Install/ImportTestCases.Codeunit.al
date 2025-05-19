codeunit 90103 "Import Test Cases"
{
    internal procedure ImportTestCases()
    begin
        ImportTestCasesFromFiles();
        CreateALTestSuite();

        // Call the mapping codeunit to handle the mappings
        MapTestCasesToCodeunits();
    end;

    local procedure ImportTestCasesFromFiles()
    var
        TestCases: List of [Text];
        TestCase: Text;
        InStr: InStream;
    begin
        TestCases := NavApp.ListResources('*.jsonl');
        foreach TestCase in TestCases do begin
            NavApp.GetResource(TestCase, InStr);
            ImportTestInputs(TestCase, InStr);
        end;

        TestCases := NavApp.ListResources('*.yaml');
        foreach TestCase in TestCases do begin
            NavApp.GetResource(TestCase, InStr);
            ImportTestInputs(TestCase, InStr);
        end;
    end;

    /// <summary>
    /// Import the Test Input Dataset from an InStream of a dataset in a supported format.
    /// Overwrite the dataset if the dataset with same filename is already imported by the same app
    /// Error if the dataset with the same filename is created by a different app
    /// </summary>
    /// <param name="DatasetFileName">The file name of the dataset file which will be used in the description of the dataset.</param>
    /// <param name="DatasetInStream">The InStream of the dataset file.</param>
    local procedure ImportTestInputs(DatasetFileName: Text; var DatasetInStream: InStream)
    var
        TestInputGroup: Record "Test Input Group";
        TestInputsManagement: Codeunit "Test Inputs Management";
        CallerModuleInfo: ModuleInfo;
        EmptyGuid: Guid;
        SameDatasetNameErr: Label 'The test input dataset %1 with the same file name already exists. The dataset was uploaded %2. Please rename the current dataset or delete the existing dataset.', Comment = '%1 = test input dataset Name, %2 = "from the UI" or "by the app id: {app_id}';
        SourceOfTheDatasetIsUILbl: Label 'from the UI';
        SourceOfTheDatasetIsAppIdLbl: Label 'by the app id: %1', Comment = '%1 = app id';
    begin
        // Check if the dataset with the same filename exists
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        TestInputGroup.SetLoadFields(Code, "Imported by AppId");

        if TestInputGroup.Get(TestInputsManagement.GetTestInputGroupCodeFromFileName(DatasetFileName)) then
            if TestInputGroup."Imported by AppId" = CallerModuleInfo.Id then
                TestInputGroup.Delete(true) // Overwrite the dataset
            else
                case TestInputGroup."Imported by AppId" of
                    EmptyGuid:
                        Error(SameDatasetNameErr, DatasetFileName, SourceOfTheDatasetIsUILbl)
                    else
                        Error(SameDatasetNameErr, DatasetFileName, StrSubstNo(SourceOfTheDatasetIsAppIdLbl, TestInputGroup."Imported by AppId"));
                end;

        TestInputsManagement.UploadAndImportDataInputs(DatasetFileName, DatasetInStream, CallerModuleInfo.Id);
    end;

    local procedure CreateALTestSuite()
    var
        ALTestSuite: Record "AL Test Suite";
        MethodLineRec: Record "Test Method Line";
        TestRunnerMgt: Codeunit "Test Runner - Mgt";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        TestSuiteNameLbl: Label 'DDT365', Locked = true, MaxLength = 10;
        TestSuiteDescriptionLbl: Label 'Data Driven Tests', Locked = true, MaxLength = 30;
        CodeunitFilter: Text;
    begin
        CodeunitFilter := '90100..90149';

        if (not ALTestSuite.Get(TestSuiteNameLbl)) then begin
            ALTestSuite.Init();
            ALTestSuite.Validate(Name, TestSuiteNameLbl);
            ALTestSuite.Validate(Description, TestSuiteDescriptionLbl);
            ALTestSuite.Validate("Test Runner Id", TestRunnerMgt.GetCodeIsolationTestRunner());
            ALTestSuite.Insert(true);
        end;

        MethodLineRec.SetRange("Test Suite", TestSuiteNameLbl);
        MethodLineRec.SetFilter("Test Codeunit", CodeunitFilter);
        MethodLineRec.DeleteAll(true);

        TestSuiteMgt.SelectTestMethodsByRange(ALTestSuite, CodeunitFilter);
    end;

    /// <summary>
    /// Initializes the test case mapping by calling the mapping codeunit
    /// </summary>
    local procedure MapTestCasesToCodeunits()
    var
        ALTestSuite: Record "AL Test Suite";
        TestCaseMapping: Codeunit "Test Case Mapping";
    begin
        // Find the test suite
        ALTestSuite.SetRange(Name, 'DDT365');
        if not ALTestSuite.FindFirst() then
            exit;

        // Call the mapping codeunit to handle the mappings
        TestCaseMapping.AssignTestCasesToCodeunits(ALTestSuite.Name);
    end;

    /// <summary>
    /// Assigns test cases to test methods. This is called by the mapping codeunit.
    /// </summary>
    /// <param name="TestInputGroup">The test input group record variable</param>
    /// <param name="TestMethodLine">The test method line record variable</param>
    procedure AssignTestCasesToTestMethods(
        var TestInputGroup: Record "Test Input Group";
        var TestMethodLine: Record "Test Method Line"
    )
    var
        TestInput: Record "Test Input";
        TestInputsManagement: Codeunit "Test Inputs Management";
    begin
        if TestInputGroup.FindSet() then
            repeat
                TestInput.SetRange("Test Input Group Code", TestInputGroup.Code);
                TestInputsManagement.AssignDataDrivenTest(TestMethodLine, TestInput);
            until TestInputGroup.Next() = 0;

        TestMethodLine.Find();
        TestMethodLine.Delete(true)
    end;
}

