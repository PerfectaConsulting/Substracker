page 50124 "Departments"
{
    PageType = List;
    SourceTable = "Department Master";
    Caption = 'Departments';
    ApplicationArea = All;
    CardPageId = "Department Master Card"; // This enables automatic New button
    UsageCategory = Lists;

    // General behaviour
    Editable = true;
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(DepartmentLines)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department code.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department description.';
                }

                field("Head of Department"; Rec."Head of Department")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the employee assigned as head of this department.';
                }

                field("Head of Department Name"; Rec."Head of Department Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the name of the head of department.';
                    Editable = false;
                }

                field("No. of Employees"; Rec."No. of Employees")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of active employees in this department.';
                    Editable = false;
                    BlankZero = true;
                }

                field(Blocked; Rec.Blocked)
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
            // REMOVED: NewDepartment action - standard New button works automatically

            action(ShowEmployees)
            {
                ApplicationArea = All;
                Caption = 'Show Employees';
                ToolTip = 'View employees in the selected department.';
                Image = Users;

                trigger OnAction()
                var
                    Employee: Record "Employee Ext";
                    EmployeeList: Page "Employee Ext List";
                begin
                    Employee.SetRange("Department Code", Rec.Code);
                    EmployeeList.SetTableView(Employee);
                    EmployeeList.Run();
                end;
            }

            action(ShowSubscriptions)
            {
                ApplicationArea = All;
                Caption = 'Show Subscriptions';
                ToolTip = 'View subscriptions assigned to the selected department.';
                Image = ServiceItem;

                trigger OnAction()
                var
                    Department: Record "Department";
                    DepartmentList: Page "Department Selection";
                begin
                    Department.SetRange("Department Code", Rec.Code);
                    DepartmentList.SetTableView(Department);
                    DepartmentList.Run();
                end;
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(ShowEmployees_Promoted; ShowEmployees) { }
                actionref(ShowSubscriptions_Promoted; ShowSubscriptions) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("No. of Employees");
    end;
}
