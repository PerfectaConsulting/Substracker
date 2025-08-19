page 70151 "Filtered Ledger"
{
    PageType = List;
    SourceTable = "Compliance Overview Archive";
    ApplicationArea = All;
    Caption = 'Compliance Archive';
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Compliance Name"; Rec."Compliance Name") { }
                field("Compliance Category"; Rec."Compliance Category") { }
                field("Filing Starting Date"; Rec."Filing Starting Date") { }
                field("Filing End Date"; Rec."Filing End Date") { }
                field("Filing Due Date"; Rec."Filing Due Date") { }
                field("Status"; Rec."Status") { }
                field("File Submitted"; Rec."File Submitted") { }
                field("Submission Reference No."; Rec."Submission Reference No.") { }
            }
        }
    }

    procedure SetComplianceName(ComplianceName: Text[100])
    begin
        Rec.SetFilter("Compliance Name", ComplianceName);
    end;
}