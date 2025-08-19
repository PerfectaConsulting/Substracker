page 50137 "End User List"
{
    Caption = 'End User List';
    PageType = List;
    ApplicationArea = All;
    SourceTable = "End User";
    UsageCategory = Lists;
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
                    Caption = 'End User (Employee)';
                    ToolTip = 'Select the employee who will be the end user for this subscription.';
                }

                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Name';
                    ToolTip = 'Shows the full name of the employee.';
                    Editable = false;
                }

                field("Employee Email"; Rec."Employee Email")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Email';
                    ToolTip = 'Shows the email address of the employee.';
                    Editable = false;
                }

                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    Caption = 'Department';
                    ToolTip = 'Shows the department of the employee.';
                    Editable = false;
                }

                field("Department Description"; Rec."Department Description")
                {
                    ApplicationArea = All;
                    Caption = 'Department Description';
                    ToolTip = 'Shows the description of the department.';
                    Editable = false;
                }

                field("Position Title"; Rec."Position Title")
                {
                    ApplicationArea = All;
                    Caption = 'Position';
                    ToolTip = 'Shows the position title of the employee.';
                    Editable = false;
                }

                field("Subscription No."; Rec."Subscription No.")
                {
                    ApplicationArea = All;
                    Caption = 'Subscription No.';
                    ToolTip = 'Shows the subscription number.';
                    Editable = false; // Made read-only since it's auto-populated
                }

                field("Subscription Name"; Rec."Subscription Name")
                {
                    ApplicationArea = All;
                    Caption = 'Subscription Name';
                    ToolTip = 'Shows the name of the subscription service.';
                    Editable = false;
                }

                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Shows the status of the end user assignment.';
                    StyleExpr = StatusStyle;
                }

                field("Primary End User"; Rec."Primary End User")
                {
                    ApplicationArea = All;
                    Caption = 'Primary';
                    ToolTip = 'Indicates if this is the primary end user for the subscription.';
                    StyleExpr = PrimaryStyle;
                }

                field("Date Added"; Rec."Date Added")
                {
                    ApplicationArea = All;
                    Caption = 'Date Added';
                    ToolTip = 'Shows when the employee was assigned to the subscription.';
                    Editable = false;
                }

                field("Added By"; Rec."Added By")
                {
                    ApplicationArea = All;
                    Caption = 'Added By';
                    ToolTip = 'Shows who added the employee to the subscription.';
                    Editable = false;
                }
            }
        }

        area(FactBoxes)
        {
            part(EmployeeDetails; "Employee Ext Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Employee No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(AddEndUser)
            {
                Caption = 'Add End User';
                Image = AddAction;
                ApplicationArea = All;
                ToolTip = 'Add a new employee as an end user to a subscription.';

                trigger OnAction()
                var
                    NewRec: Record "End User";
                begin
                    NewRec.Init();
                    // Auto-populate Subscription No. if we have a filter
                    if FilteredSubscriptionNo <> '' then
                        NewRec."Subscription No." := FilteredSubscriptionNo;
                    NewRec.Insert(true);
                    CurrPage.SetRecord(NewRec);
                    CurrPage.Update(false);
                end;
            }

            action(RemoveEndUser)
            {
                Caption = 'Remove End User';
                Image = RemoveLine;
                ApplicationArea = All;
                ToolTip = 'Remove the selected employee from the subscription.';

                trigger OnAction()
                begin
                    if Rec."Entry No." = 0 then
                        exit;
                    if Confirm('Remove employee %1 from subscription %2?', false, Rec."Employee Name", Rec."Subscription Name") then
                        Rec.Delete(true);
                end;
            }

            action(SetAsPrimary)
            {
                Caption = 'Set as Primary';
                Image = SelectField;
                ApplicationArea = All;
                ToolTip = 'Set this employee as the primary end user for the subscription.';

                trigger OnAction()
                begin
                    if Rec."Entry No." = 0 then
                        exit;
                    Rec.SetAsPrimary();
                    CurrPage.Update(false);
                end;
            }

            action(ActivateEndUser)
            {
                Caption = 'Activate';
                Image = Approve;
                ApplicationArea = All;
                Enabled = ActivateEnabled;
                ToolTip = 'Activate the selected end user.';

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Active;
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }

            action(DeactivateEndUser)
            {
                Caption = 'Deactivate';
                Image = Cancel;
                ApplicationArea = All;
                Enabled = DeactivateEnabled;
                ToolTip = 'Deactivate the selected end user.';

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Inactive;
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }

            action(ViewEmployee)
            {
                Caption = 'View Employee';
                Image = Employee;
                ApplicationArea = All;
                ToolTip = 'View the employee card for the selected end user.';

                trigger OnAction()
                var
                    EmployeeExt: Record "Employee Ext";
                    EmployeeCard: Page "Employee Ext Card";
                begin
                    if Rec."Employee No." = '' then
                        exit;
                    if EmployeeExt.Get(Rec."Employee No.") then begin
                        EmployeeCard.SetRecord(EmployeeExt);
                        EmployeeCard.Run();
                    end;
                end;
            }

            action(ViewSubscription)
            {
                Caption = 'View Subscription';
                Image = ServiceItem;
                ApplicationArea = All;
                ToolTip = 'View the subscription card for the selected subscription.';

                trigger OnAction()
                var
                    Subscription: Record Subscription;
                    SubscriptionCard: Page "Add Subscription";
                begin
                    if Rec."Subscription No." = '' then
                        exit;
                    if Subscription.Get(Rec."Subscription No.") then begin
                        SubscriptionCard.SetRecord(Subscription);
                        SubscriptionCard.Run();
                    end;
                end;
            }
        }

        area(navigation)
        {
            action(ManageEmployees)
            {
                Caption = 'Manage Employees';
                Image = Users;
                ApplicationArea = All;
                RunObject = Page "Employee Ext List";
                ToolTip = 'Manage employee records.';
            }

            action(ManageSubscriptions)
            {
                Caption = 'Manage Subscriptions';
                Image = ServiceItem;
                ApplicationArea = All;
                RunObject = Page "Manage Subscriptions";
                ToolTip = 'Manage subscription records.';
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(AddEndUser_Promoted; AddEndUser) { }
                actionref(RemoveEndUser_Promoted; RemoveEndUser) { }
                actionref(SetAsPrimary_Promoted; SetAsPrimary) { }
                actionref(ActivateEndUser_Promoted; ActivateEndUser) { }
                actionref(DeactivateEndUser_Promoted; DeactivateEndUser) { }
            }
            group(Navigate)
            {
                Caption = 'Navigate';
                actionref(ViewEmployee_Promoted; ViewEmployee) { }
                actionref(ViewSubscription_Promoted; ViewSubscription) { }
            }
        }
    }

    var
        StatusStyle: Text;
        PrimaryStyle: Text;
        ActivateEnabled: Boolean;
        DeactivateEnabled: Boolean;
        FilteredSubscriptionNo: Code[20]; // NEW: Variable to store filtered subscription

    // NEW: Capture subscription filter when page opens
    trigger OnOpenPage()
    begin
        if Rec.GetFilter("Subscription No.") <> '' then
            FilteredSubscriptionNo := Rec.GetRangeMin("Subscription No.");
    end;

    // NEW: Auto-populate subscription number for new records
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if FilteredSubscriptionNo <> '' then
            Rec."Subscription No." := FilteredSubscriptionNo;
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateStyles();
        SetActionStates();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateStyles();
        SetActionStates();
    end;

    local procedure UpdateStyles()
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

    local procedure SetActionStates()
    begin
        ActivateEnabled := (Rec."Entry No." <> 0) and (Rec.Status <> Rec.Status::Active);
        DeactivateEnabled := (Rec."Entry No." <> 0) and (Rec.Status = Rec.Status::Active);
    end;
}
