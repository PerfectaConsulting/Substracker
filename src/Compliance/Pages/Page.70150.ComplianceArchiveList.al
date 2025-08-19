page 70150 "Compliance Archive List"
{
    PageType = List;
    SourceTable = "Compliance Overview Archive";
    ApplicationArea = All;
    Caption = 'Compliance Archive';
    UsageCategory = Administration;
    Editable = false;
    SourceTableView = SORTING(SystemCreatedAt) ORDER(Descending);

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
                field("Submitted By"; Rec."Submitted By") { }
                field("Submission Reference No."; Rec."Submission Reference No.") { }
            }
        }
    }

}