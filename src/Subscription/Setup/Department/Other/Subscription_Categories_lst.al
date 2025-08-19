page 50123 "Subscription Categories"
{
    PageType = List;
    SourceTable = "Subscription Category";
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Subscription Categories';
    Editable = true;
    DelayedInsert = true;
    InsertAllowed = true;  // CRUCIAL: This enables the "New" button in dropdown
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category code.';
                }

                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category description.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(NewCategory)
            {
                ApplicationArea = All;
                Caption = 'New Category';
                ToolTip = 'Create a new subscription category';
                Image = New;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    SubscriptionCategory: Record "Subscription Category";
                begin
                    Clear(SubscriptionCategory);
                    SubscriptionCategory.Insert(true);

                    // Set focus on the new record
                    Rec := SubscriptionCategory;
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
