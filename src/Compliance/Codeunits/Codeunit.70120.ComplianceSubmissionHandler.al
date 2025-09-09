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

        // --- NEW: TransferFields won't copy Bank Debit Date because field IDs differ across tables
        ArchiveRec."Bank Debit Date" := ComplianceRec."Bank Debit Date";

        ArchiveRec."Source Compliance ID" := ComplianceRec.ID;
        ArchiveRec.Insert();

        // Update current record's status
        ComplianceRec.Status := ComplianceRec.Status::Submitted;
        //ComplianceRec."Current Status" := ComplianceRec."Current Status"::Submitted;
        ComplianceRec."File Submitted" := Today; // keeps your existing behavior
        ComplianceRec.Modify();

        // Determine next cycle based on frequency
        case ComplianceRec."Filing Recurring Frequency" of
            ComplianceRec."Filing Recurring Frequency"::Monthly:
                begin
                    NewStartDate := CalcDate('<1M>', ComplianceRec."Filing Starting Date");
                    NewEndDate := CalcDate('<1M>', ComplianceRec."Filing End Date");

                    // CPF due date forced to 14th of the month
                    if ComplianceRec."Compliance Name" = 'CPF' then begin
                        TempDate := CalcDate('<1M>', ComplianceRec."Filing Due Date");
                        NewDueDate := DMY2Date(14, Date2DMY(TempDate, 2), Date2DMY(TempDate, 3));
                    end else
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
        //NewRec."Current Status" := NewRec."Current Status"::Active;
        NewRec."File Submitted" := 0D;
        NewRec."Submission Reference No." := '';
        NewRec."Penalty or Fine" := 0;
        NewRec."Payable Amount" := 0;

        // --- NEW: Do not carry forward bank debit date to the next cycle
        NewRec."Bank Debit Date" := 0D;

        NewRec.Insert();

        // Delete the original record to remove it from Compliance Type Selector
        ComplianceRec.Delete();
    end;
}
