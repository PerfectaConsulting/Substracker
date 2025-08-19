page 50143 "Department Selection"
{
    PageType = ListPart;
    SourceTable = "Department";
    Caption = 'Departments';
    DelayedInsert = true;
    AutoSplitKey = true;

    // ── Layout ─────────────────────────────────────────────────────────
    layout
    {
        area(content)
        {
            repeater(Departments)
            {
                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select the department code.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field("Department Description"; Rec."Department Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Shows the department description.';
                }

                field("Primary Department"; Rec."Primary Department")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates if this is the primary department.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    // ── Actions ────────────────────────────────────────────────────────
    actions
    {
        area(processing)
        {
            action(AddDepartment)
            {
                Caption = 'Add Department';
                ApplicationArea = All;
                Image = New;

                trigger OnAction()
                var
                    SubscriptionDept: Record "Department";
                    SubscriptionNo: Code[20];
                begin
                    SubscriptionNo := CopyStr(Rec.GetFilter("Subscription No."), 1, 20);
                    if SubscriptionNo = '' then begin
                        Message('No subscription filter is set. Cannot add departments.');
                        exit;
                    end;

                    SubscriptionDept.Init();
                    SubscriptionDept."Subscription No." := SubscriptionNo;
                    SubscriptionDept.Insert(true);

                    CurrPage.Update(false);
                end;
            }

            action(RemoveDepartment)
            {
                Caption = 'Remove Department';
                ApplicationArea = All;
                Image = Delete;

                trigger OnAction()
                begin
                    if Rec."Department Code" <> '' then
                        if Confirm('Remove department %1?', false, Rec."Department Code") then begin
                            Rec.Delete(true);
                            CurrPage.Update(false);
                        end;
                end;
            }

            action(SelectFromList)
            {
                Caption = 'Select from List';
                ApplicationArea = All;
                Image = SelectEntries;

                trigger OnAction()
                begin
                    SelectDepartmentsFromList();
                end;
            }
        }
    }

    // ── Local procedures ───────────────────────────────────────────────
    local procedure SelectDepartmentsFromList()
    var
        DepartmentMaster: Record "Department Master";
        DepartmentMultiSelect: Page "Department Multi-Selection";
        TempSelected: Record "Department Master" temporary;
        SubscriptionDept: Record "Department";
        SubscriptionNo: Code[20];
    begin
        SubscriptionNo := CopyStr(Rec.GetFilter("Subscription No."), 1, 20);
        if SubscriptionNo = '' then begin
            Message('No subscription filter is set. Cannot select departments.');
            exit;
        end;

        DepartmentMultiSelect.LookupMode(true);
        if DepartmentMultiSelect.RunModal() = Action::LookupOK then begin
            DepartmentMultiSelect.GetSelectionFilter(TempSelected);
            if TempSelected.FindSet() then
                repeat
                    if not SubscriptionDept.Get(SubscriptionNo, TempSelected.Code) then begin
                        SubscriptionDept.Init();
                        SubscriptionDept."Subscription No." := SubscriptionNo;
                        SubscriptionDept."Department Code" := TempSelected.Code;
                        SubscriptionDept.Insert(true);
                    end;
                until TempSelected.Next() = 0;

            CurrPage.Update(false);
        end;
    end;
}
