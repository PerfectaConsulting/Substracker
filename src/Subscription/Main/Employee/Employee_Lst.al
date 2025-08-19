page 50120 "Employee Ext List"
{
    PageType = List;
    SourceTable = "Employee Ext";
    Caption = 'Employee Ext List';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Employee Ext Card";

    layout
    {
        area(content)
        {
            repeater(Employees)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee number.';
                }

                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the employee.';
                }

                field("Email"; Rec.Email)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address of the employee.';
                }

                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department code.';
                }

                field("Department Description"; Rec."Department Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department description.';
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

                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee status.';
                    StyleExpr = StatusStyle;
                }

                field("Manager Employee No."; Rec."Manager Employee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the manager employee number.';
                }

                field("Subscription Count"; Rec."Subscription Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of subscriptions assigned to this employee.';
                    BlankZero = true;
                }

                field("Blocked"; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the employee is blocked.';
                    StyleExpr = BlockedStyle;
                }
            }
        }

        area(FactBoxes)
        {
            part(EmployeeExtDetails; "Employee Ext Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(NewEmployeeExt)
            {
                ApplicationArea = All;
                Caption = 'New Employee Ext';
                Image = New;
                ToolTip = 'Create a new employee ext record.';

                // trigger OnAction()
                // begin
                //     CurrPage.NewRecord();
                // end;
            }

            action(ToggleBlocked)
            {
                ApplicationArea = All;
                Caption = 'Toggle Blocked';
                Image = Lock;
                ToolTip = 'Block or unblock the selected employee.';

                trigger OnAction()
                begin
                    Rec.ToggleBlocked();
                    CurrPage.Update(false);
                end;
            }

            action(ViewSubscriptions)
            {
                ApplicationArea = All;
                Caption = 'View Subscriptions';
                Image = List;
                ToolTip = 'View subscriptions assigned to this employee.';

                trigger OnAction()
                var
                    Subscription: Record Subscription;
                    SubscriptionList: Page "Manage Subscriptions";
                begin
                    Subscription.SetRange("End-user", Rec."No.");
                    SubscriptionList.SetTableView(Subscription);
                    SubscriptionList.Run();
                end;
            }

            action(EmployeeExtSetup)
            {
                ApplicationArea = All;
                Caption = 'Employee Ext Setup';
                Image = Setup;
                ToolTip = 'Configure employee ext number series and settings.';
                RunObject = Page "Employee Ext Setup";
            }
        }

        area(navigation)
        {
            action(ManageDepartments)
            {
                ApplicationArea = All;
                Caption = 'Manage Departments';
                Image = Departments;
                ToolTip = 'Manage department master data.';
                RunObject = Page Departments;
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(NewEmployeeExt_Promoted; NewEmployeeExt) { }
                actionref(ToggleBlocked_Promoted; ToggleBlocked) { }
                actionref(ViewSubscriptions_Promoted; ViewSubscriptions) { }
            }
            group(Setup)
            {
                Caption = 'Setup';
                actionref(EmployeeExtSetup_Promoted; EmployeeExtSetup) { }
                actionref(ManageDepartments_Promoted; ManageDepartments) { }
            }
        }
    }

    var
        StatusStyle: Text;
        BlockedStyle: Text;

    trigger OnAfterGetRecord()
    begin
        // Set styling based on status
        case Rec.Status of
            Rec.Status::Active:
                StatusStyle := 'Favorable';
            Rec.Status::Inactive:
                StatusStyle := 'Unfavorable';
            Rec.Status::OnLeave:
                StatusStyle := 'Attention';
            else
                StatusStyle := 'Standard';
        end;

        // Set styling for blocked status
        if Rec.Blocked then
            BlockedStyle := 'Unfavorable'
        else
            BlockedStyle := 'Standard';

        // Update FlowFields
        Rec.CalcFields("Subscription Count");
    end;
}
