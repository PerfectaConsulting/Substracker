table 50120 "Employee Ext"
{
    Caption = 'Employee Ext';
    DataClassification = CustomerContent;
    LookupPageId = "Employee Ext List";
    DrillDownPageId = "Employee Ext List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Employee No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "No." := UpperCase(DelChr("No.", '<>', ' '));  // Remove spaces, uppercase
                if StrLen("No.") < 2 then
                    Error('Employee number must be at least 2 characters.');
            end;
        }

        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }

        field(10; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateFullName();
            end;
        }

        field(11; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateFullName();
            end;
        }

        field(12; "Full Name"; Text[100])
        {
            Caption = 'Full Name';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(20; "Email"; Text[80])
        {
            Caption = 'Email Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                ValidateEmail();
            end;
        }

        field(21; "Phone No."; Text[30])
        {
            Caption = 'Phone Number';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }

        field(30; "Department Code"; Code[20])
        {
            Caption = 'Department Code';
            TableRelation = "Department Master".Code where(Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DeptMaster: Record "Department Master";
            begin
                if "Department Code" = '' then begin
                    "Department Description" := '';
                    exit;
                end;

                if not DeptMaster.Get("Department Code") then
                    Error('Department %1 does not exist.', "Department Code");

                if DeptMaster.Blocked then
                    Error('Department %1 is blocked and cannot be used.', "Department Code");

                "Department Description" := DeptMaster.Description;
            end;
        }

        field(31; "Department Description"; Text[100])
        {
            Caption = 'Department Description';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(40; "Position Title"; Text[50])
        {
            Caption = 'Position Title';
            DataClassification = CustomerContent;
        }

        field(41; "Employment Date"; Date)
        {
            Caption = 'Employment Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Employment Date" <> 0D) and ("Employment Date" > Today) then
                    Error('Employment date cannot be in the future.');

                if ("Termination Date" <> 0D) and ("Employment Date" > "Termination Date") then
                    Error('Employment date cannot be after termination date.');
            end;
        }

        field(42; "Termination Date"; Date)
        {
            Caption = 'Termination Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Termination Date" <> 0D) and ("Employment Date" <> 0D) then
                    if "Termination Date" < "Employment Date" then
                        Error('Termination date cannot be before employment date.');

                if "Termination Date" <> 0D then
                    Status := Status::Inactive
                else
                    Status := Status::Active;
            end;
        }

        field(50; "Status"; Enum "Employee Ext Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }

        field(51; "Manager Employee No."; Code[20])
        {
            Caption = 'Manager';
            TableRelation = "Employee Ext"."No." where(Status = const(Active));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ManagerEmployee: Record "Employee Ext";
            begin
                if "Manager Employee No." = '' then begin
                    "Manager Name" := '';
                    exit;
                end;

                if "Manager Employee No." = "No." then
                    Error('Employee cannot be manager of themselves.');

                if ManagerEmployee.Get("Manager Employee No.") then
                    "Manager Name" := ManagerEmployee."Full Name"
                else
                    Error('Manager employee %1 does not exist.', "Manager Employee No.");
            end;
        }

        field(52; "Manager Name"; Text[100])
        {
            Caption = 'Manager Name';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(60; "Salary"; Decimal)
        {
            Caption = 'Salary';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MinValue = 0;
        }

        field(70; "Address"; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }

        field(71; "City"; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }

        field(72; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }

        field(73; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }

        field(80; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(81; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(82; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(83; "Last Modified By"; Code[50])
        {
            Caption = 'Last Modified By';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(90; "Blocked"; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Blocked then begin
                    if not Confirm('Block employee %1 (%2)?', false, "No.", "Full Name") then
                        Error('');
                end;
            end;
        }

        // FlowFields
        field(100; "Subscription Count"; Integer)
        {
            Caption = 'Assigned Subscriptions';
            FieldClass = FlowField;
            CalcFormula = count(Subscription where("End-user" = field("No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Name; "Last Name", "First Name") { }
        key(Department; "Department Code", "No.") { }
        key(Status; Status, "No.") { }
        key(Email; Email) { }
    }

    var
        EmployeeExtSetup: Record "Employee Ext Setup";
        NoSeries: Codeunit "No. Series";

    trigger OnInsert()
    begin
        if "No." = '' then begin
            // FIXED: Improved number series handling
            Clear(EmployeeExtSetup);
            EmployeeExtSetup.GetRecordOnce();
            if EmployeeExtSetup."Employee Ext Nos." <> '' then begin
                "No." := NoSeries.GetNextNo(EmployeeExtSetup."Employee Ext Nos.");
                "No. Series" := EmployeeExtSetup."Employee Ext Nos.";
            end else begin
                Error('Employee Ext number series is not set up. Please configure it in Employee Ext Setup.');
            end;
        end;

        "Created Date" := CurrentDateTime;
        "Created By" := UserId;
        "Last Modified Date" := CurrentDateTime;
        "Last Modified By" := UserId;

        if Status = Status::" " then
            Status := Status::Active;

        UpdateFullName();
    end;

    trigger OnModify()
    begin
        "Last Modified Date" := CurrentDateTime;
        "Last Modified By" := UserId;

        if xRec."No." <> "No." then
            Error('Employee number cannot be changed after creation.');
    end;

    trigger OnDelete()
    var
        Subscription: Record Subscription;
    begin
        // Check if employee is assigned to any subscriptions
        Subscription.SetRange("End-user", "No.");
        if not Subscription.IsEmpty() then
            Error('Cannot delete employee %1 because they are assigned to %2 subscription(s).',
                  "No.", Subscription.Count());

        // Check if employee is a manager for other employees
        if IsManager() then
            Error('Cannot delete employee %1 because they are a manager for other employees.', "No.");
    end;

    // Procedures
    procedure AssistEdit(OldEmployeeExt: Record "Employee Ext"): Boolean
    var
        SelectedNoSeries: Code[20];
    begin
        Clear(EmployeeExtSetup);
        EmployeeExtSetup.GetRecordOnce();

        if EmployeeExtSetup."Employee Ext Nos." = '' then begin
            Error('Employee Ext number series is not set up. Please configure it in Employee Ext Setup.');
            exit(false);
        end;

        if NoSeries.LookupRelatedNoSeries(EmployeeExtSetup."Employee Ext Nos.", OldEmployeeExt."No. Series", SelectedNoSeries) then begin
            "No. Series" := SelectedNoSeries;
            "No." := NoSeries.GetNextNo(SelectedNoSeries);
            exit(true);
        end;

        exit(false);
    end;

    local procedure UpdateFullName()
    begin
        "Full Name" := DelChr("First Name" + ' ' + "Last Name", '<>', ' ');
        if "Manager Employee No." <> '' then
            UpdateManagerReferences();
    end;

    local procedure UpdateManagerReferences()
    var
        SubordinateEmployee: Record "Employee Ext";
    begin
        // Update manager name in employees who report to this employee
        SubordinateEmployee.SetRange("Manager Employee No.", "No.");
        if SubordinateEmployee.FindSet() then
            repeat
                SubordinateEmployee."Manager Name" := "Full Name";
                SubordinateEmployee.Modify();
            until SubordinateEmployee.Next() = 0;
    end;

    local procedure ValidateEmail()
    begin
        if Email = '' then
            exit;

        // Check for duplicate email
        CheckDuplicateEmail();
    end;

    local procedure CheckDuplicateEmail()
    var
        EmployeeExt: Record "Employee Ext";
    begin
        if Email = '' then
            exit;

        EmployeeExt.SetRange(Email, Email);
        EmployeeExt.SetFilter("No.", '<>%1', "No.");
        if not EmployeeExt.IsEmpty() then begin
            EmployeeExt.FindFirst();
            Error('Email address %1 is already used by employee %2 (%3).',
                  Email, EmployeeExt."No.", EmployeeExt."Full Name");
        end;
    end;

    procedure IsManager(): Boolean
    var
        EmployeeExt: Record "Employee Ext";
    begin
        EmployeeExt.SetRange("Manager Employee No.", "No.");
        exit(not EmployeeExt.IsEmpty());
    end;

    procedure GetSubordinatesCount(): Integer
    var
        EmployeeExt: Record "Employee Ext";
    begin
        EmployeeExt.SetRange("Manager Employee No.", "No.");
        exit(EmployeeExt.Count());
    end;

    procedure ToggleBlocked()
    begin
        Validate(Blocked, not Blocked);
        Modify(true);
    end;

    procedure GetStatusText(): Text
    begin
        case Status of
            Status::Active:
                exit('Active');
            Status::Inactive:
                exit('Inactive');
            Status::OnLeave:
                exit('On Leave');
            else
                exit('Unknown');
        end;
    end;
}
