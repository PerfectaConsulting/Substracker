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
                    // Filtered, department-aware lookup
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Emp: Record "Employee Ext";
                        EmpList: Page "Employee Ext List";
                    begin
                        // only show active, unblocked employees
                        Emp.SetRange(Status, Emp.Status::Active);
                        Emp.SetRange(Blocked, false);
                        // restrict by departments passed from Add Subscription (e.g., 'FINANCE|SALES')
                        if FilteredDepartmentFilter <> '' then
                            Emp.SetFilter("Department Code", FilteredDepartmentFilter);
                        EmpList.SetTableView(Emp);
                        EmpList.LookupMode(true);
                        if EmpList.RunModal() = Action::LookupOK then begin
                            EmpList.GetRecord(Emp);
                            // use table validation to populate dependent fields
                            Rec.Validate("Employee No.", Emp."No.");
                            exit(true);
                        end;
                        exit(false);
                    end;
                    // Enhanced validation with duplicate prevention
                    trigger OnValidate()
                    var
                        Emp: Record "Employee Ext";
                    begin
                        if Rec."Employee No." = '' then
                            exit;
                        // Guard against manual typing outside allowed departments
                        if (FilteredDepartmentFilter <> '') then
                            if Emp.Get(Rec."Employee No.") then
                                if not DeptInFilter(Emp."Department Code", FilteredDepartmentFilter) then
                                    Error(
                                      'Employee %1 (%2) belongs to department %3, which is not in the selected departments (%4).',
                                      Emp."No.", Emp."Full Name", Emp."Department Code", FilteredDepartmentFilter);
                        // NEW: Validate unique Employee-Subscription combination
                        ValidateUniqueEmployeeSubscription(Rec."Employee No.", Rec."Subscription No.", Rec."Entry No.");
                    end;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Name';
                    ToolTip = 'Shows the full name of the employee.';
                    Editable = false;
                }
                // NEW: Live employee department from Employee Ext
                field("Employee Department"; EmployeeDeptDisplay)
                {
                    ApplicationArea = All;
                    Caption = 'Employee Department';
                    ToolTip = 'Department of the employee (from Employee).';
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
                    ToolTip = 'Shows the department of the employee (if stored on the line).';
                    Editable = false;
                }
                field("Department Description"; Rec."Department Description")
                {
                    ApplicationArea = All;
                    Caption = 'Department Description';
                    ToolTip = 'Shows the description of the department (if stored on the line).';
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
                    Editable = false;
                }
                field("Subscription Name"; Rec."Subscription Name")
                {
                    ApplicationArea = All;
                    Caption = 'Subscription Name';
                    ToolTip = 'Shows the name of the subscription service.';
                    Editable = false;
                }
                field(Status; Rec.Status)
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
                    SingleDepartmentCode: Code[20];
                begin
                    NewRec.Init();
                    if FilteredSubscriptionNo <> '' then
                        NewRec."Subscription No." := FilteredSubscriptionNo;
                    if FilteredDepartmentFilter <> '' then begin
                        SingleDepartmentCode := GetSingleDepartmentFromFilter(FilteredDepartmentFilter);
                        if SingleDepartmentCode <> '' then
                            NewRec."Department Code" := SingleDepartmentCode;
                    end;
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
            action(ShowFilterInfo)
            {
                Caption = 'Show Filter Information';
                Image = FilterLines;
                ApplicationArea = All;
                ToolTip = 'Display current subscription and department filters.';
                trigger OnAction()
                var
                    FilterInfo: Text;
                begin
                    FilterInfo := 'Current Filters Applied:';
                    if FilteredSubscriptionNo <> '' then
                        FilterInfo += StrSubstNo('\• Subscription: %1', FilteredSubscriptionNo);
                    if FilteredDepartmentFilter <> '' then
                        FilterInfo += StrSubstNo('\• Departments: %1', FilteredDepartmentFilter);
                    if (FilteredSubscriptionNo = '') and (FilteredDepartmentFilter = '') then
                        FilterInfo += '\No filters applied - showing all records.';
                    Message(FilterInfo);
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
            action(ViewSubscriptionDepartments)
            {
                Caption = 'View Subscription Departments';
                Image = Departments;
                ApplicationArea = All;
                ToolTip = 'View all departments assigned to the filtered subscription.';
                Enabled = CanViewSubDepartments;
                trigger OnAction()
                var
                    DeptLink: Record "Department";           // link: Subscription No. ↔ Department Code
                    DeptMaster: Record "Department Master";  // source of "Department Multi-Selection"
                    DepartmentList: Page "Department Multi-Selection";
                    CodeFilter: Text;
                    First: Boolean;
                begin
                    if FilteredSubscriptionNo = '' then begin
                        Message('No subscription filter applied.');
                        exit;
                    end;
                    DeptLink.SetRange("Subscription No.", FilteredSubscriptionNo);
                    if DeptLink.IsEmpty() then begin
                        Message('No departments assigned to subscription %1.', FilteredSubscriptionNo);
                        exit;
                    end;
                    First := true;
                    if DeptLink.FindSet() then
                        repeat
                            if not First then
                                CodeFilter += '|';
                            CodeFilter += DeptLink."Department Code";
                            First := false;
                        until DeptLink.Next() = 0;
                    DeptMaster.SetFilter(Code, CodeFilter);
                    DepartmentList.SetTableView(DeptMaster);
                    DepartmentList.Caption := StrSubstNo('Departments for Subscription %1', FilteredSubscriptionNo);
                    DepartmentList.Run();
                end;
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
            group(Information)
            {
                Caption = 'Information';
                actionref(ShowFilterInfo_Promoted; ShowFilterInfo) { }
                actionref(ViewSubscriptionDepartments_Promoted; ViewSubscriptionDepartments) { }
            }
        }
    }
    var
        StatusStyle: Text;
        PrimaryStyle: Text;
        ActivateEnabled: Boolean;
        DeactivateEnabled: Boolean;
        // Filters captured from caller
        FilteredSubscriptionNo: Code[20];
        FilteredDepartmentFilter: Text;
        // For action enabling
        CanViewSubDepartments: Boolean;
        // NEW: display column value
        EmployeeDeptDisplay: Text[100];

    trigger OnOpenPage()
    begin
        // Capture filters applied by caller (Add Subscription page)
        FilteredSubscriptionNo := CopyStr(Rec.GetFilter("Subscription No."), 1, MaxStrLen(FilteredSubscriptionNo));
        FilteredDepartmentFilter := Rec.GetFilter("Department Code");
        // Join-like narrowing by Employee Dept (works even if End User lines don't store Dept)
        ApplyDepartmentEmployeeFilter();
        // Warn only if no employees exist for the selected departments
        ValidateEmployeeAvailability();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        SingleDepartmentCode: Code[20];
    begin
        if FilteredSubscriptionNo <> '' then
            Rec."Subscription No." := FilteredSubscriptionNo;
        if FilteredDepartmentFilter <> '' then begin
            SingleDepartmentCode := GetSingleDepartmentFromFilter(FilteredDepartmentFilter);
            if SingleDepartmentCode <> '' then
                Rec."Department Code" := SingleDepartmentCode;
        end;
        Rec."Primary End User" := false;
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateStyles();
        SetActionStates();
        UpdateEmployeeDeptDisplay();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateStyles();
        SetActionStates();
        UpdateEmployeeDeptDisplay();
    end;
    // NEW: Validation procedure to prevent duplicate Employee-Subscription combinations
    local procedure ValidateUniqueEmployeeSubscription(EmployeeNo: Code[20]; SubscriptionNo: Code[20]; CurrentEntryNo: Integer)
    var
        ExistingEndUser: Record "End User";
        EmployeeName: Text[100];
        SubscriptionName: Text[100];
        Emp: Record "Employee Ext";
        Sub: Record Subscription;
    begin
        if (EmployeeNo = '') or (SubscriptionNo = '') then
            exit;
        // Check for existing combination
        ExistingEndUser.SetRange("Employee No.", EmployeeNo);
        ExistingEndUser.SetRange("Subscription No.", SubscriptionNo);
        ExistingEndUser.SetFilter("Entry No.", '<>%1', CurrentEntryNo); // Exclude current record for edits
        if not ExistingEndUser.IsEmpty() then begin
            // Get friendly names for error message
            if Emp.Get(EmployeeNo) then
                EmployeeName := Emp."Full Name"
            else
                EmployeeName := EmployeeNo;
            // FIXED: Using subscription number instead of non-existent field
            if Sub.Get(SubscriptionNo) then
                SubscriptionName := SubscriptionNo  // Temporary fix - replace with correct field name
            else
                SubscriptionName := SubscriptionNo;
            Error('Employee %1 (%2) is already assigned to subscription %3 (%4). Duplicate assignments are not allowed.',
                  EmployeeNo, EmployeeName, SubscriptionNo, SubscriptionName);
        end;
    end;

    local procedure DeptInFilter(DeptCode: Code[20]; FilterTxt: Text): Boolean
    var
        token: Text;
        rest: Text;
        pos: Integer;
    begin
        if (FilterTxt = '') or (DeptCode = '') then
            exit(true);
        // FilterTxt is like 'FINANCE|SALES|IT' (we build this upstream)
        rest := FilterTxt + '|';
        while true do begin
            pos := StrPos(rest, '|');
            if pos = 0 then
                break;
            token := CopyStr(rest, 1, pos - 1);
            if DeptCode = token then
                exit(true);
            // move to next token
            rest := CopyStr(rest, pos + 1, MaxStrLen(rest));
        end;
        exit(false);
    end;

    local procedure ApplyDepartmentEmployeeFilter()
    var
        Emp: Record "Employee Ext";
        empFilter: Text;
        first: Boolean;
    begin
        if FilteredDepartmentFilter = '' then
            exit;
        Emp.SetRange(Status, Emp.Status::Active);
        Emp.SetRange(Blocked, false);
        Emp.SetFilter("Department Code", FilteredDepartmentFilter);
        if Emp.IsEmpty() then
            exit;
        first := true;
        if Emp.FindSet() then
            repeat
                if not first then
                    empFilter += '|';
                empFilter += Emp."No.";
                first := false;
            until Emp.Next() = 0;
        if empFilter <> '' then
            Rec.SetFilter("Employee No.", empFilter);
    end;

    local procedure ValidateEmployeeAvailability()
    var
        EmployeeExt: Record "Employee Ext";
    begin
        if FilteredDepartmentFilter = '' then
            exit;
        EmployeeExt.SetRange(Status, EmployeeExt.Status::Active);
        EmployeeExt.SetRange(Blocked, false);
        EmployeeExt.SetFilter("Department Code", FilteredDepartmentFilter);
        if EmployeeExt.IsEmpty() then
            Message('No employees available for the selected department(s): %1', FilteredDepartmentFilter);
    end;

    local procedure GetSingleDepartmentFromFilter(DepartmentFilter: Text): Code[20]
    var
        DepartmentMaster: Record "Department Master";
        DepartmentCount: Integer;
        SingleDepartment: Code[20];
    begin
        if DepartmentFilter = '' then
            exit('');
        DepartmentMaster.SetFilter(Code, DepartmentFilter);
        DepartmentCount := DepartmentMaster.Count();
        if DepartmentCount = 1 then
            if DepartmentMaster.FindFirst() then
                SingleDepartment := DepartmentMaster.Code;
        exit(SingleDepartment);
    end;

    local procedure UpdateEmployeeDeptDisplay()
    var
        Emp: Record "Employee Ext";
        DeptMaster: Record "Department Master";
        deptCode: Code[20];
    begin
        EmployeeDeptDisplay := '';
        if Rec."Employee No." = '' then
            exit;
        if Emp.Get(Rec."Employee No.") then begin
            deptCode := Emp."Department Code";
            if (deptCode <> '') and DeptMaster.Get(deptCode) then
                EmployeeDeptDisplay := StrSubstNo('%1 - %2', deptCode, DeptMaster.Description)
            else
                EmployeeDeptDisplay := deptCode;
        end;
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
        CanViewSubDepartments := (FilteredSubscriptionNo <> '');
    end;
}
