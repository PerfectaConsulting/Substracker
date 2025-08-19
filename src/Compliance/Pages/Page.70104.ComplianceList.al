page 70104 "Compliance List"
{
    PageType = List;
    SourceTable = "Compliance Overview";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Compliance List';
    CardPageId = "Compliance Card";
    Editable = true;
    InsertAllowed = false; // Prevents automatic insertion of a blank new record line
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Compliance Category"; Rec."Compliance Category")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Editable = false;
                }
                field("Compliance Name"; Rec."Compliance Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Editable = EditableComplianceName;
                }
                field("Governing Authority"; Rec."Governing Authority")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Submitted By"; Rec."Submitted By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Current Status"; Rec."Current Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Filing Due Date"; Rec."Filing Due Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleExpr;
                    Visible = false;
                    Editable = false;
                }
                field("Payable Amount"; Rec."Payable Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("Penalty or Fine"; Rec."Penalty or Fine")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Compliance)
            {
                action(NewCompliance)
                {
                    Caption = 'New Compliance';
                    Image = NewDocument;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Create a new compliance entry.';

                    trigger OnAction()
                    var
                        NewCompliance: Record "Compliance Overview";
                    begin
                        NewCompliance.Init();
                        NewCompliance.Insert(true);
                        PAGE.Run(PAGE::"Compliance Card", NewCompliance);
                    end;
                }
            }
        }
    }

    var
        StatusStyleExpr: Text;
        EditableComplianceName: Boolean;
        ArchiveRec: Record "Compliance Overview Archive";

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
        ArchiveRec.SetRange("Compliance Name", Rec."Compliance Name");
        if not ArchiveRec.IsEmpty then
            EditableComplianceName := true
        else
            EditableComplianceName := false;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetStatusStyle();
    end;

    trigger OnOpenPage()
    var
        DelRec: Record "Compliance Overview";
    begin
        // Delete any saved records where both Compliance Name and Governing Authority are empty
        DelRec.SetFilter("Compliance Name", '=''''');
        DelRec.SetFilter("Governing Authority", '=''''');
        if not DelRec.IsEmpty then
            DelRec.DeleteAll(true);

        // Apply filters to show only valid records
        Rec.SetCurrentKey("Compliance Name");
        Rec.SetFilter("Compliance Name", '<>''''');
        Rec.SetFilter("Governing Authority", '<>''''');
        // Removed the commented filter to ensure only valid records are shown
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Submitted:
                StatusStyleExpr := 'Favorable';
            Rec.Status::"Due Today":
                StatusStyleExpr := 'Attention';
            Rec.Status::"Upcoming Due":
                StatusStyleExpr := 'Subordinate';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;
}


// page 70104 "Compliance List"
// {
//     PageType = List;
//     SourceTable = "Compliance Overview";
//     ApplicationArea = All;
//     UsageCategory = Lists;
//     Caption = 'Compliance List';
//     CardPageId = "Compliance Card";
//     Editable = true;
//     RefreshOnActivate = true;


//     layout
//     {
//         area(content)
//         {
//             repeater(Group)
//             {

//                 field("Compliance Category"; Rec."Compliance Category")
//                 {
//                     ApplicationArea = All;
//                     Importance = Additional;
//                     Editable = false;
//                 }
//                 field("Compliance Name"; Rec."Compliance Name")
//                 {
//                     ApplicationArea = All;
//                     Importance = Promoted;
//                     Editable = EditableComplianceName;
//                 }
//                 field("Governing Authority"; Rec."Governing Authority")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }

//                 field("Submitted By"; Rec."Submitted By")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }

//                 field("Current Status"; Rec."Current Status")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//                 field("Filing Due Date"; Rec."Filing Due Date")
//                 {
//                     ApplicationArea = All;
//                     Visible = false;
//                     Editable = false;
//                 }
//                 field("Status"; Rec."Status")
//                 {
//                     ApplicationArea = All;
//                     StyleExpr = StatusStyleExpr;
//                     Visible = false;
//                     Editable = false;
//                 }
//                 field("Payable Amount"; Rec."Payable Amount")
//                 {
//                     ApplicationArea = All;
//                     Visible = false;
//                     Editable = false;
//                 }
//                 field("Penalty or Fine"; Rec."Penalty or Fine")
//                 {
//                     ApplicationArea = All;
//                     Visible = false;
//                     Editable = false;
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(navigation)
//         {
//             group(Compliance)
//             {
//                 action(NewCompliance)
//                 {
//                     Caption = 'New Compliance';
//                     Image = NewDocument;
//                     ApplicationArea = All;
//                     Promoted = true;
//                     PromotedCategory = Process;
//                     PromotedIsBig = true;
//                     ToolTip = 'Create a new compliance entry.';

//                     trigger OnAction()
//                     var
//                         NewCompliance: Record "Compliance Overview";
//                     begin
//                         NewCompliance.Init();
//                         NewCompliance.Insert(true);
//                         PAGE.Run(PAGE::"Compliance Card", NewCompliance);
//                     end;

//                 }
//             }
//         }
//     }


//     var
//         StatusStyleExpr: Text;
//         EditableComplianceName: Boolean;
//         ArchiveRec: Record "Compliance Overview Archive";

//     trigger OnAfterGetRecord()
//     begin
//         SetStatusStyle();
//         ArchiveRec.SetRange("Compliance Name", Rec."Compliance Name");
//         if not ArchiveRec.IsEmpty then
//             EditableComplianceName := true
//         else
//             EditableComplianceName := false;
//     end;

//     trigger OnAfterGetCurrRecord()
//     begin
//         SetStatusStyle();
//     end;

//     trigger OnOpenPage()
//     begin
//         Rec.SetCurrentKey("Compliance Name");
//         Rec.SetFilter("Compliance Name", '<>''''');
//         Rec.SetFilter("Governing Authority", '<>''''');
//         //Rec.SetRange("Current Status", Rec."Current Status"::Compliant); // Only show active compliances
//     end;


//     local procedure SetStatusStyle()
//     begin
//         case Rec.Status of
//             Rec.Status::Submitted:
//                 StatusStyleExpr := 'Favorable';
//             Rec.Status::"Due Today":
//                 StatusStyleExpr := 'Attention';
//             Rec.Status::"Upcoming Due":
//                 StatusStyleExpr := 'Subordinate';
//             else
//                 StatusStyleExpr := 'Standard';
//         end;
//     end;
// }