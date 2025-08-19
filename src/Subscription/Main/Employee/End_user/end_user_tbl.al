table 50117 "End User"
{
    Caption = 'End User';
    DataClassification = CustomerContent;
    LookupPageId = "End User List";
    DrillDownPageId = "End User List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }

        field(2; "Subscription No."; Code[20])
        {
            Caption = 'Subscription No.';
            NotBlank = true;
            TableRelation = Subscription."No.";
            DataClassification = CustomerContent;
        }

        field(3; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            NotBlank = true;
            TableRelation = "Employee Ext"."No." where(Status = const(Active), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateEmployeeInfo();
            end;
        }

        field(4; "Employee Name"; Text[100])
        {
            Caption = 'Employee Name';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(5; "Employee Email"; Text[80])
        {
            Caption = 'Employee Email';
            ExtendedDatatype = EMail;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(6; "Department Code"; Code[20])
        {
            Caption = 'Department Code';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(7; "Department Description"; Text[100])
        {
            Caption = 'Department Description';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(8; "Subscription Name"; Text[100])
        {
            Caption = 'Subscription Name';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(9; "Date Added"; Date)
        {
            Caption = 'Date Added';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(10; "Added By"; Code[50])
        {
            Caption = 'Added By';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(11; "Status"; Enum "End User Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }

        field(12; "Primary End User"; Boolean)
        {
            Caption = 'Primary End User';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EndUser: Record "End User";
            begin
                if "Primary End User" then begin
                    // Clear other primary users for this subscription
                    EndUser.SetRange("Subscription No.", "Subscription No.");
                    EndUser.SetFilter("Entry No.", '<>%1', "Entry No.");
                    EndUser.ModifyAll("Primary End User", false, true);
                end;
            end;
        }

        field(13; "Position Title"; Text[50])
        {
            Caption = 'Position Title';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key("Subscription + Employee"; "Subscription No.", "Employee No.") { }
        key("Employee No."; "Employee No.") { }
        key("Primary User"; "Subscription No.", "Primary End User") { }
        key("Status"; Status, "Employee No.") { }
    }

    trigger OnInsert()
    begin
        "Date Added" := Today;
        "Added By" := UserId;
        if Status = Status::" " then
            Status := Status::Active;
        UpdateEmployeeInfo();
        UpdateSubscriptionInfo();
    end;

    trigger OnModify()
    begin
        UpdateEmployeeInfo();
        UpdateSubscriptionInfo();
    end;

    trigger OnDelete()
    var
        EndUser: Record "End User";
        RemainingCount: Integer;
    begin
        if "Primary End User" then begin
            EndUser.SetRange("Subscription No.", "Subscription No.");
            EndUser.SetFilter("Entry No.", '<>%1', "Entry No.");
            RemainingCount := EndUser.Count();

            if RemainingCount > 0 then begin
                if Confirm('This is the primary end user. Delete anyway? You will need to assign a new primary end user.', false) then begin
                    // Auto-assign new primary if possible
                    if EndUser.FindFirst() then begin
                        EndUser."Primary End User" := true;
                        EndUser.Modify(true);
                        Message('Employee %1 is now the primary end user.', EndUser."Employee Name");
                    end;
                end else
                    Error('');
            end;
        end;
    end;

    local procedure UpdateEmployeeInfo()
    var
        EmployeeExt: Record "Employee Ext";
        DeptMaster: Record "Department Master";
    begin
        if "Employee No." = '' then begin
            Clear("Employee Name");
            Clear("Employee Email");
            Clear("Department Code");
            Clear("Department Description");
            Clear("Position Title");
            exit;
        end;

        if EmployeeExt.Get("Employee No.") then begin
            "Employee Name" := EmployeeExt."Full Name";
            "Employee Email" := EmployeeExt.Email;
            "Department Code" := EmployeeExt."Department Code";
            "Position Title" := EmployeeExt."Position Title";

            if DeptMaster.Get(EmployeeExt."Department Code") then
                "Department Description" := DeptMaster.Description;
        end;
    end;

    local procedure UpdateSubscriptionInfo()
    var
        Subscription: Record Subscription;
    begin
        if "Subscription No." = '' then begin
            Clear("Subscription Name");
            exit;
        end;

        if Subscription.Get("Subscription No.") then
            "Subscription Name" := Subscription."Service Name";
    end;

    procedure SetAsPrimary()
    var
        EndUser: Record "End User";
    begin
        EndUser.SetRange("Subscription No.", "Subscription No.");
        EndUser.SetRange("Primary End User", true);
        EndUser.SetFilter("Entry No.", '<>%1', "Entry No.");
        EndUser.ModifyAll("Primary End User", false, true);

        "Primary End User" := true;
        Modify(true);

        Message('Employee %1 is now the primary end user.', "Employee Name");
    end;

    procedure GetPrimaryEndUser(SubscriptionNo: Code[20]): Code[20]
    var
        EndUser: Record "End User";
    begin
        EndUser.SetRange("Subscription No.", SubscriptionNo);
        EndUser.SetRange("Primary End User", true);
        if EndUser.FindFirst() then
            exit(EndUser."Employee No.");
        exit('');
    end;

    procedure CountEndUsers(SubscriptionNo: Code[20]): Integer
    var
        EndUser: Record "End User";
    begin
        EndUser.SetRange("Subscription No.", SubscriptionNo);
        exit(EndUser.Count());
    end;
}
