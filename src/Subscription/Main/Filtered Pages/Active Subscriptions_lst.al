page 50130 "Active Subscriptions"
{
    PageType = List;
    SourceTable = "Subscription";
    Caption = 'Active Subscriptions';
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
                    StyleExpr = 'Strong';
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

                field("Billing Cycle"; Rec."Billing Cycle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Billing cycle';
                }

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Start date';
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'End date';
                    StyleExpr = EndDateStyleExpr;
                }

                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
                    StyleExpr = 'Favorable';
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

            action(RenewSelected)
            {
                ApplicationArea = All;
                Caption = 'Renew Subscription';
                ToolTip = 'Renew the selected subscription';
                Image = Refresh;

                trigger OnAction()
                begin
                    ProcessRenewal();
                end;
            }

            action(ShowExpiring)
            {
                ApplicationArea = All;
                Caption = 'Show Expiring Soon';
                ToolTip = 'Filter to show subscriptions expiring within 30 days';
                Image = FilterLines;

                trigger OnAction()
                begin
                    Rec.SetFilter("End Date", '<%1', CalcDate('<+30D>', Today));
                    CurrPage.Update(false);
                    Message('Showing active subscriptions expiring within 30 days.');
                end;
            }

            action(ClearFilters)
            {
                ApplicationArea = All;
                Caption = 'Show All Active';
                ToolTip = 'Show all active subscriptions';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    SetActiveFilter();
                    Message('Showing all active subscriptions.');
                end;
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(ViewSubscription_Promoted; ViewSubscription) { }
                actionref(RenewSelected_Promoted; RenewSelected) { }
            }
            group(Filter)
            {
                Caption = 'Filter';
                actionref(ShowExpiring_Promoted; ShowExpiring) { }
                actionref(ClearFilters_Promoted; ClearFilters) { }
            }
        }
    }

    var
        EndDateStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        // Highlight expiring subscriptions
        if (Rec."End Date" <> 0D) and (Rec."End Date" <= CalcDate('<+30D>', Today)) then
            EndDateStyleExpr := 'Attention'
        else
            EndDateStyleExpr := 'Standard';
    end;

    trigger OnOpenPage()
    begin
        SetActiveFilter();
    end;

    local procedure SetActiveFilter()
    begin
        Rec.Reset();
        Rec.SetRange(Status, Rec.Status::Active);
        Rec.SetCurrentKey("End Date");
    end;

    local procedure ProcessRenewal()
    begin
        if Rec."No." = '' then exit;

        if Confirm('Do you want to renew subscription "%1"?', false, Rec."Service Name") then begin
            Rec.RenewSubscription();
            Rec.Modify(true);
            CurrPage.Update(false);
            Message('Subscription "%1" renewed successfully.', Rec."Service Name");
        end;
    end;
}
