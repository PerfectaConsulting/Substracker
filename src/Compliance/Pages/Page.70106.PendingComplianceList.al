page 70106 "Pending Compliance List"
{
    PageType = List;
    SourceTable = "Compliance Overview";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Pending Compliance';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field("Compliance Name"; Rec."Compliance Name") { ApplicationArea = All; }
                field("Compliance Category"; Rec."Compliance Category") { ApplicationArea = All; }
                field("Governing Authority"; Rec."Governing Authority") { ApplicationArea = All; }
                field("Current Status"; Rec."Current Status") { ApplicationArea = All; }
                field("Filing Due Date"; Rec."Filing Due Date") { ApplicationArea = All; }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;

                }
                field("Payable Amount"; Rec."Payable Amount") { ApplicationArea = All; }
                field("Penalty or Fine"; Rec."Penalty or Fine") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange(Status, Rec.Status::"No Due Date");
    end;
}
