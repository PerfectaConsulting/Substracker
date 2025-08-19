table 50112 "Department"
{
    Caption = 'Subscription Department';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Subscription No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = Subscription."No.";
            NotBlank = true;
            DataClassification = CustomerContent;
        }

        field(2; "Department Code"; Code[20])  // Fixed: Aligned with Department Master
        {
            Caption = 'Department Code';
            TableRelation = "Department Master".Code where(Blocked = const(false));
            NotBlank = true;
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

        field(3; "Department Description"; Text[100])
        {
            Caption = 'Department Description';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(4; "Primary Department"; Boolean)
        {
            Caption = 'Primary Department';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SubscriptionDept: Record "Department";
                OldPrimaryCode: Code[20];
            begin
                if "Primary Department" then begin
                    // Find current primary department
                    SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
                    SubscriptionDept.SetRange("Primary Department", true);
                    SubscriptionDept.SetFilter("Department Code", '<>%1', "Department Code");

                    if SubscriptionDept.FindFirst() then begin
                        OldPrimaryCode := SubscriptionDept."Department Code";

                        if not Confirm('Department %1 is currently the primary. Change to %2?',
                                      false, OldPrimaryCode, "Department Code") then begin
                            "Primary Department" := false;
                            exit;
                        end;

                        // Update all other primary departments
                        SubscriptionDept.ModifyAll("Primary Department", false, true);
                        Message('Primary department changed from %1 to %2.', OldPrimaryCode, "Department Code");
                    end;
                end;
            end;
        }

        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }

        // FlowFields for enhanced information
        field(10; "Department Usage Count"; Integer)
        {
            Caption = 'Usage Count';
            FieldClass = FlowField;
            CalcFormula = count("Department" where("Department Code" = field("Department Code")));
            Editable = false;
        }

        field(11; "Department Blocked"; Boolean)
        {
            Caption = 'Department Blocked';
            FieldClass = FlowField;
            CalcFormula = lookup("Department Master".Blocked where(Code = field("Department Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Subscription No.", "Department Code") { Clustered = true; }
        key(LineOrder; "Subscription No.", "Line No.") { }
        key(Primary; "Subscription No.", "Primary Department") { }
        key(DepartmentCode; "Department Code") { }
    }

    trigger OnInsert()
    var
        SubscriptionDept: Record "Department";
        Subscription: Record Subscription;
        LineNumberDept: Record "Department";  // Added: Separate record variable for line numbering
    begin
        // Validate subscription exists
        if not Subscription.Get("Subscription No.") then
            Error('Subscription %1 does not exist.', "Subscription No.");

        // Check for duplicates
        SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
        SubscriptionDept.SetRange("Department Code", "Department Code");
        if not SubscriptionDept.IsEmpty() then
            Error('Department %1 is already assigned to subscription %2.',
                  "Department Code", "Subscription No.");

        // Set as primary if this is the first department
        SubscriptionDept.Reset();
        SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
        if SubscriptionDept.IsEmpty() then begin
            "Primary Department" := true;
            Message('Department %1 set as primary (first department for this subscription).',
                    "Department Code");
        end;

        // Auto-assign line number if not set - FIXED: Use separate record variable
        if "Line No." = 0 then begin
            Clear(LineNumberDept);
            LineNumberDept.SetRange("Subscription No.", "Subscription No.");
            if LineNumberDept.FindLast() then
                "Line No." := LineNumberDept."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;

    trigger OnModify()
    var
        SubscriptionDept: Record "Department";
    begin
        // Validate that we don't remove the last primary department
        if xRec."Primary Department" and not "Primary Department" then begin
            SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
            SubscriptionDept.SetRange("Primary Department", true);
            SubscriptionDept.SetFilter("Department Code", '<>%1', "Department Code");
            if SubscriptionDept.IsEmpty() then
                Error('You cannot remove the primary department flag. At least one department must be primary.');
        end;
    end;

    trigger OnDelete()
    var
        SubscriptionDept: Record "Department";
        RemainingCount: Integer;
    begin
        if "Primary Department" then begin
            SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
            SubscriptionDept.SetFilter("Department Code", '<>%1', "Department Code");
            RemainingCount := SubscriptionDept.Count();

            if RemainingCount > 0 then begin
                if not Confirm('This is the primary department. Delete anyway? You will need to assign a new primary department.', false) then
                    Error('');

                // Optionally auto-assign new primary
                if SubscriptionDept.FindFirst() then begin
                    SubscriptionDept."Primary Department" := true;
                    SubscriptionDept.Modify(true);
                    Message('Department %1 is now the primary department.', SubscriptionDept."Department Code");
                end;
            end;
        end;
    end;

    // ─────────────────────────────────────────────────────────────
    //  Utility Procedures
    // ─────────────────────────────────────────────────────────────
    procedure SetAsPrimary()
    var
        SubscriptionDept: Record "Department";
    begin
        SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
        SubscriptionDept.SetRange("Primary Department", true);
        SubscriptionDept.SetFilter("Department Code", '<>%1', "Department Code");
        SubscriptionDept.ModifyAll("Primary Department", false, true);

        "Primary Department" := true;
        Modify(true);

        Message('Department %1 is now the primary department.', "Department Code");
    end;

    procedure GetPrimaryDepartment(SubscriptionNo: Code[20]): Code[20]
    var
        SubscriptionDept: Record "Department";
    begin
        SubscriptionDept.SetRange("Subscription No.", SubscriptionNo);
        SubscriptionDept.SetRange("Primary Department", true);
        if SubscriptionDept.FindFirst() then
            exit(SubscriptionDept."Department Code");
        exit('');
    end;

    procedure CountDepartments(SubscriptionNo: Code[20]): Integer
    var
        SubscriptionDept: Record "Department";
    begin
        SubscriptionDept.SetRange("Subscription No.", SubscriptionNo);
        exit(SubscriptionDept.Count());
    end;

    procedure HasPrimaryDepartment(SubscriptionNo: Code[20]): Boolean
    var
        SubscriptionDept: Record "Department";
    begin
        SubscriptionDept.SetRange("Subscription No.", SubscriptionNo);
        SubscriptionDept.SetRange("Primary Department", true);
        exit(not SubscriptionDept.IsEmpty());
    end;

    procedure GetDepartmentsBySubscription(SubscriptionNo: Code[20]; var DepartmentList: Text)
    var
        SubscriptionDept: Record "Department";
    begin
        DepartmentList := '';
        SubscriptionDept.SetRange("Subscription No.", SubscriptionNo);
        if SubscriptionDept.FindSet() then begin
            repeat
                if DepartmentList <> '' then
                    DepartmentList += ', ';
                DepartmentList += SubscriptionDept."Department Code";
                if SubscriptionDept."Primary Department" then
                    DepartmentList += ' (Primary)';
            until SubscriptionDept.Next() = 0;
        end;
    end;

    procedure ValidateDepartmentExists()
    var
        DeptMaster: Record "Department Master";
    begin
        if "Department Code" <> '' then begin
            if not DeptMaster.Get("Department Code") then
                Error('Department %1 does not exist in the master table.', "Department Code");

            if DeptMaster.Blocked then
                Error('Department %1 is blocked and cannot be used.', "Department Code");
        end;
    end;

    procedure EnsurePrimaryExists()
    var
        SubscriptionDept: Record "Department";
    begin
        SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
        SubscriptionDept.SetRange("Primary Department", true);

        if SubscriptionDept.IsEmpty() then begin
            SubscriptionDept.Reset();
            SubscriptionDept.SetRange("Subscription No.", "Subscription No.");
            if SubscriptionDept.FindFirst() then begin
                SubscriptionDept."Primary Department" := true;
                SubscriptionDept.Modify(true);
            end;
        end;
    end;
}
