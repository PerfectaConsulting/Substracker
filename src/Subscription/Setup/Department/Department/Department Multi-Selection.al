page 50125 "Department Multi-Selection"
{
    PageType = List;
    SourceTable = "Department Master";
    Caption = 'Select Departments';
    ApplicationArea = All;
    ShowFilter = true;
    MultipleNewLines = false;

    // ── Layout ─────────────────────────────────────────────────────────
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

                field(Code; Rec.Code) { ApplicationArea = All; Editable = false; }
                field(Description; Rec.Description) { ApplicationArea = All; Editable = false; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; Editable = false; }
            }
        }
    }

    // ── Actions ────────────────────────────────────────────────────────
    actions
    {
        area(processing)
        {
            action(SelectAll)
            {
                Caption = 'Select All';
                ApplicationArea = All;
                Image = Process;

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

                trigger OnAction()
                begin
                    TempChosen.DeleteAll();
                    CurrPage.Update(false);
                end;
            }

            action(OpenDepartmentList)
            {
                Caption = 'Manage Departments';
                ApplicationArea = All;
                Image = EditList;   // ← valid icon (AL0482 resolved)
                RunObject = Page "Departments";
            }
        }
    }

    // ── Variables & Triggers ───────────────────────────────────────────
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
