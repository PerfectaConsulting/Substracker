page 50116 "Department Master Card"
{
    Caption = 'Department Card';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Department Master";
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General Information';

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department code.';
                    ShowMandatory = true;
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department name/description.';
                    ShowMandatory = true;
                }

                // FIXED: Show Head of Department Name instead of Number
                field("Head of Department Name"; Rec."Head of Department Name")
                {
                    ApplicationArea = All;
                    Caption = 'Head of Department';
                    ToolTip = 'Select the employee who will be the head of this department. Click to open employee selection.';
                    Editable = false;
                    ShowMandatory = false;

                    trigger OnAssistEdit()
                    var
                        Employee: Record "Employee Ext";
                        EmployeeList: Page "Employee Ext List";
                    begin
                        // Filter employees to only show those in current department
                        Employee.SetRange("Department Code", Rec."Code");
                        Employee.SetRange(Status, Employee.Status::Active);
                        Employee.SetRange(Blocked, false);

                        if Employee.IsEmpty() then begin
                            Message('No active employees found in department %1.', Rec."Code");
                            exit;
                        end;

                        EmployeeList.SetTableView(Employee);
                        EmployeeList.LookupMode(true);
                        EmployeeList.Caption := StrSubstNo('Select Head of Department %1', Rec."Code");

                        if EmployeeList.RunModal() = Action::LookupOK then begin
                            EmployeeList.GetRecord(Employee);

                            // Set both the employee number and name
                            Rec."Head of Department" := Employee."No.";
                            Rec.Validate("Head of Department", Employee."No.");

                            // Save and refresh the page
                            Rec.Modify(true);
                            CurrPage.Update(false);

                            Message('Head of Department set to %1.', Employee."Full Name");
                        end;
                    end;

                    trigger OnDrillDown()
                    var
                        Employee: Record "Employee Ext";
                        EmployeeList: Page "Employee Ext List";
                    begin
                        // Same logic as OnAssistEdit
                        Employee.SetRange("Department Code", Rec."Code");
                        Employee.SetRange(Status, Employee.Status::Active);
                        Employee.SetRange(Blocked, false);

                        if Employee.IsEmpty() then begin
                            Message('No active employees found in department %1.', Rec."Code");
                            exit;
                        end;

                        EmployeeList.SetTableView(Employee);
                        EmployeeList.LookupMode(true);
                        EmployeeList.Caption := StrSubstNo('Select Head of Department %1', Rec."Code");

                        if EmployeeList.RunModal() = Action::LookupOK then begin
                            EmployeeList.GetRecord(Employee);

                            Rec."Head of Department" := Employee."No.";
                            Rec.Validate("Head of Department", Employee."No.");

                            Rec.Modify(true);
                            CurrPage.Update(false);

                            Message('Head of Department set to %1.', Employee."Full Name");
                        end;
                    end;
                }

                // OPTIONAL: Keep employee number field hidden or as additional info
                field("Head of Department"; Rec."Head of Department")
                {
                    ApplicationArea = All;
                    Caption = 'Head of Department No.';
                    ToolTip = 'Shows the employee number of the head of department.';
                    Editable = false;
                    Visible = false; // Hide this field since we show the name instead
                }

                field("No. of Employees"; Rec."No. of Employees")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of active employees assigned to this department.';
                    Editable = false;
                    BlankZero = true;
                    Style = Favorable;

                    trigger OnDrillDown()
                    var
                        Employee: Record "Employee Ext";
                        EmployeeList: Page "Employee Ext List";
                    begin
                        Employee.SetRange("Department Code", Rec."Code");
                        Employee.SetRange(Status, Employee.Status::Active);
                        EmployeeList.SetTableView(Employee);
                        EmployeeList.Caption := StrSubstNo('Employees in Department %1', Rec."Code");
                        EmployeeList.Run();
                    end;
                }

                field("Blocked"; Rec."Blocked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the department is blocked from use.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Department Actions")
            {
                Caption = 'Department Actions';

                action(ShowAllEmployees)
                {
                    ApplicationArea = All;
                    Caption = 'Show All Employees';
                    ToolTip = 'View all employees in this department (active and inactive).';
                    Image = Users;

                    trigger OnAction()
                    var
                        Employee: Record "Employee Ext";
                        EmployeeList: Page "Employee Ext List";
                    begin
                        Employee.SetRange("Department Code", Rec."Code");
                        EmployeeList.SetTableView(Employee);
                        EmployeeList.Caption := StrSubstNo('All Employees in Department %1', Rec."Code");
                        EmployeeList.Run();
                    end;
                }

                action(ShowActiveEmployees)
                {
                    ApplicationArea = All;
                    Caption = 'Show Active Employees';
                    ToolTip = 'View only active employees in this department.';
                    Image = UserSetup;

                    trigger OnAction()
                    var
                        Employee: Record "Employee Ext";
                        EmployeeList: Page "Employee Ext List";
                    begin
                        Employee.SetRange("Department Code", Rec."Code");
                        Employee.SetRange(Status, Employee.Status::Active);
                        EmployeeList.SetTableView(Employee);
                        EmployeeList.Caption := StrSubstNo('Active Employees in Department %1', Rec."Code");
                        EmployeeList.Run();
                    end;
                }

                action(ShowDepartmentSubscriptions)
                {
                    ApplicationArea = All;
                    Caption = 'Show Subscriptions';
                    ToolTip = 'View subscriptions assigned to this department.';
                    Image = ServiceItem;

                    trigger OnAction()
                    var
                        Department: Record "Department";
                        DepartmentList: Page "Department Selection";
                    begin
                        Department.SetRange("Department Code", Rec."Code");
                        DepartmentList.SetTableView(Department);
                        DepartmentList.Caption := StrSubstNo('Subscriptions for Department %1', Rec."Code");
                        DepartmentList.Run();
                    end;
                }
            }

            group("Head Management")
            {
                Caption = 'Head of Department Management';

                action(SelectHeadOfDepartment)
                {
                    ApplicationArea = All;
                    Caption = 'Select Head of Department';
                    ToolTip = 'Select an employee from this department to be the head of department.';
                    Image = SelectField;

                    trigger OnAction()
                    var
                        Employee: Record "Employee Ext";
                        EmployeeList: Page "Employee Ext List";
                    begin
                        Employee.SetRange("Department Code", Rec."Code");
                        Employee.SetRange(Status, Employee.Status::Active);
                        Employee.SetRange(Blocked, false);

                        if Employee.IsEmpty() then begin
                            Message('No active employees found in department %1.', Rec."Code");
                            exit;
                        end;

                        EmployeeList.SetTableView(Employee);
                        EmployeeList.LookupMode(true);
                        EmployeeList.Caption := StrSubstNo('Select Head of Department %1', Rec."Code");

                        if EmployeeList.RunModal() = Action::LookupOK then begin
                            EmployeeList.GetRecord(Employee);
                            Rec.Validate("Head of Department", Employee."No.");
                            Rec.Modify(true);
                            CurrPage.Update(false);
                            Message('Head of Department set to %1 (%2).', Employee."No.", Employee."Full Name");
                        end;
                    end;
                }

                action(ClearHeadOfDepartment)
                {
                    ApplicationArea = All;
                    Caption = 'Clear Head of Department';
                    ToolTip = 'Remove the current head of department assignment.';
                    Image = ClearLog;
                    Enabled = HeadOfDepartmentExists;

                    trigger OnAction()
                    begin
                        if Confirm('Clear head of department for %1 (%2)?', false, Rec."Code", Rec."Description") then begin
                            Rec."Head of Department" := '';
                            Rec.Modify(true);
                            CurrPage.Update(false);
                            Message('Head of Department cleared for department %1.', Rec."Code");
                        end;
                    end;
                }

                action(ViewHeadOfDepartmentCard)
                {
                    ApplicationArea = All;
                    Caption = 'View Head of Department';
                    ToolTip = 'Open the employee card for the head of department.';
                    Image = Employee;
                    Enabled = HeadOfDepartmentExists;

                    trigger OnAction()
                    var
                        Employee: Record "Employee Ext";
                        EmployeeCard: Page "Employee Ext Card";
                    begin
                        if Employee.Get(Rec."Head of Department") then begin
                            EmployeeCard.SetRecord(Employee);
                            EmployeeCard.Run();
                        end else begin
                            Message('Head of Department employee %1 not found.', Rec."Head of Department");
                        end;
                    end;
                }
            }
        }

        area(navigation)
        {
            action(DepartmentList)
            {
                ApplicationArea = All;
                Caption = 'Department List';
                ToolTip = 'Open the department master list.';
                Image = Departments;
                RunObject = Page "Departments";
            }

            action(EmployeeList)
            {
                ApplicationArea = All;
                Caption = 'Employee List';
                ToolTip = 'Open the employee list.';
                Image = Users;
                RunObject = Page "Employee Ext List";
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(ShowActiveEmployees_Promoted; ShowActiveEmployees) { }
                actionref(ShowAllEmployees_Promoted; ShowAllEmployees) { }
                actionref(ShowDepartmentSubscriptions_Promoted; ShowDepartmentSubscriptions) { }
            }
            group(HeadMgmt)
            {
                Caption = 'Head of Department';
                actionref(SelectHeadOfDepartment_Promoted; SelectHeadOfDepartment) { }
                actionref(ViewHeadOfDepartmentCard_Promoted; ViewHeadOfDepartmentCard) { }
                actionref(ClearHeadOfDepartment_Promoted; ClearHeadOfDepartment) { }
            }
        }
    }

    var
        HeadOfDepartmentExists: Boolean;

    trigger OnAfterGetRecord()
    begin
        // Refresh FlowFields
        Rec.CalcFields("No. of Employees");

        // Set action states
        HeadOfDepartmentExists := Rec."Head of Department" <> '';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        // Refresh FlowFields
        Rec.CalcFields("No. of Employees");

        // Set action states
        HeadOfDepartmentExists := Rec."Head of Department" <> '';
    end;
}
