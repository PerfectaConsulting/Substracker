table 70101 "Compliance Overview"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "ID"; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
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
            OptionMembers = Active,Pending,Compliant,"Non-Compliant",Submitted;
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
            OptionMembers = Submitted,Overdue,"Due Today","Upcoming Due","No Due Date";
            DataClassification = CustomerContent;
        }
        field(13; "File Submitted"; Date) { DataClassification = CustomerContent; }
        field(14; "Submission Reference No."; Text[50]) { DataClassification = CustomerContent; }
        field(15; "Payable Amount"; Decimal) { DataClassification = CustomerContent; }
        field(16; "Penalty or Fine"; Decimal) { DataClassification = CustomerContent; }
        field(17; "Additional Notes"; Text[250]) { DataClassification = CustomerContent; }
        field(18; "Submitted By"; Text[250]) { DataClassification = CustomerContent; }
        field(19; "Compliance ID"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Compliance ID';
        }
        field(20; "Custom 1"; Text[250]) { DataClassification = CustomerContent; }
        field(21; "Custom 2"; Text[250]) { DataClassification = CustomerContent; }
        field(22; "Custom 3"; Text[250]) { DataClassification = CustomerContent; }
        field(23; "Custom 4"; Text[250]) { DataClassification = CustomerContent; }
        field(24; "Custom5"; Text[250]) { DataClassification = CustomerContent; }
        
    }
    keys
    {
        key(PK; "ID") { Clustered = true; }
         key(PK2; "Filing Due Date") {  }
    }
    trigger OnInsert()
    var
        InitialSetup: Record "Initial Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        if "Compliance ID" = '' then begin
            InitialSetup.Get();
            InitialSetup.TestField("Compliance Nos.");
            "Compliance ID" := NoSeriesMgt.GetNextNo(InitialSetup."Compliance Nos.", WorkDate(), true);
        end;
    end;

    trigger OnModify()
    begin
        // Auto-sync Current Status with new Status field
        case Rec."Status" of
            Rec."Status"::OverDue:
                Rec."Current Status" := Rec."Current Status"::"Non-Compliant";
            Rec."Status"::"Due Today":
                Rec."Current Status" := Rec."Current Status"::Pending;
            Rec."Status"::"Upcoming Due":
                Rec."Current Status" := Rec."Current Status"::Active;
            Rec."Status"::"No Due Date":
                Rec."Current Status" := Rec."Current Status"::Compliant;
            Rec."Status"::Submitted:
                Rec."Current Status" := Rec."Current Status"::Submitted;
        end;
    end;
}