table 50113 "Department Master"
{
    Caption = 'Department Master';
    DataClassification = CustomerContent;
    LookupPageId = "Departments";
    DrilldownPageId = "Departments";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Code := UpperCase(DelChr(Code, '<>', ' '));  // Remove spaces, uppercase
                if StrLen(Code) < 2 then
                    Error('Department code must be at least 2 characters.');
            end;
        }

        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Description = '' then
                    Error('Description cannot be empty.');
            end;
        }

        // NEW: Head of Department field with filtered lookup
        field(3; "Head of Department"; Code[20])
        {
            Caption = 'Head of Department';
            TableRelation = "Employee Ext"."No." where("Department Code" = field("Code"), Status = const(Active), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Employee: Record "Employee Ext";
            begin
                if "Head of Department" = '' then begin
                    "Head of Department Name" := '';
                    exit;
                end;

                if not Employee.Get("Head of Department") then
                    Error('Employee %1 does not exist.', "Head of Department");

                if Employee."Department Code" <> "Code" then
                    Error('Employee %1 does not belong to department %2. Employee is assigned to department %3.',
                          "Head of Department", "Code", Employee."Department Code");

                if Employee.Status <> Employee.Status::Active then
                    Error('Employee %1 is not active and cannot be head of department.', "Head of Department");

                if Employee.Blocked then
                    Error('Employee %1 is blocked and cannot be head of department.', "Head of Department");

                "Head of Department Name" := Employee."Full Name";
            end;
        }

        // NEW: Head of Department Name field (auto-populated)
        field(4; "Head of Department Name"; Text[100])
        {
            Caption = 'Head of Department Name';
            Editable = false;
            DataClassification = CustomerContent;
        }

        // NEW: No. of Employees FlowField
        field(5; "No. of Employees"; Integer)
        {
            Caption = 'No. of Employees';
            FieldClass = FlowField;
            CalcFormula = count("Employee Ext" where("Department Code" = field("Code"), Status = const(Active)));
            Editable = false;
        }

        field(10; "Blocked"; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SubscriptionDept: Record "Department";
            begin
                if Blocked then begin
                    SubscriptionDept.SetRange("Department Code", Code);
                    if not SubscriptionDept.IsEmpty() then
                        if not Confirm('Department %1 is used in subscriptions. Block anyway?', false, Code) then
                            Error('');
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
        key(HeadOfDepartment; "Head of Department") { } // NEW: Index for head of department
    }

    trigger OnInsert()
    begin
        if Code = '' then
            Error('Department code cannot be empty.');

        Code := UpperCase(Code);  // Standardize format
    end;

    trigger OnModify()
    begin
        if xRec.Code <> Code then
            Error('Department code cannot be changed after creation.');
    end;

    trigger OnDelete()
    var
        SubscriptionDept: Record "Department";
        Employee: Record "Employee Ext";
    begin
        // Check if blocked before allowing deletion
        if Blocked then
            if not Confirm('Department %1 is blocked. Do you want to delete it?', false, Code) then
                Error('');

        // Check for employees in department
        Employee.SetRange("Department Code", Code);
        if not Employee.IsEmpty() then
            Error('Cannot delete department %1 because it has %2 employee(s) assigned.',
                  Code, Employee.Count());

        // Check for subscription usage
        SubscriptionDept.SetRange("Department Code", Code);
        if not SubscriptionDept.IsEmpty() then
            Error('Cannot delete department %1 because it is used in %2 subscription(s).',
                  Code, SubscriptionDept.Count());
    end;

    // Existing utility procedures
    procedure IsInUse(): Boolean
    var
        SubscriptionDept: Record "Department";
    begin
        SubscriptionDept.SetRange("Department Code", Code);
        exit(not SubscriptionDept.IsEmpty());
    end;

    procedure GetUsageCount(): Integer
    var
        SubscriptionDept: Record "Department";
    begin
        SubscriptionDept.SetRange("Department Code", Code);
        exit(SubscriptionDept.Count());
    end;

    procedure ToggleBlocked()
    begin
        Validate(Blocked, not Blocked);
        Modify(true);
    end;

    // NEW: Get employee count procedure
    procedure GetEmployeeCount(): Integer
    var
        Employee: Record "Employee Ext";
    begin
        Employee.SetRange("Department Code", Code);
        Employee.SetRange(Status, Employee.Status::Active);
        exit(Employee.Count());
    end;

    // NEW: Check if department has active employees
    procedure HasActiveEmployees(): Boolean
    var
        Employee: Record "Employee Ext";
    begin
        Employee.SetRange("Department Code", Code);
        Employee.SetRange(Status, Employee.Status::Active);
        exit(not Employee.IsEmpty());
    end;
}
