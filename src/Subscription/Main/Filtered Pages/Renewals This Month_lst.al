page 50132 "Renewals This Month"
{
    PageType = List;
    SourceTable = "Subscription";
    Caption = 'Renewals This Month';
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

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Renewal date';
                    StyleExpr = RenewalDateStyleExpr;
                }

                field("Reminder Days"; Rec."Reminder Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Reminder days before renewal';
                }

                field("Days Until Renewal"; DaysUntilRenewal)
                {
                    ApplicationArea = All;
                    Caption = 'Days Until Renewal';
                    ToolTip = 'Number of days until renewal';
                    StyleExpr = DaysStyleExpr;
                }

                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
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

            action(RenewNow)
            {
                ApplicationArea = All;
                Caption = 'Renew Now';
                ToolTip = 'Renew the selected subscription immediately';
                Image = Refresh;

                trigger OnAction()
                begin
                    ProcessRenewal();
                end;
            }

            action(FilterOverdue)
            {
                ApplicationArea = All;
                Caption = 'Show Overdue';
                ToolTip = 'Show subscriptions that are overdue for renewal';
                Image = FilterLines;

                trigger OnAction()
                begin
                    Rec.SetFilter("End Date", '<%1', Today);
                    CurrPage.Update(false);
                    Message('Showing overdue renewals.');
                end;
            }

            action(FilterDueToday)
            {
                ApplicationArea = All;
                Caption = 'Due Today';
                ToolTip = 'Show subscriptions due for renewal today';
                Image = FilterLines;

                trigger OnAction()
                begin
                    Rec.SetRange("End Date", Today);
                    CurrPage.Update(false);
                    Message('Showing renewals due today.');
                end;
            }

            action(FilterNext7Days)
            {
                ApplicationArea = All;
                Caption = 'Next 7 Days';
                ToolTip = 'Show subscriptions due for renewal in the next 7 days';
                Image = FilterLines;

                trigger OnAction()
                begin
                    Rec.SetRange("End Date", Today, CalcDate('<+7D>', Today));
                    CurrPage.Update(false);
                    Message('Showing renewals due in the next 7 days.');
                end;
            }

            action(ShowAllThisMonth)
            {
                ApplicationArea = All;
                Caption = 'Show All This Month';
                ToolTip = 'Show all renewals for this month';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    SetThisMonthFilter();
                    Message('Showing all renewals for this month.');
                end;
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(ViewSubscription_Promoted; ViewSubscription) { }
                actionref(RenewNow_Promoted; RenewNow) { }
            }
            group(Filter)
            {
                Caption = 'Filter';
                actionref(FilterOverdue_Promoted; FilterOverdue) { }
                actionref(FilterDueToday_Promoted; FilterDueToday) { }
                actionref(FilterNext7Days_Promoted; FilterNext7Days) { }
                actionref(ShowAllThisMonth_Promoted; ShowAllThisMonth) { }
            }
        }
    }

    var
        RenewalDateStyleExpr: Text;
        DaysStyleExpr: Text;
        DaysUntilRenewal: Integer;

    trigger OnAfterGetRecord()
    begin
        CalculateDaysUntilRenewal();
        SetConditionalFormatting();
    end;

    trigger OnOpenPage()
    begin
        SetThisMonthFilter();
    end;

    local procedure SetThisMonthFilter()
    var
        StartOfMonth: Date;
        EndOfMonth: Date;
    begin
        Rec.Reset();
        Rec.SetRange(Status, Rec.Status::Active);

        StartOfMonth := CalcDate('<-CM>', Today); // Start of current month
        EndOfMonth := CalcDate('<CM>', Today);   // End of current month

        Rec.SetRange("End Date", StartOfMonth, EndOfMonth);
        Rec.SetCurrentKey("End Date");
    end;

    local procedure CalculateDaysUntilRenewal()
    begin
        if Rec."End Date" <> 0D then
            DaysUntilRenewal := Rec."End Date" - Today
        else
            DaysUntilRenewal := 0;
    end;

    local procedure SetConditionalFormatting()
    begin
        // Style renewal dates
        if Rec."End Date" < Today then
            RenewalDateStyleExpr := 'Unfavorable' // Overdue
        else if Rec."End Date" = Today then
            RenewalDateStyleExpr := 'Attention'   // Due today
        else if Rec."End Date" <= CalcDate('<+7D>', Today) then
            RenewalDateStyleExpr := 'Attention'   // Due within 7 days
        else
            RenewalDateStyleExpr := 'Standard';

        // Style days until renewal
        if DaysUntilRenewal < 0 then
            DaysStyleExpr := 'Unfavorable' // Overdue
        else if DaysUntilRenewal <= 7 then
            DaysStyleExpr := 'Attention'   // Due soon
        else
            DaysStyleExpr := 'Standard';
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
