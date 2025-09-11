page 50121 "Employee Ext Card"
{
    PageType = Card;
    SourceTable = "Employee Ext";
    Caption = 'Employee Ext Card';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General Information';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee number.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }

                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first name of the employee.';
                    // REMOVED: ShowMandatory = true; (as requested - all fields non-mandatory)
                }

                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last name of the employee.';
                    // REMOVED: ShowMandatory = true; (as requested - all fields non-mandatory)
                }

                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the employee.';
                    Importance = Additional;
                }

                field("Email"; Rec.Email)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address of the employee.';
                }

                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number of the employee.';
                }

                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee status.';
                    StyleExpr = StatusStyle;
                }

                field("Blocked"; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the employee is blocked.';
                    StyleExpr = BlockedStyle;
                }
            }

            group(Employment)
            {
                Caption = 'Employment Details';

                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department code.';
                    // REMOVED: ShowMandatory = true; (as requested - all fields non-mandatory)
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

                field("Termination Date"; Rec."Termination Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the termination date if applicable.';
                }

                field("Manager Employee No."; Rec."Manager Employee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the manager employee number.';
                }

                field("Manager Name"; Rec."Manager Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the manager name.';
                }

                field("Salary"; Rec.Salary)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee salary.';
                }
            }

            group(AddressDetails)  // FIXED: Changed from "Address" to "AddressDetails" to avoid naming conflicts
            {
                Caption = 'Address Information';

                field("Employee Address"; Rec.Address)  // FIXED: Changed from "Address" to "Employee Address" to avoid naming conflicts
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee address.';
                }

                field("City"; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city.';
                }

                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the post code.';
                }

                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region code.';
                }
            }

            group(Statistics)
            {
                Caption = 'Statistics';

                field("Subscription Count"; Rec."Subscription Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of subscriptions assigned to this employee.';
                    DrillDownPageId = "Manage Subscriptions";

                    trigger OnDrillDown()
                    var
                        Subscription: Record Subscription;
                        SubscriptionList: Page "Manage Subscriptions";
                    begin
                        Subscription.SetRange("End-user", Rec."No.");
                        SubscriptionList.SetTableView(Subscription);
                        SubscriptionList.Run();
                    end;
                }

                field("Subordinates Count"; SubordinatesCount)
                {
                    ApplicationArea = All;
                    Caption = 'Direct Reports';
                    ToolTip = 'Shows the number of employees reporting to this employee.';
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        EmployeeExt: Record "Employee Ext";
                        EmployeeExtList: Page "Employee Ext List";
                    begin
                        EmployeeExt.SetRange("Manager Employee No.", Rec."No.");
                        EmployeeExtList.SetTableView(EmployeeExt);
                        EmployeeExtList.Run();
                    end;
                }
            }

            group(Administration)
            {
                Caption = 'Administration';

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the record was created.';
                }

                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the record.';
                }

                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the record was last modified.';
                }

                field("Last Modified By"; Rec."Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who last modified the record.';
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

            action(ViewSubordinates)
            {
                ApplicationArea = All;
                Caption = 'View Direct Reports';
                Image = Users;
                ToolTip = 'View employees reporting to this employee.';

                trigger OnAction()
                var
                    EmployeeExt: Record "Employee Ext";
                    EmployeeExtList: Page "Employee Ext List";
                begin
                    EmployeeExt.SetRange("Manager Employee No.", Rec."No.");
                    if EmployeeExt.IsEmpty() then begin
                        Message('No employees report to %1.', Rec."Full Name");
                        exit;
                    end;
                    EmployeeExtList.SetTableView(EmployeeExt);
                    EmployeeExtList.Run();
                end;
            }

            action(ToggleBlocked)
            {
                ApplicationArea = All;
                Caption = 'Toggle Blocked';
                Image = Lock;
                ToolTip = 'Block or unblock this employee.';

                trigger OnAction()
                begin
                    Rec.ToggleBlocked();
                    CurrPage.Update(false);
                end;
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

            action(EmployeeExtSetup)
            {
                ApplicationArea = All;
                Caption = 'Employee Ext Setup';
                Image = Setup;
                ToolTip = 'Configure employee ext settings.';
                RunObject = Page "Employee Ext Setup";
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(ViewSubscriptions_Promoted; ViewSubscriptions) { }
                actionref(ViewSubordinates_Promoted; ViewSubordinates) { }
                actionref(ToggleBlocked_Promoted; ToggleBlocked) { }
            }
            group(Setup)
            {
                Caption = 'Setup';
                actionref(ManageDepartments_Promoted; ManageDepartments) { }
                actionref(EmployeeExtSetup_Promoted; EmployeeExtSetup) { }
            }
        }
    }

    var
        StatusStyle: Text;
        BlockedStyle: Text;
        SubordinatesCount: Integer;

    trigger OnAfterGetRecord()
    begin
        UpdateStyles();
        UpdateStatistics();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateStyles();
        UpdateStatistics();
    end;

    local procedure UpdateStyles()
    begin
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

        if Rec.Blocked then
            BlockedStyle := 'Unfavorable'
        else
            BlockedStyle := 'Standard';
    end;

    local procedure UpdateStatistics()
    begin
        Rec.CalcFields("Subscription Count");
        SubordinatesCount := Rec.GetSubordinatesCount();
    end;
}
