table 70111 "Compliance Overview Archive"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Archive ID"; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(100; "Source Compliance ID"; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(2; "Compliance Name"; Text[100]) { DataClassification = CustomerContent; }
        field(3; "Compliance Category"; Option)
        {
            OptionMembers = Tax,Payroll,CorporateFiling,Accounting,AR,AGM;
            DataClassification = CustomerContent;
        }
        field(4; "Governing Authority"; Text[100]) { DataClassification = CustomerContent; }

        field(5; "Current Status"; Option)
        {
            OptionMembers = Active,InProgress,Filed,Overdue;
            DataClassification = CustomerContent;
        }


        field(6; "Filing Starting Date"; Date) { DataClassification = CustomerContent; }
        field(7; "Filing End Date"; Date) { DataClassification = CustomerContent; }
        field(8; "Filing Due Date"; Date) { DataClassification = CustomerContent; }
        field(9; "Filing Recurring Frequency"; Option)
        {
            OptionMembers = Monthly,Quarterly,Annually,OneTime;
            DataClassification = CustomerContent;
        }


        field(10; "Reminder Lead Time (Days)"; Integer) { DataClassification = CustomerContent; }
        field(11; "Reminder Schedule"; Option)
        {
            OptionMembers = OneTime,TwoReminders,UntilDue;
            DataClassification = CustomerContent;
        }


        field(12; "Status"; Option)
        {
            OptionMembers = Submitted,Pending,"Not Applicable";
            DataClassification = CustomerContent;
        }

        field(13; "File Submitted"; Date) { DataClassification = CustomerContent; }
        field(14; "Submission Reference No."; Text[50]) { DataClassification = CustomerContent; }


        field(15; "Payable Amount"; Decimal) { DataClassification = CustomerContent; }
        field(16; "Penalty or Fine"; Decimal) { DataClassification = CustomerContent; }


        field(17; "Additional Notes"; Text[250]) { DataClassification = CustomerContent; }
        field(18; "Submitted By"; Text[250]) { DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Archive ID") { Clustered = true; }
    }
}