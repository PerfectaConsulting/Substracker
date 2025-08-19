table 50111 "Subscription Setup"
{
    Caption = 'Subscription Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Subscription Nos."; Code[20])
        {
            Caption = 'Subscription Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(20; "Employee Ext Nos."; Code[20])
        {
            Caption = 'Employee Ext Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(30; "Payment Method Nos."; Code[20])
        {
            Caption = 'Payment Method Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOnce()
    begin
        Reset();
        if not Get() then begin
            Init();
            "Primary Key" := '';
            Insert();
        end;
    end;
}
