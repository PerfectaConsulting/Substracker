codeunit 70120 "Compliance Submission Handler"
{
    trigger OnRun()
    begin
    end;

    procedure SubmitCompliance(var ComplianceRec: Record "Compliance Overview")
    var
        ArchiveRec: Record "Compliance Overview Archive";
        NewRec: Record "Compliance Overview";
        NewStartDate: Date;
        NewEndDate: Date;
        NewDueDate: Date;
        TempDate: Date;
    begin
        // Archive current record
        ArchiveRec.Init();
        ArchiveRec.TransferFields(ComplianceRec, true);
        ArchiveRec."Source Compliance ID" := ComplianceRec.ID;
        ArchiveRec.Insert();

        // Update current record's status
        ComplianceRec.Status := ComplianceRec.Status::Submitted;
        ComplianceRec."Current Status" := ComplianceRec."Current Status"::Submitted;
        ComplianceRec."File Submitted" := Today;
        ComplianceRec.Modify();

        // Determine next cycle based on frequency
        case ComplianceRec."Filing Recurring Frequency" of
            ComplianceRec."Filing Recurring Frequency"::Monthly:
                begin
                    NewStartDate := CalcDate('<1M>', ComplianceRec."Filing Starting Date");
                    NewEndDate := CalcDate('<1M>', ComplianceRec."Filing End Date");
                    //NewDueDate := CalcDate('<1M>', ComplianceRec."Filing Due Date");
                    // Force CPF due dates to 14th of the month
                    IF ComplianceRec."Compliance Name" = 'CPF' THEN BEGIN
                        TempDate := CalcDate('<1M>', ComplianceRec."Filing Due Date");
                        NewDueDate := DMY2Date(14, Date2DMY(TempDate, 2), Date2DMY(TempDate, 3));
                    END ELSE
                        NewDueDate := CalcDate('<1M>', ComplianceRec."Filing Due Date");

                end;
            ComplianceRec."Filing Recurring Frequency"::Quarterly:
                begin
                    NewStartDate := CalcDate('<3M>', ComplianceRec."Filing Starting Date");
                    NewEndDate := CalcDate('<3M>', ComplianceRec."Filing End Date");
                    NewDueDate := CalcDate('<3M>', ComplianceRec."Filing Due Date");

                end;
            ComplianceRec."Filing Recurring Frequency"::Annually:
                begin
                    NewStartDate := CalcDate('<1Y>', ComplianceRec."Filing Starting Date");
                    NewEndDate := CalcDate('<1Y>', ComplianceRec."Filing End Date");
                    NewDueDate := CalcDate('<1Y>', ComplianceRec."Filing Due Date");
                end;
            ComplianceRec."Filing Recurring Frequency"::OneTime:
                exit; // No new cycle needed
        end;

        // Insert next cycle
        NewRec.Init();
        NewRec.TransferFields(ComplianceRec, false);
        NewRec."Filing Starting Date" := NewStartDate;
        NewRec."Filing End Date" := NewEndDate;
        NewRec."Filing Due Date" := NewDueDate;
        NewRec.Status := NewRec.Status::"Due Today";
        NewRec."Current Status" := NewRec."Current Status"::Active;
        NewRec."File Submitted" := 0D;
        NewRec."Submission Reference No." := '';
        NewRec."Penalty or Fine" := 0;
        NewRec."Payable Amount" := 0;
        NewRec.Insert();

        // Delete the original record to remove it from Compliance Type Selector
        ComplianceRec.Delete();
    end;

}