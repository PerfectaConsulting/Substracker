page 50125 "Department Multi-Selection"
{
    PageType = List;
    SourceTable = "Department Master";
    Caption = 'Select Departments';
    ApplicationArea = All;
    ShowFilter = true;
    MultipleNewLines = false;

    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Choices)
            {
                field(Select; IsSelected)
                {
                    ApplicationArea = All;
                    Caption = 'Select';

                    trigger OnValidate()
                    begin
                        if IsSelected then begin
                            if not TempChosen.Get(Rec.Code) then begin
                                TempChosen := Rec;
                                TempChosen.Insert();
                            end;
                        end else
                            if TempChosen.Get(Rec.Code) then
                                TempChosen.Delete();
                    end;
                }

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        // ✅ Use area(creation) to place button before Edit List
        area(creation)
        {
            action(ManageDepartments)
            {
                Caption = 'Manage Departments';
                ApplicationArea = All;
                Image = Departments;
                ToolTip = 'Open the Departments page to manage department records.';
                RunObject = Page "Departments";
            }
        }

        area(processing)
        {
            action(SelectAll)
            {
                Caption = 'Select All';
                ApplicationArea = All;
                Image = Process;
                ToolTip = 'Select all departments shown in the current view.';

                trigger OnAction()
                var
                    Dept: Record "Department Master";
                begin
                    Dept.CopyFilters(Rec);
                    if Dept.FindSet() then
                        repeat
                            if not TempChosen.Get(Dept.Code) then begin
                                TempChosen := Dept;
                                TempChosen.Insert();
                            end;
                        until Dept.Next() = 0;

                    CurrPage.Update(false);
                end;
            }

            action(DeselectAll)
            {
                Caption = 'Deselect All';
                ApplicationArea = All;
                Image = ClearFilter;
                ToolTip = 'Clear all current selections.';

                trigger OnAction()
                begin
                    TempChosen.DeleteAll();
                    CurrPage.Update(false);
                end;
            }
        }

        // ✅ Promoted actions with unique names
        area(Promoted)
        {
            group(Management)
            {
                Caption = 'Manage Department';
                actionref(ManageDepartments_Ref; ManageDepartments) { }
            }
            group(Process)
            {
                Caption = 'Process';
                actionref(SelectAll_Ref; SelectAll) { }
                actionref(DeselectAll_Ref; DeselectAll) { }
            }
        }
    }

    var
        TempChosen: Record "Department Master" temporary;
        IsSelected: Boolean;

    trigger OnAfterGetRecord()
    begin
        IsSelected := TempChosen.Get(Rec.Code);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsSelected := TempChosen.Get(Rec.Code);
    end;

    procedure SetSelectionFilter(var Sel: Record "Department Master" temporary)
    begin
        TempChosen.DeleteAll();
        if Sel.FindSet() then
            repeat
                TempChosen := Sel;
                TempChosen.Insert();
            until Sel.Next() = 0;
    end;

    procedure GetSelectionFilter(var Sel: Record "Department Master" temporary)
    begin
        Sel.DeleteAll();
        if TempChosen.FindSet() then
            repeat
                Sel := TempChosen;
                Sel.Insert();
            until TempChosen.Next() = 0;
    end;
}
