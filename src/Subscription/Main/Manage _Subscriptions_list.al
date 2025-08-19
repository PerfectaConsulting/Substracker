page 50111 "Manage Subscriptions"
{
    PageType = List;
    SourceTable = "Subscription";
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'Manage Subscriptions';
    CardPageId = "Add Subscription";
    Editable = false;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the subscription number.';
                }

                field("Service Name"; Rec."Service Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the name of the subscription service.';
                }

                field("Vendor"; Rec.Vendor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the vendor providing the subscription service.';
                    Visible = false;
                }

                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the category code for this subscription.';
                }

                // ADDED: Show Category Description


                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the current status of the subscription.';
                    StyleExpr = StatusStyleExpr;
                }

                field("Amount"; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the subscription amount.';
                    Visible = false;
                }

                field("Billing Cycle"; Rec."Billing Cycle")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows how often the subscription is billed.';
                }

                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows when the subscription started.';
                }

                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows when the subscription will next renew.';
                    StyleExpr = RenewalStyleExpr;
                }

                field("Reminder Days"; Rec."Reminder Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows how many days before renewal to send reminders.';
                    Visible = false;
                }

                // ADDED: Show creation and modification info
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows when the subscription was created.';
                    Visible = false; // Hidden by default, can be shown via personalization
                }

                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows when the subscription was last modified.';
                    Visible = true; // Hidden by default
                }
            }
        }

        area(FactBoxes)
        {
            part(SubscriptionHistory; "Subscription History FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Subscription No." = field("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(NewSubscription)
            {
                ApplicationArea = All;
                Caption = 'New Subscription';
                ToolTip = 'Create a new subscription.';
                Image = New;

                trigger OnAction()
                var
                    AddSubscriptionPage: Page "Add Subscription";
                begin
                    AddSubscriptionPage.RunModal();
                    CurrPage.Update(false);
                end;
            }

            action(EditSubscription)
            {
                ApplicationArea = All;
                Caption = 'Edit Subscription';
                ToolTip = 'Edit the selected subscription.';
                Image = Edit;

                trigger OnAction()
                var
                    AddSubscriptionPage: Page "Add Subscription";
                begin
                    if Rec."No." = '' then begin
                        Message('Please select a subscription to edit.');
                        exit;
                    end;

                    AddSubscriptionPage.SetRecord(Rec);
                    AddSubscriptionPage.RunModal();
                    CurrPage.Update(false);
                end;
            }

            action(RenewSelected)
            {
                ApplicationArea = All;
                Caption = 'Renew Subscription';
                ToolTip = 'Renew the selected subscription.';
                Image = Refresh;

                trigger OnAction()
                begin
                    ProcessSelectedRenewal();
                end;
            }

            action(CancelSelected)
            {
                ApplicationArea = All;
                Caption = 'Cancel Subscription';
                ToolTip = 'Cancel the selected subscription.';
                Image = Cancel;

                trigger OnAction()
                begin
                    ProcessSelectedCancellation();
                end;
            }

            // ADDED: View History action
            action(ViewHistory)
            {
                ApplicationArea = All;
                Caption = 'View History';
                ToolTip = 'View the change history for the selected subscription.';
                Image = History;

                trigger OnAction()
                var
                    SubscriptionLedger: Record "Subscription Ledger Entry";
                begin
                    if Rec."No." = '' then begin
                        Message('Please select a subscription to view history.');
                        exit;
                    end;

                    SubscriptionLedger.SetRange("Subscription No.", Rec."No.");
                    Page.Run(Page::"Subscription Ledger Entries", SubscriptionLedger);
                end;
            }

            action(ShowExpiring)
            {
                ApplicationArea = All;
                Caption = 'Show Expiring Soon';
                ToolTip = 'Filter to show subscriptions expiring within reminder period.';
                Image = FilterLines;

                trigger OnAction()
                begin
                    FilterExpiringSoon();
                end;
            }

            // ADDED: Show Active Subscriptions filter
            action(ShowActive)
            {
                ApplicationArea = All;
                Caption = 'Show Active Only';
                ToolTip = 'Filter to show only active subscriptions.';
                Image = FilterLines;

                trigger OnAction()
                begin
                    FilterActiveOnly();
                end;
            }

            // ADDED: Show Expired Subscriptions filter
            action(ShowExpired)
            {
                ApplicationArea = All;
                Caption = 'Show Expired';
                ToolTip = 'Filter to show expired subscriptions.';
                Image = FilterLines;

                trigger OnAction()
                begin
                    FilterExpiredOnly();
                end;
            }

            action(ClearFilters)
            {
                ApplicationArea = All;
                Caption = 'Clear Filters';
                ToolTip = 'Clear all applied filters.';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update(false);
                    Message('All filters cleared.');
                end;
            }

            action(RefreshList)
            {
                ApplicationArea = All;
                Caption = 'Refresh List';
                ToolTip = 'Manually refresh the subscription list.';
                Image = Refresh;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                    Message('List refreshed successfully.');
                end;
            }

            action(DeleteSelected)
            {
                ApplicationArea = All;
                Caption = 'Delete Subscription';
                ToolTip = 'Delete the selected subscription permanently.';
                Image = Delete;

                trigger OnAction()
                begin
                    ProcessSelectedDeletion();
                end;
            }

            // ADDED: Update Status action (for expired subscriptions)
            action(UpdateStatuses)
            {
                ApplicationArea = All;
                Caption = 'Update Statuses';
                ToolTip = 'Update subscription statuses based on current dates.';
                Image = UpdateDescription;

                trigger OnAction()
                begin
                    UpdateAllStatuses();
                end;
            }
        }

        area(navigation)
        {
            action(SubscriptionSetup)
            {
                ApplicationArea = All;
                Caption = 'Subscription Setup';
                ToolTip = 'Open subscription setup to configure number series.';
                Image = Setup;
                RunObject = Page "Subscription Setup";
            }

            action(ManageCategories)
            {
                ApplicationArea = All;
                Caption = 'Manage Categories';
                ToolTip = 'Create and manage subscription categories.';
                Image = Category;
                RunObject = Page "Subscription Categories";
            }

            action(ViewLedgerEntries)
            {
                ApplicationArea = All;
                Caption = 'All Ledger Entries';
                ToolTip = 'View all subscription ledger entries.';
                Image = Ledger;
                RunObject = Page "Subscription Ledger Entries";
            }
        }

        area(Promoted)
        {
            group(New)
            {
                Caption = 'New';
                actionref(NewSubscription_Promoted; NewSubscription) { }
            }
            group(Process)
            {
                Caption = 'Process';
                actionref(RenewSelected_Promoted; RenewSelected) { }
                actionref(CancelSelected_Promoted; CancelSelected) { }
                actionref(DeleteSelected_Promoted; DeleteSelected) { }
                actionref(UpdateStatuses_Promoted; UpdateStatuses) { }
            }
            group(View)
            {
                Caption = 'View';
                actionref(ShowExpiring_Promoted; ShowExpiring) { }
                actionref(ShowActive_Promoted; ShowActive) { }
                actionref(ShowExpired_Promoted; ShowExpired) { }
                actionref(ClearFilters_Promoted; ClearFilters) { }
                actionref(RefreshList_Promoted; RefreshList) { }
            }
            group(History)
            {
                Caption = 'History';
                actionref(ViewHistory_Promoted; ViewHistory) { }
            }
            group(Setup)
            {
                Caption = 'Setup';
                actionref(ManageCategories_Promoted; ManageCategories) { }
            }
        }
    }

    var
        StatusStyleExpr: Text;
        RenewalStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        SetConditionalFormatting();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetConditionalFormatting();
    end;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("End Date");
        CurrPage.Update(false);
    end;

    local procedure SetConditionalFormatting()
    begin
        // UPDATED: Added Expired status styling
        case Rec.Status of
            Rec.Status::Active:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Cancelled:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::Inactive:
                StatusStyleExpr := 'Subordinate';
            Rec.Status::Expired:
                StatusStyleExpr := 'Attention';
            else
                StatusStyleExpr := 'Standard';
        end;

        // Enhanced renewal date styling
        if (Rec."End Date" <> 0D) then begin
            if (Rec."End Date" < Today) then
                RenewalStyleExpr := 'Unfavorable' // Past due
            else if (Rec."End Date" <= CalcDate('<+' + Format(Rec."Reminder Days") + 'D>', Today)) then
                RenewalStyleExpr := 'Attention' // Expiring soon
            else
                RenewalStyleExpr := 'Standard';
        end else
            RenewalStyleExpr := 'Standard';
    end;

    local procedure ProcessSelectedRenewal()
    begin
        if Rec."No." = '' then begin
            Message('Please select a subscription to renew.');
            exit;
        end;

        if Confirm('Do you want to renew the subscription "%1"?', false, Rec."Service Name") then begin
            Rec.RenewSubscription();
            Rec.Modify(true);
            CurrPage.Update(false);
            Message('Subscription "%1" renewed successfully.', Rec."Service Name");
        end;
    end;

    local procedure ProcessSelectedCancellation()
    begin
        if Rec."No." = '' then begin
            Message('Please select a subscription to cancel.');
            exit;
        end;

        if Confirm('Are you sure you want to cancel the subscription "%1"?', false, Rec."Service Name") then begin
            // UPDATED: Use the CancelSubscription procedure for proper ledger tracking
            Rec.CancelSubscription();
            CurrPage.Update(false);
            Message('Subscription "%1" cancelled successfully.', Rec."Service Name");
        end;
    end;

    local procedure ProcessSelectedDeletion()
    begin
        if Rec."No." = '' then begin
            Message('Please select a subscription to delete.');
            exit;
        end;

        if Confirm('Are you sure you want to permanently delete the subscription "%1"?\This will also create a ledger entry for audit purposes.', false, Rec."Service Name") then begin
            if Rec.Delete(true) then begin
                CurrPage.Update(false);
                Message('Subscription "%1" deleted successfully.', Rec."Service Name");
            end else
                Message('Error occurred while deleting the subscription.');
        end;
    end;

    local procedure FilterExpiringSoon()
    begin
        Rec.Reset();
        Rec.SetFilter("End Date", '<%1&<>%2', CalcDate('<+30D>', Today), 0D);
        Rec.SetFilter(Status, '<>%1', Rec.Status::Cancelled);
        CurrPage.Update(false);
        Message('Showing subscriptions expiring within 30 days.');
    end;

    // ADDED: Filter for active subscriptions only
    local procedure FilterActiveOnly()
    begin
        Rec.Reset();
        Rec.SetRange(Status, Rec.Status::Active);
        CurrPage.Update(false);
        Message('Showing active subscriptions only.');
    end;

    // ADDED: Filter for expired subscriptions only
    local procedure FilterExpiredOnly()
    begin
        Rec.Reset();
        Rec.SetRange(Status, Rec.Status::Expired);
        CurrPage.Update(false);
        Message('Showing expired subscriptions only.');
    end;

    // ADDED: Update all subscription statuses
    local procedure UpdateAllStatuses()
    var
        SubscriptionRec: Record "Subscription";
        UpdatedCount: Integer;
    begin
        SubscriptionRec.SetRange(Status, SubscriptionRec.Status::Active);
        if SubscriptionRec.FindSet() then begin
            repeat
                if SubscriptionRec.HasExpired() then begin
                    SubscriptionRec.UpdateStatus();
                    UpdatedCount += 1;
                end;
            until SubscriptionRec.Next() = 0;
        end;

        CurrPage.Update(false);
        if UpdatedCount > 0 then
            Message('%1 subscription(s) updated to Expired status.', UpdatedCount)
        else
            Message('No subscriptions needed status updates.');
    end;
}
