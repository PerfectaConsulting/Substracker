table 50100 "Initial Setup"
{
    Caption = 'Initial Setup';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Subscription Nos."; Code[20])
        {
            Caption = 'Subscription Nos.';
            DataClassification = SystemMetadata;
            TableRelation = "No. Series";
        }
        field(20; "Compliance Nos."; Code[20])
        {
            Caption = 'Compliance Nos.';
            DataClassification = SystemMetadata;
            TableRelation = "No. Series";
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure CreateDefaultComplianceNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create number series if it doesn't exist
        if not NoSeries.Get('COMP') then begin
            NoSeries.Init();
            NoSeries.Code := 'COMP';
            NoSeries.Description := 'Compliance';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();
            // Create number series line
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'COMP';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'COMP00001';
            NoSeriesLine."Ending No." := 'COMP99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;
        // Update setup record
        "Compliance Nos." := 'COMP';
        Modify();
    end;

    procedure CreateDefaultSubscriptionNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create number series if it doesn't exist
        if not NoSeries.Get('SUB') then begin
            NoSeries.Init();
            NoSeries.Code := 'SUB';
            NoSeries.Description := 'Subscription';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();
            // Create number series line
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'SUB';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'SUB00001';
            NoSeriesLine."Ending No." := 'SUB99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;
        // Update setup record
        "Subscription Nos." := 'SUB';
        Modify();
    end;
}