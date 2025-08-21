table 70150 "ST Payment Method"
{
    Caption = 'Payment Method';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(10; "Title"; Text[100]) { Caption = 'Title'; }
        field(20; "Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = type1,type2;
            OptionCaption = 'Type 1,Type 2';
        }
        field(30; "Description"; Text[250]) { Caption = 'Description'; }
        field(40; "Icon"; Text[30]) { Caption = 'Icon (Key)'; }
        field(50; "Managed By"; Text[100]) { Caption = 'Managed By'; }
        field(60; "Expires At"; Date) { Caption = 'Expires At'; }
    }

    keys
    {
        key(PK; "Entry No.","Description") { Clustered = true; } 
        
    }
         
    
}

page 70158 "ST Payment Methods"
{
    PageType = List;
    SourceTable = "ST Payment Method";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Payment Methods';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Title"; Rec."Title") { ApplicationArea = All; }
                field("Type"; Rec."Type") { ApplicationArea = All; }
                field("Description"; Rec."Description") { ApplicationArea = All; }
                field("Icon"; Rec."Icon") { ApplicationArea = All; }
                field("Managed By"; Rec."Managed By") { ApplicationArea = All; }
                field("Expires At"; Rec."Expires At") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Edit)
            {
                Caption = 'Edit';
                Image = EditLines;
                ApplicationArea = All;
                RunObject = Page "ST Payment Method Card";
                RunPageMode = Edit;
            }
        }
    }

}

page 70152 "ST Payment Method Card"
{
    PageType = Card;
    SourceTable = "ST Payment Method";
    ApplicationArea = All;
    Caption = 'Payment Method';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Title"; Rec."Title") { ApplicationArea = All; }
                field("Type"; Rec."Type") { ApplicationArea = All; }
                field("Description"; Rec."Description") { ApplicationArea = All; }
                field("Icon"; Rec."Icon") { ApplicationArea = All; ToolTip = 'visa, mastercard, paypal, amex, applepay, googlepay, user, megaphone, lock'; }
                field("Managed By"; Rec."Managed By") { ApplicationArea = All; }
                field("Expires At"; Rec."Expires At") { ApplicationArea = All; }
            }
        }


    }

}
