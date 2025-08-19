table 70130 "Compliance Reminder"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Compliance ID"; Integer)
        {
            DataClassification = CustomerContent;

        }

        field(3; "Compliance Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(4; "Reminder Date"; Date)
        {
            DataClassification = SystemMetadata;
        }

        field(5; Message; Text[250])
        {
            DataClassification = CustomerContent;
        }

        field(6; "Is Today"; Boolean)
        {
            DataClassification = SystemMetadata;
        }

        field(7; "Compliance Due Date"; Date)
        {
            Caption = 'Compliance Due Date';
        }

        field(8; "Reminder Lead Time"; Integer)
        {
            Caption = 'Reminder Lead Time';
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