page 50138 "End User Subpage"
{
    Caption = 'End Users';
    PageType = ListPart;
    SourceTable = "End User";
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(EndUsers)
            {
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                    Caption = 'Employee No.';
                    ToolTip = 'Select the employee number.';
                }

                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Name';
                    ToolTip = 'Shows the employee name.';
                    Editable = false;
                }

                field("Employee Email"; Rec."Employee Email")
                {
                    ApplicationArea = All;
                    Caption = 'Email';
                    ToolTip = 'Shows the employee email.';
                    Editable = false;
                }

                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    Caption = 'Department';
                    ToolTip = 'Shows the employee department.';
                    Editable = false;
                }

                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Shows the status.';
                    StyleExpr = StatusStyle;
                }

                field("Primary End User"; Rec."Primary End User")
                {
                    ApplicationArea = All;
                    Caption = 'Primary';
                    ToolTip = 'Indicates if this is the primary end user.';
                    StyleExpr = PrimaryStyle;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SetAsPrimary)
            {
                Caption = 'Set as Primary';
                Image = SelectField;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.SetAsPrimary();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        StatusStyle: Text;
        PrimaryStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Active:
                StatusStyle := 'Favorable';
            Rec.Status::Inactive:
                StatusStyle := 'Unfavorable';
            Rec.Status::"On Leave":
                StatusStyle := 'Attention';
            else
                StatusStyle := 'Standard';
        end;

        if Rec."Primary End User" then
            PrimaryStyle := 'Strong'
        else
            PrimaryStyle := 'Standard';
    end;
}
