table 50121 "Employee Ext Setup"
{
    Caption = 'Employee Ext Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }

        field(10; "Employee Ext Nos."; Code[20])
        {
            Caption = 'Employee Ext Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetRecordOnce()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
