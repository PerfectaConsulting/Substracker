page 50136 "Custom Payment Method List"
{
    ApplicationArea = All;
    Caption = 'Custom Payment Methods';
    PageType = List;
    SourceTable = "Custom Payment Method";
    UsageCategory = Lists;
    CardPageId = "Custom Payment Method Card";
    Editable = false;

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
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the full name of the managing employee.';
                }
                field("Expires At"; Rec."Expires At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this payment method expires.';
                }
                // ✅ FIXED: Use variable instead of procedure call
                field(Status; StatusText)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Shows whether the payment method is active or expired.';
                    StyleExpr = StatusStyleExpr;
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
                ToolTip = 'Create a new payment method.';

                trigger OnAction()
                var
                    PaymentMethod: Record "Custom Payment Method";
                    PaymentMethodCard: Page "Custom Payment Method Card";
                begin
                    Clear(PaymentMethod);
                    PaymentMethodCard.SetRecord(PaymentMethod);
                    if PaymentMethodCard.RunModal() = Action::OK then
                        CurrPage.Update(false);
                end;
            }
        }

        area(Navigation)
        {
            action(Edit)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Edit the selected payment method.';

                trigger OnAction()
                var
                    PaymentMethodCard: Page "Custom Payment Method Card";
                begin
                    PaymentMethodCard.SetRecord(Rec);
                    if PaymentMethodCard.RunModal() = Action::OK then
                        CurrPage.Update(false);
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete the selected payment method.';

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to delete payment method %1?', false, Rec."Code") then begin
                        Rec.Delete(true);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    var
        StatusStyleExpr: Text;
        StatusText: Text[20];
        IsExpiredVar: Boolean;

    // ✅ FIXED: Calculate procedure results in trigger
    trigger OnAfterGetRecord()
    begin
        // Calculate status text
        if (Rec."Expires At" <> 0D) and (Rec."Expires At" < Today) then
            StatusText := 'Expired'
        else
            StatusText := 'Active';

        // Set style based on status
        IsExpiredVar := (Rec."Expires At" <> 0D) and (Rec."Expires At" < Today);
        if IsExpiredVar then
            StatusStyleExpr := 'Unfavorable'
        else
            StatusStyleExpr := 'Favorable';
    end;
}
