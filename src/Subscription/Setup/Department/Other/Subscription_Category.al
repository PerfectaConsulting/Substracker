table 50124 "Subscription Category"
{
    DataClassification = ToBeClassified;
    Caption = 'Subscription Category';
    LookupPageId = "Subscription Categories";
    DrillDownPageId = "Subscription Categories";

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';
            NotBlank = true;
        }

        field(2; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if Code = '' then
            Error('Category Code cannot be blank.');
    end;
}
