page 50122 "Employee Ext Setup"
{
    PageType = Card;
    SourceTable = "Employee Ext Setup";
    Caption = 'Employee Ext Setup';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Numbering)
            {
                Caption = 'Numbering';

                field("Employee Ext Nos."; Rec."Employee Ext Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series for employee ext numbers.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetRecordOnce();
    end;
}
