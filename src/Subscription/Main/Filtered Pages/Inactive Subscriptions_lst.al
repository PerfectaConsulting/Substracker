page 50131 "Inactive Subscriptions"
{
    PageType = List;
    SourceTable = "Subscription";
    Caption = 'Inactive Subscriptions';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Subscription number';
                }

                field("Service Name"; Rec."Service Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Service name';
                }

                field("Vendor"; Rec.Vendor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor name';
                }

                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Category code';
                }

                field("Amount"; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Subscription amount';
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'End date';
                }

                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
                    StyleExpr = StatusStyleExpr;
                }

                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'When it became inactive';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ViewSubscription)
            {
                ApplicationArea = All;
                Caption = 'View Subscription';
                ToolTip = 'Open the selected subscription';
                Image = Document;

                trigger OnAction()
                begin
                    Page.Run(Page::"Add Subscription", Rec);
                end;
            }

            action(ReactivateSelected)
            {
                ApplicationArea = All;
                Caption = 'Reactivate';
                ToolTip = 'Reactivate the selected subscription';
                Image = ReleaseDoc;

                trigger OnAction()
                begin
                    ProcessReactivation();
                end;
            }

            action(FilterExpired)
            {
                ApplicationArea = All;
                Caption = 'Show Only Expired';
                ToolTip = 'Show only expired subscriptions';
                Image = FilterLines;

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Expired);
                    CurrPage.Update(false);
                    Message('Showing only expired subscriptions.');
                end;
            }

            action(FilterCancelled)
            {
                ApplicationArea = All;
                Caption = 'Show Only Cancelled';
                ToolTip = 'Show only cancelled subscriptions';
                Image = FilterLines;

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Cancelled);
                    CurrPage.Update(false);
                    Message('Showing only cancelled subscriptions.');
                end;
            }

            action(ShowAllInactive)
            {
                ApplicationArea = All;
                Caption = 'Show All Inactive';
                ToolTip = 'Show all inactive subscriptions';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    SetInactiveFilter();
                    Message('Showing all inactive subscriptions.');
                end;
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(ViewSubscription_Promoted; ViewSubscription) { }
                actionref(ReactivateSelected_Promoted; ReactivateSelected) { }
            }
            group(Filter)
            {
                Caption = 'Filter';
                actionref(FilterExpired_Promoted; FilterExpired) { }
                actionref(FilterCancelled_Promoted; FilterCancelled) { }
                actionref(ShowAllInactive_Promoted; ShowAllInactive) { }
            }
        }
    }

    var
        StatusStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Expired:
                StatusStyleExpr := 'Attention';
            Rec.Status::Cancelled:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::Inactive:
                StatusStyleExpr := 'Subordinate';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    trigger OnOpenPage()
    begin
        SetInactiveFilter();
    end;

    local procedure SetInactiveFilter()
    begin
        Rec.Reset();
        Rec.SetFilter(Status, '%1|%2|%3', Rec.Status::Inactive, Rec.Status::Expired, Rec.Status::Cancelled);
        Rec.SetCurrentKey("Last Modified Date");
        Rec.Ascending(false);
    end;

    local procedure ProcessReactivation()
    begin
        if Rec."No." = '' then exit;

        if Confirm('Do you want to reactivate subscription "%1"?', false, Rec."Service Name") then begin
            Rec.Status := Rec.Status::Active;
            Rec.Modify(true);
            CurrPage.Update(false);
            Message('Subscription "%1" reactivated successfully.', Rec."Service Name");
        end;
    end;
}
