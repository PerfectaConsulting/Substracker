table 70140 "Subscription Reminder"
{
    Caption = 'Subscription Reminder';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Subscription ID"; Integer)
        {
            Caption = 'Subscription ID';
            DataClassification = CustomerContent;
        }

        field(3; "Subscription Name"; Text[100])
        {
            Caption = 'Subscription Name';
            DataClassification = CustomerContent;
        }

        field(4; "Reminder Date"; Date)
        {
            Caption = 'Reminder Date';
            DataClassification = SystemMetadata;
        }

        field(5; Message; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }

        field(6; "Is Today"; Boolean)
        {
            Caption = 'Is Today';
            DataClassification = SystemMetadata;
        }

        field(7; "Subscription Due Date"; Date)
        {
            Caption = 'Subscription Due Date';
            DataClassification = CustomerContent;
        }

        field(8; "Reminder Lead Time"; Integer)
        {
            Caption = 'Reminder Lead Time';
            DataClassification = CustomerContent;
        }

        field(9; "Email Sent"; Boolean)
        {
            Caption = 'Email Sent';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
