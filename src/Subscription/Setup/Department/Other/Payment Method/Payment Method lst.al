page 50136 "Custom Payment Method List"
{
    ApplicationArea = All;
    Caption = 'Custom Payment Methods';
    PageType = List;
    SourceTable = "Custom Payment Method";
    UsageCategory = Lists;
    CardPageId = "Custom Payment Method Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the payment method.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the payment method.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the payment method.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the payment method.';
                }
                field("Managed By"; Rec."Managed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee who manages this payment method.';
                }
                field("Expires At"; Rec."Expires At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this payment method expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(New)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedCategory = New;
                RunObject = Page "Custom Payment Method Card";
                RunPageMode = Create;
                ToolTip = 'Create a new payment method.';
            }
        }
    }
}
