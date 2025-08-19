table 50140 "Notification"
{
    DataClassification = ToBeClassified;
    Caption = 'Notification';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Subscription No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Subscription No.';
            TableRelation = "Subscription"."No.";
        }
        field(3; "Created Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date';
        }
        field(4; "Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Message';
        }
        field(5; "Is Read"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Read';
            InitValue = false;
        }
        field(6; "User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'User ID';
            TableRelation = User."User Name";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key("User ID"; "User ID", "Is Read", "Created Date")
        {
        }
        key("Subscription"; "Subscription No.", "User ID", "Created Date")
        {
        }
    }

    trigger OnDelete()
    begin
        // Add any cleanup logic if needed
    end;
}
