page 70103 "Compliance Card"
{
    PageType = Card;
    SourceTable = "Compliance Overview";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Compliance Card';
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General Information';
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Compliance ID"; Rec."Compliance ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the unique ID for this compliance entry.';
                }
                field("Compliance Name"; Rec."Compliance Name")
                {
                    ApplicationArea = All;
                    Editable = IsNameEditable;
                }
                field("Compliance Category"; Rec."Compliance Category") { ApplicationArea = All; }
                field("Governing Authority"; Rec."Governing Authority") { ApplicationArea = All; }
                field("Current Status"; Rec."Current Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Filing)
            {
                Caption = 'Filing Details';
                field("Filing Starting Date"; Rec."Filing Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Filing End Date"; Rec."Filing End Date") { ApplicationArea = All; }
                field("Filing Due Date"; Rec."Filing Due Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    trigger OnValidate()
                    begin
                        UpdateStatus();
                    end;
                }
                field("Filing Recurring Frequency"; Rec."Filing Recurring Frequency") { ApplicationArea = All; }
                field("Reminder Lead Time (Days)"; Rec."Reminder Lead Time (Days)")
                {
                    ApplicationArea = All;
                }
                field("Reminder Schedule"; Rec."Reminder Schedule") { ApplicationArea = All; }
            }
            group(OtherDetails)
            {
                Caption = 'Other Details';
                field("File Submitted"; Rec."File Submitted")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        UserRec: Record User;
                    begin
                        if Rec."Submitted By" = '' then begin
                            if UserRec.Get(UserSecurityId()) then
                                Rec."Submitted By" := UserRec."User Name";
                        end;
                    end;
                }
                field("Submission Reference No."; Rec."Submission Reference No.") { ApplicationArea = All; }
                field("Submitted By"; Rec."Submitted By") { ApplicationArea = All; Editable = false; }
                field("Payable Amount"; Rec."Payable Amount") { ApplicationArea = All; }
                field("Penalty or Fine"; Rec."Penalty or Fine") { ApplicationArea = All; }
                field("Additional Notes"; Rec."Additional Notes")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        InitialSetup: Record "Initial Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        UpdateStatus();
        CheckIfArchived();
        if Rec."Compliance ID" = '' then begin
            InitialSetup.Get();
            InitialSetup.TestField("Compliance Nos.");
            Rec."Compliance ID" := NoSeriesMgt.GetNextNo(InitialSetup."Compliance Nos.", WorkDate(), true);
            Rec.Modify(true);
        end;
    end;

    local procedure UpdateDueDate()
    begin
        if Rec."Filing Starting Date" = 0D then begin
            Message('Please enter a starting date first.');
            exit;
        end;
        case Rec."Filing Recurring Frequency" of
            Rec."Filing Recurring Frequency"::Monthly:
                Rec."Filing Due Date" := CalcDate('<+1M>', Rec."Filing Due Date");
            Rec."Filing Recurring Frequency"::Quarterly:
                Rec."Filing Due Date" := CalcDate('<+3M>', Rec."Filing Due Date");
            Rec."Filing Recurring Frequency"::Annually:
                Rec."Filing Due Date" := CalcDate('<+1Y>', Rec."Filing Due Date");
        end;
        Rec.Modify(true);
        CurrPage.Update();
        Message('Due date updated successfully.');
    end;

    local procedure UpdateStatus()
    var
        TodayDate: Date;
    begin
        TodayDate := Today();
        if Rec."Filing Due Date" = 0D then begin
            Rec."Status" := Rec."Status"::"No Due Date";
        end else begin
            if TodayDate > Rec."Filing Due Date" then
                Rec."Status" := Rec."Status"::OverDue
            else if TodayDate = Rec."Filing Due Date" then
                Rec."Status" := Rec."Status"::"Due Today"
            else if CalcDate('<+2D>', TodayDate) = Rec."Filing Due Date" then
                Rec."Status" := Rec."Status"::"Upcoming Due"
            else if TodayDate < Rec."Filing Due Date" then
                Rec."Status" := Rec."Status"::"No Due Date";
        end;
        if Rec."Status" <> xRec."Status" then
            Rec.Modify(true);
    end;

    local procedure CheckIfArchived()
    var
        ComplianceArchive: Record "Compliance Overview Archive";
    begin
        IsNameEditable := true;
        if ComplianceArchive.GetFilter("Compliance Name") = Rec."Compliance Name" then
            exit;
        ComplianceArchive.SetRange("Compliance Name", Rec."Compliance Name");
        if not ComplianceArchive.IsEmpty() then
            IsNameEditable := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Submitted By" := UserId();
        CurrPage.Update();
    end;

    var
        IsNameEditable: Boolean;
}


pageextension 70103 Ext extends "Compliance Card"
{
    actions
    {
        addlast(Processing)
        {


            action(Submit)
            {
                Caption = 'Submit';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    SubmissionHandler: Codeunit "Compliance Submission Handler";
                begin
                    if Rec."File Submitted" = 0D then
                        Error('Without Filling Submission date you cant submit the compliance');
                    if Rec."Submission Reference No." = '' then
                        Error('You cannot submit the compliance without a Submission Reference No.');
                    if Rec."Submitted By" = '' then
                        Error('You cannot submit the compliance without the Submitted By field being filled.');

                    Rec."Status" := Rec."Status"::Submitted;
                    Rec.Modify(true);
                    SubmissionHandler.SubmitCompliance(Rec);
                    Message('Compliance submitted and next period generated.');
                end;
            }

            action("Ledger")
            {
                Caption = 'Ledger';
                Image = Ledger;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    LedgerPage: Page "Filtered Ledger";
                begin
                    LedgerPage.SetComplianceName(Rec."Compliance Name");
                    LedgerPage.Run();
                end;
            }

        }
    }
}