page 50127 "Subscription Ledger Entries"
{
    PageType = List;
    SourceTable = "Subscription Ledger Entry";
    Caption = 'Subscription History - Renewals & Cancellations';
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Entry number';
                }

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

                field("Previous Start Date"; Rec."Previous Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Previous start date';
                }

                field("Previous End Date"; Rec."Previous End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Previous end date';
                }

                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Subscription amount';
                }

                field("Amount in LCY"; Rec."Amount in LCY")
            {
                ApplicationArea = All;
                ToolTip = 'Subscription amount in local currency';
            }

                field("Billing Cycle"; Rec."Billing Cycle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Billing cycle';
                }

                field("Note"; Rec.Note)
                {
                    ApplicationArea = All;
                    ToolTip = 'Notes about this change';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(BackToSubscription)
            {
                ApplicationArea = All;
                Caption = 'Back to Subscription';
                ToolTip = 'Go back to the subscription card';
                Image = PreviousRecord;

                trigger OnAction()
                var
                    Subscription: Record "Subscription";
                begin
                    if Rec."Subscription No." <> '' then begin
                        if Subscription.Get(Rec."Subscription No.") then
                            Page.Run(Page::"Add Subscription", Subscription);
                    end;
                end;
            }

            action(ShowOnlyRenewals)
            {
                ApplicationArea = All;
                Caption = 'Show Only Renewals';
                ToolTip = 'Show only renewal entries';
                Image = FilterLines;

                trigger OnAction()
                begin
                    ApplyRenewalFilter();
                end;
            }

            action(ShowOnlyCancellations)
            {
                ApplicationArea = All;
                Caption = 'Show Only Cancellations';
                ToolTip = 'Show only cancellation entries';
                Image = FilterLines;

                trigger OnAction()
                begin
                    ApplyCancellationFilter();
                end;
            }

            action(ShowBoth)
            {
                ApplicationArea = All;
                Caption = 'Show Both';
                ToolTip = 'Show both renewals and cancellations';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    ApplyBothFilter();
                end;
            }
        }

        area(Promoted)
        {
            group(Navigate)
            {
                Caption = 'Navigate';
                actionref(BackToSubscription_Promoted; BackToSubscription) { }
            }
            group(Filter)
            {
                Caption = 'Filter';
                actionref(ShowOnlyRenewals_Promoted; ShowOnlyRenewals) { }
                actionref(ShowOnlyCancellations_Promoted; ShowOnlyCancellations) { }
                actionref(ShowBoth_Promoted; ShowBoth) { }
            }
        }
    }

    var
        ChangeTypeStyleExpr: Text;
        SubscriptionNoFilter: Code[20];

    trigger OnAfterGetRecord()
    begin
        // Style the change types
        case Rec."Change Type" of
            Rec."Change Type"::Renewal:
                ChangeTypeStyleExpr := 'Favorable';
            Rec."Change Type"::Cancellation:
                ChangeTypeStyleExpr := 'Unfavorable';
            else
                ChangeTypeStyleExpr := 'Standard';
        end;
    end;

    trigger OnOpenPage()
    begin
        // Get the subscription filter if set
        if Rec.GetFilter("Subscription No.") <> '' then
            SubscriptionNoFilter := Rec.GetRangeMin("Subscription No.");

        // Apply initial filter to show only Renewal and Cancellation
        ApplyBothFilter();

        // Sort by latest changes first
        Rec.SetCurrentKey("Change Date");
        Rec.Ascending(false);
    end;

    local procedure ApplyRenewalFilter()
    begin
        Rec.Reset();
        if SubscriptionNoFilter <> '' then
            Rec.SetRange("Subscription No.", SubscriptionNoFilter);
        Rec.SetRange("Change Type", Rec."Change Type"::Renewal);
        Rec.SetCurrentKey("Change Date");
        Rec.Ascending(false);
        CurrPage.Update(false);
        Message('Showing only renewal history.');
    end;

    local procedure ApplyCancellationFilter()
    begin
        Rec.Reset();
        if SubscriptionNoFilter <> '' then
            Rec.SetRange("Subscription No.", SubscriptionNoFilter);
        Rec.SetRange("Change Type", Rec."Change Type"::Cancellation);
        Rec.SetCurrentKey("Change Date");
        Rec.Ascending(false);
        CurrPage.Update(false);
        Message('Showing only cancellation history.');
    end;

    local procedure ApplyBothFilter()
    begin
        Rec.Reset();
        if SubscriptionNoFilter <> '' then
            Rec.SetRange("Subscription No.", SubscriptionNoFilter);
        // Filter to show only Renewal and Cancellation (exclude Creation and Update)
        Rec.SetFilter("Change Type", '%1|%2', Rec."Change Type"::Renewal, Rec."Change Type"::Cancellation);
        Rec.SetCurrentKey("Change Date");
        Rec.Ascending(false);
        CurrPage.Update(false);
        Message('Showing renewals and cancellations only.');
    end;
}
