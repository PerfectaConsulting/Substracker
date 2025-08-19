page 50141 "Employee Ext Details FactBox"
{
    PageType = CardPart;
    SourceTable = "Employee Ext";
    Caption = 'Employee Ext Details';

    layout
    {
        area(content)
        {
            group(Details)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee number.';
                }

                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name.';
                }

                field("Email"; Rec.Email)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address.';
                }

                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department code.';
                }

                field("Position Title"; Rec."Position Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the position title.';
                }

                field("Employment Date"; Rec."Employment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employment date.';
                }

                field("Manager Employee No."; Rec."Manager Employee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the manager.';
                }

                field("Subscription Count"; Rec."Subscription Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows assigned subscriptions.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Subscription Count");
    end;
}
