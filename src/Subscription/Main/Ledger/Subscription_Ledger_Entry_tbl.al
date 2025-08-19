table 50126 "Subscription Ledger Entry"
{
    DataClassification = ToBeClassified;
    Caption = 'Subscription Ledger Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Subscription No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Subscription No.';
            TableRelation = "Subscription"."No.";
        }

        field(3; "Service Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Service Name';
        }

        field(4; "Vendor"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Vendor';
        }

        field(5; "Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Category Code';
            TableRelation = "Subscription Category".Code;
        }

        field(6; "Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Amount';
            DecimalPlaces = 2 : 2;
        }

        field(7; "Billing Cycle"; Enum "Billing Cycle")
        {
            DataClassification = ToBeClassified;
            Caption = 'Billing Cycle';
        }

        field(8; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Start Date';
        }

        field(9; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'End Date';
        }

        field(10; "Status"; Enum "Subscription Status")
        {
            DataClassification = ToBeClassified;
            Caption = 'Status';
        }

        field(11; "Reminder Days"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Reminder Days';
        }

        field(12; "Reminder Policy"; Enum "Reminder Policy")
        {
            DataClassification = ToBeClassified;
            Caption = 'Reminder Policy';
        }

        field(13; "Note"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Note';
        }

        field(14; "Change Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Change Date';
        }

        field(15; "Changed By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Changed By';
        }

        field(16; "Change Type"; Enum "Subscription Change Type")
        {
            DataClassification = ToBeClassified;
            Caption = 'Change Type';
        }

        field(17; "Previous Start Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Previous Start Date';
        }

        field(18; "Previous End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Previous End Date';
        }

        // NEW: Currency Code field (REQUIRED to fix AL0132 error)
        field(19; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
        }

        // NEW: Amount in LCY field (REQUIRED to fix AL0132 error)
        field(20; "Amount in LCY"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Amount in LCY';
            AutoFormatType = 1; // Amount format
            DecimalPlaces = 2 : 2;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Subscription No.", "Change Date")
        {
        }
        // NEW: Add key for Currency Code for better performance
        key(SK2; "Currency Code", "Change Date")
        {
        }
        // NEW: Add key for Change Type for reporting
        key(SK3; "Change Type", "Change Date")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Change Date" = 0DT then
            "Change Date" := CurrentDateTime;

        if "Changed By" = '' then
            "Changed By" := UserId;
    end;

    procedure GetChangeTypeText(): Text
    begin
        case "Change Type" of
            "Change Type"::Creation:
                exit('Creation');
            "Change Type"::Update:
                exit('Update');
            "Change Type"::Renewal:
                exit('Renewal');
            "Change Type"::Cancellation:
                exit('Cancellation');
            else
                exit('Unknown');
        end;
    end;

    procedure GetBillingCycleText(): Text
    begin
        case "Billing Cycle" of
            "Billing Cycle"::Weekly:
                exit('Weekly');
            "Billing Cycle"::Monthly:
                exit('Monthly');
            "Billing Cycle"::Quarterly:
                exit('Quarterly');
            "Billing Cycle"::Yearly:
                exit('Yearly');
            else
                exit('Unknown');
        end;
    end;

    procedure GetStatusText(): Text
    begin
        case Status of
            Status::Active:
                exit('Active');
            Status::Inactive:
                exit('Inactive');
            Status::Cancelled:
                exit('Cancelled');
            Status::Expired:
                exit('Expired');
            else
                exit('Unknown');
        end;
    end;

    // NEW: Get formatted currency amount display
    procedure GetFormattedAmount(): Text
    var
        Currency: Record Currency;
    begin
        if "Currency Code" <> '' then begin
            if Currency.Get("Currency Code") then
                exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>') + ' ' + "Currency Code")
            else
                exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>') + ' ' + "Currency Code");
        end else
            exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    // NEW: Get formatted LCY amount display
    procedure GetFormattedAmountLCY(): Text
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if GLSetup.Get() then begin
            if GLSetup."LCY Code" <> '' then
                exit(Format("Amount in LCY", 0, '<Precision,2:2><Standard Format,0>') + ' ' + GLSetup."LCY Code")
            else
                exit(Format("Amount in LCY", 0, '<Precision,2:2><Standard Format,0>'));
        end else
            exit(Format("Amount in LCY", 0, '<Precision,2:2><Standard Format,0>'));
    end;

    procedure HasCurrencyCode(): Boolean
    begin
        exit("Currency Code" <> '');
    end;

    procedure IsForeignCurrency(): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if "Currency Code" = '' then
            exit(false);

        if GLSetup.Get() then
            exit("Currency Code" <> GLSetup."LCY Code")
        else
            exit(true);
    end;
}
