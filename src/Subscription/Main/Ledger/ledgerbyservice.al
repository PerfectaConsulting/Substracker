page 50144 "Subscriptions by Service"
{
    PageType = List;
    SourceTable = "Subscription";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Subscriptions by Service';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    // Default sort for direct opens too
    SourceTableView = sorting("Created Date") order(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Service Name"; Rec."Service Name") { ApplicationArea = All; }
                field(Vendor; Rec.Vendor) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Amount in LCY"; Rec."Amount in LCY") { ApplicationArea = All; }
                field("Start Date"; Rec."Start Date") { ApplicationArea = All; }
                field("End Date"; Rec."End Date") { ApplicationArea = All; }
                field("Created Date"; Rec."Created Date") { ApplicationArea = All; }
                field("Last Modified Date"; Rec."Last Modified Date") { ApplicationArea = All; }
                field("Category Code"; Rec."Category Code") { ApplicationArea = All; }
            }
        }
    }
}



pageextension 50131 "Subscription Card Ledger Ext" extends "Add Subscription" // ← replace with your actual card page name if different
{
    actions
    {
       addlast(navigation) // If the action name differs, switch to the correct identifier or use addlast(Processing)
        {
            action(Ledger)
            {
                Caption = 'Ledger';
                ApplicationArea = All;
                Image = List;
                Promoted = true;
                PromotedIsBig= true;
                PromotedCategory = Process;
                ToolTip = 'Show all subscriptions with the same Service Name, newest first.';

                RunObject = page "Subscriptions by Service";
                RunPageLink = "Service Name" = FIELD("Service Name");
                RunPageView = sorting("Created Date") order(Descending);
            }
        }
    }
}
