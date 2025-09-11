table 50130 "Custom Payment Method"
{
    Caption = 'Custom Payment Method';
    DataClassification = CustomerContent;
    LookupPageId = "Custom Payment Method List";
    DrillDownPageId = "Custom Payment Method List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }

        field(2; Name; Text[100])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }

        field(3; Type; Enum "Payment Method Type")
        {
            Caption = 'Type';
            NotBlank = true;
            DataClassification = CustomerContent;
        }

        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(5; "Card Image"; Media)
        {
            Caption = 'Card Image';
            DataClassification = CustomerContent;
        }

        field(6; "Managed By"; Code[20])
        {
            Caption = 'Managed By';
            TableRelation = "Employee Ext";
            DataClassification = CustomerContent;
        }

        field(7; "Expires At"; Date)
        {
            Caption = 'Expires At';
            DataClassification = CustomerContent;
        }

        field(8; "Employee Name"; Text[100])
        {
            Caption = 'Employee Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Employee Ext"."Full Name" where("No." = field("Managed By")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name)
        {
        }
        fieldgroup(Brick; "Code", Name, Type)
        {
        }
    }

    trigger OnDelete()
    var
        Subscription: Record "Subscription";
    begin
        Subscription.SetRange("Payment Method", "Code");
        if not Subscription.IsEmpty then
            Error('Cannot delete payment method %1 because it is being used by %2 subscription(s).',
                  "Code", Subscription.Count);
    end;

    // Helper procedures
    procedure GetDisplayText(): Text[250]
    begin
        if Name <> '' then
            exit(StrSubstNo('%1 - %2', "Code", Name))
        else
            exit("Code");
    end;

    procedure IsExpired(): Boolean
    begin
        if "Expires At" <> 0D then
            exit("Expires At" < Today)
        else
            exit(false);
    end;

    procedure GetStatusText(): Text[20]
    begin
        if IsExpired() then
            exit('Expired')
        else
            exit('Active');
    end;
}
