page 50113 "Subscription Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Subscription Setup";
    Caption = 'Subscription Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Numbering)
            {
                Caption = 'Number Series';

                field("Subscription Nos."; Rec."Subscription Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the number series for subscription entries.';
                }

                field("Employee Ext Nos."; Rec."Employee Ext Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the number series for employee extension entries.';
                }

                field("Payment Method Nos."; Rec."Payment Method Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the number series for custom payment method entries.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(NumberSeries)
            {
                ApplicationArea = All;
                Caption = 'Number Series';
                ToolTip = 'View or edit number series.';
                Image = NumberSetup;
                RunObject = Page "No. Series";
            }

            action(CreateAllNumberSeries)
            {
                ApplicationArea = All;
                Caption = 'Auto Create All Number Series';
                ToolTip = 'Automatically create default number series for all modules.';
                Image = CreateForm;

                trigger OnAction()
                begin
                    CreateAllDefaultNumberSeries();
                    Message('All number series (SUB, EMP-EXT, PAY-METHOD) created and configured automatically.');
                    CurrPage.Update();
                end;
            }

            action(CreateSubscriptionNos)
            {
                ApplicationArea = All;
                Caption = 'Create Subscription Number Series';
                ToolTip = 'Create only subscription number series.';
                Image = CreateSerialNo;

                trigger OnAction()
                begin
                    CreateSubscriptionNumberSeries();
                    Message('Subscription number series "SUB" created successfully.');
                    CurrPage.Update();
                end;
            }

            action(CreateEmployeeExtNos)
            {
                ApplicationArea = All;
                Caption = 'Create Employee Ext Number Series';
                ToolTip = 'Create only employee extension number series.';
                Image = Employee;  // Changed from CreateEmployee to Employee

                trigger OnAction()
                begin
                    CreateEmployeeExtNumberSeries();
                    Message('Employee Ext number series "EMP-EXT" created successfully.');
                    CurrPage.Update();
                end;
            }

            action(CreatePaymentMethodNos)
            {
                ApplicationArea = All;
                Caption = 'Create Payment Method Number Series';
                ToolTip = 'Create only payment method number series.';
                Image = Payment;

                trigger OnAction()
                begin
                    CreatePaymentMethodNumberSeries();
                    Message('Payment Method number series "PAY-METHOD" created successfully.');
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;

        AutoCreateNumberSeriesOnFirstRun();
    end;

    local procedure AutoCreateNumberSeriesOnFirstRun()
    var
        NoSeries: Record "No. Series";
        NeedToCreate: Boolean;
        MessageText: Text;
    begin
        NeedToCreate := false;
        MessageText := '';

        // Check Subscription Number Series
        if Rec."Subscription Nos." = '' then begin
            if not NoSeries.Get('SUB') then begin
                NeedToCreate := true;
                MessageText += 'Subscription number series "SUB"' + '\';
            end else begin
                Rec."Subscription Nos." := 'SUB';
                Rec.Modify();
            end;
        end;

        // Check Employee Ext Number Series
        if Rec."Employee Ext Nos." = '' then begin
            if not NoSeries.Get('EMP-EXT') then begin
                NeedToCreate := true;
                MessageText += 'Employee Ext number series "EMP-EXT"' + '\';
            end else begin
                Rec."Employee Ext Nos." := 'EMP-EXT';
                Rec.Modify();
            end;
        end;

        // Check Payment Method Number Series
        if Rec."Payment Method Nos." = '' then begin
            if not NoSeries.Get('PAY-METHOD') then begin
                NeedToCreate := true;
                MessageText += 'Payment Method number series "PAY-METHOD"';
            end else begin
                Rec."Payment Method Nos." := 'PAY-METHOD';
                Rec.Modify();
            end;
        end;

        if NeedToCreate then begin
            if Confirm('No number series found for:\%1\\Do you want to create them automatically?', true, MessageText) then begin
                CreateAllDefaultNumberSeries();
                Message('Number series created automatically.');
            end;
        end;
    end;

    local procedure CreateAllDefaultNumberSeries()
    begin
        CreateSubscriptionNumberSeries();
        CreateEmployeeExtNumberSeries();
        CreatePaymentMethodNumberSeries();
    end;

    local procedure CreateSubscriptionNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get('SUB') then begin
            NoSeries.Init();
            NoSeries.Code := 'SUB';
            NoSeries.Description := 'Subscription';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'SUB';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'SUB00001';
            NoSeriesLine."Ending No." := 'SUB99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        Rec."Subscription Nos." := 'SUB';
        Rec.Modify();
    end;

    local procedure CreateEmployeeExtNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get('EMP-EXT') then begin
            NoSeries.Init();
            NoSeries.Code := 'EMP-EXT';
            NoSeries.Description := 'Employee Extension';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'EMP-EXT';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'EMP-EXT00001';
            NoSeriesLine."Ending No." := 'EMP-EXT99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        Rec."Employee Ext Nos." := 'EMP-EXT';
        Rec.Modify();
    end;

    local procedure CreatePaymentMethodNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get('PAY-METHOD') then begin
            NoSeries.Init();
            NoSeries.Code := 'PAY-METHOD';
            NoSeries.Description := 'Custom Payment Method';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries.Insert();

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'PAY-METHOD';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'PAY-METHOD00001';
            NoSeriesLine."Ending No." := 'PAY-METHOD99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        Rec."Payment Method Nos." := 'PAY-METHOD';
        Rec.Modify();
    end;
}
