page 50128 "Subscription History FactBox"
{
    PageType = ListPart;
    SourceTable = "Subscription Ledger Entry";
    Caption = 'Recent Changes';
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Change Date"; Rec."Change Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'When the change was made';
                }

                field("Change Type"; Rec."Change Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type of change';
                    StyleExpr = ChangeTypeStyleExpr;
                }

                field("Changed By"; Rec."Changed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who made the change';
                }

                field("Previous End Date"; Rec."Previous End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Previous end date';
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'New end date';
                }
            }
        }
    }

    var
        ChangeTypeStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec."Change Type" of
            Rec."Change Type"::Creation:
                ChangeTypeStyleExpr := 'Favorable';
            Rec."Change Type"::Renewal:
                ChangeTypeStyleExpr := 'Favorable';
            Rec."Change Type"::Update:
                ChangeTypeStyleExpr := 'Attention';
            Rec."Change Type"::Cancellation:
                ChangeTypeStyleExpr := 'Unfavorable';
            else
                ChangeTypeStyleExpr := 'Standard';
        end;
    end;

    trigger OnOpenPage()
    begin
        // Show only recent entries (last 10) and sort by date
        Rec.SetCurrentKey("Change Date");
        Rec.Ascending(false);
    end;
}
