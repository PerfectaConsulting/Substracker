// page 50100 "Initial Setup"
// {
//     PageType = Card;
//     ApplicationArea = All;
//     UsageCategory = Administration;
//     SourceTable = "Initial Setup";
//     Caption = 'Initial Setup';
//     InsertAllowed = false;
//     DeleteAllowed = false;

//     layout
//     {
//         area(Content)
//         {
//             group(General)
//             {
//                 Caption = 'General';
//                 // Additional fields and logic can be added here later
//             }

//             group(Compliance)
//             {
//                 Caption = 'Compliance';

//                 field("Compliance Nos."; Rec."Compliance Nos.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specify the number series for compliance entries.';
//                 }
//             }

//             group(Subscription)
//             {
//                 Caption = 'Subscription';

//                 field("Subscription Nos."; Rec."Subscription Nos.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Specify the number series for subscription entries.';
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(Navigation)
//         {
//             action(NumberSeries)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Number Series';
//                 ToolTip = 'View or edit number series.';
//                 Image = NumberSetup;
//                 RunObject = Page "No. Series";
//             }

//             action(CreateComplianceNumberSeries)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Auto Create Compliance Number Series';
//                 ToolTip = 'Automatically create default number series for compliance.';
//                 Image = CreateForm;

//                 trigger OnAction()
//                 begin
//                     CreateDefaultComplianceNumberSeries();
//                     Message('Number series "COMP" created and configured automatically.');
//                     CurrPage.Update();
//                 end;
//             }

//             action(CreateSubscriptionNumberSeries)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Auto Create Subscription Number Series';
//                 ToolTip = 'Automatically create default number series for subscriptions.';
//                 Image = CreateForm;

//                 trigger OnAction()
//                 begin
//                     CreateDefaultSubscriptionNumberSeries();
//                     Message('Number series "SUB" created and configured automatically.');
//                     CurrPage.Update();
//                 end;
//             }
//         }
//     }

//     trigger OnOpenPage()
//     begin
//         Rec.Reset();
//         if not Rec.Get() then begin
//             Rec.Init();
//             Rec."Primary Key" := '';
//             Rec.Insert();
//         end;

//         // Auto-create number series if not set
//         if Rec."Compliance Nos." = '' then
//             AutoCreateComplianceNumberSeriesOnFirstRun();

//         if Rec."Subscription Nos." = '' then
//             AutoCreateSubscriptionNumberSeriesOnFirstRun();
//     end;

//     local procedure AutoCreateComplianceNumberSeriesOnFirstRun()
//     var
//         NoSeries: Record "No. Series";
//     begin
//         // Only auto-create on first run when field is empty
//         if not NoSeries.Get('COMP') then begin
//             if Confirm('No compliance number series found. Do you want to create default number series "COMP" automatically?') then begin
//                 CreateDefaultComplianceNumberSeries();
//                 Message('Number series "COMP" has been created automatically.');
//             end;
//         end else begin
//             // Number series exists, just assign it
//             Rec."Compliance Nos." := 'COMP';
//             Rec.Modify();
//         end;
//     end;

//     local procedure AutoCreateSubscriptionNumberSeriesOnFirstRun()
//     var
//         NoSeries: Record "No. Series";
//     begin
//         // Only auto-create on first run when field is empty
//         if not NoSeries.Get('SUB') then begin
//             if Confirm('No subscription number series found. Do you want to create default number series "SUB" automatically?') then begin
//                 CreateDefaultSubscriptionNumberSeries();
//                 Message('Number series "SUB" has been created automatically.');
//             end;
//         end else begin
//             // Number series exists, just assign it
//             Rec."Subscription Nos." := 'SUB';
//             Rec.Modify();
//         end;
//     end;

//     local procedure CreateDefaultComplianceNumberSeries()
//     var
//         NoSeries: Record "No. Series";
//         NoSeriesLine: Record "No. Series Line";
//     begin
//         // Create number series if it doesn't exist
//         if not NoSeries.Get('COMP') then begin
//             NoSeries.Init();
//             NoSeries.Code := 'COMP';
//             NoSeries.Description := 'Compliance';
//             NoSeries."Default Nos." := true;
//             NoSeries."Manual Nos." := true;
//             NoSeries.Insert();

//             // Create number series line
//             NoSeriesLine.Init();
//             NoSeriesLine."Series Code" := 'COMP';
//             NoSeriesLine."Line No." := 10000;
//             NoSeriesLine."Starting No." := 'COMP00001';
//             NoSeriesLine."Ending No." := 'COMP99999';
//             NoSeriesLine."Increment-by No." := 1;
//             NoSeriesLine.Insert();
//         end;

//         // Update setup record
//         Rec."Compliance Nos." := 'COMP';
//         Rec.Modify();
//     end;

//     local procedure CreateDefaultSubscriptionNumberSeries()
//     var
//         NoSeries: Record "No. Series";
//         NoSeriesLine: Record "No. Series Line";
//     begin
//         // Create number series if it doesn't exist
//         if not NoSeries.Get('SUB') then begin
//             NoSeries.Init();
//             NoSeries.Code := 'SUB';
//             NoSeries.Description := 'Subscription';
//             NoSeries."Default Nos." := true;
//             NoSeries."Manual Nos." := true;
//             NoSeries.Insert();

//             // Create number series line
//             NoSeriesLine.Init();
//             NoSeriesLine."Series Code" := 'SUB';
//             NoSeriesLine."Line No." := 10000;
//             NoSeriesLine."Starting No." := 'SUB00001';
//             NoSeriesLine."Ending No." := 'SUB99999';
//             NoSeriesLine."Increment-by No." := 1;
//             NoSeriesLine.Insert();
//         end;

//         // Update setup record
//         Rec."Subscription Nos." := 'SUB';
//         Rec.Modify();
//     end;
// }

page 50100 "Initial Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Initial Setup";
    Caption = 'Initial Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                // Additional fields and logic can be added here later
            }
            group(Compliance)
            {
                Caption = 'Compliance';
                field("Compliance Nos."; Rec."Compliance Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the number series for compliance entries.';
                }
            }
            group(Subscription)
            {
                Caption = 'Subscription';
                field("Subscription Nos."; Rec."Subscription Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the number series for subscription entries.';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(NumberSeries)
            {
                ApplicationArea = All;
                Caption = 'Number Series';
                ToolTip = 'View or edit number series.';
                Image = NumberSetup;
                RunObject = Page "No. Series";
            }
            action(CreateComplianceNumberSeries)
            {
                ApplicationArea = All;
                Caption = 'Auto Create Compliance Number Series';
                ToolTip = 'Automatically create default number series for compliance.';
                Image = CreateForm;
                trigger OnAction()
                begin
                    Rec.CreateDefaultComplianceNumberSeries();
                    Message('Number series "COMP" created and configured automatically.');
                    CurrPage.Update();
                end;
            }
            action(CreateSubscriptionNumberSeries)
            {
                ApplicationArea = All;
                Caption = 'Auto Create Subscription Number Series';
                ToolTip = 'Automatically create default number series for subscriptions.';
                Image = CreateForm;
                trigger OnAction()
                begin
                    Rec.CreateDefaultSubscriptionNumberSeries();
                    Message('Number series "SUB" created and configured automatically.');
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
    end;
}