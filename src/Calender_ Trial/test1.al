

// ComplianceCalendar.al - Control Add-in Definition
controladdin ComplianceCalendar
{
    RequestedHeight = 600;
    RequestedWidth = 1200;
    MinimumHeight = 400;
    MinimumWidth = 800;
    MaximumHeight = 1000;
    MaximumWidth = 1600;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'src\Dashboard\Resources\ComplianceCalendar.js';
    StyleSheets = 'src\Dashboard\Resources\ComplianceCalendar.css';

    event ControlAddInReady();
    event DateClicked(date: Text);
    event ViewChanged(viewType: Text; year: Integer; month: Integer);

    procedure InitializeCalendar(data: Text);
    procedure UpdateCalendarData(data: Text);
    procedure NavigateToDate(year: Integer; month: Integer);
    procedure SetView(viewType: Text);
}

// ComplianceOverviewCalendar.al - Page Definition
page 70124 "Compliance Overview Calendar"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Compliance Overview Calendar';

    layout
    {
        area(Content)
        {
            usercontrol(ComplianceCalendar; ComplianceCalendar)
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    LoadCalendarData();
                end;

                trigger DateClicked(date: Text)
                begin
                    ShowComplianceRecords(date);
                end;

                trigger ViewChanged(viewType: Text; year: Integer; month: Integer)
                begin
                    CurrentYear := year;
                    CurrentMonth := month;
                    CurrentView := viewType;
                    LoadCalendarData();
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Monthly View")
            {
                Caption = 'Monthly View';
                Image = Calendar;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CurrPage.ComplianceCalendar.SetView('monthly');
                end;
            }

            action("Yearly View")
            {
                Caption = 'Yearly View';
                Image = ViewPage;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CurrPage.ComplianceCalendar.SetView('yearly');
                end;
            }

            action("Today")
            {
                Caption = 'Today';
                Image = Today;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Today: Date;
                begin
                    Today := WorkDate();
                    CurrPage.ComplianceCalendar.NavigateToDate(Date2DMY(Today, 3), Date2DMY(Today, 2));
                end;
            }

            action("Refresh")
            {
                Caption = 'Refresh';
                Image = Refresh;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    LoadCalendarData();
                end;
            }
        }
    }

    var
        CurrentYear: Integer;
        CurrentMonth: Integer;
        CurrentView: Text;

    local procedure LoadCalendarData()
    var
        ComplianceOverview: Record "Compliance Overview";
        JsonBuilder: JsonObject;
        JsonArray: JsonArray;
        JsonItem: JsonObject;
        JsonText: Text;
    begin
        // Initialize current date if not set
        if CurrentYear = 0 then begin
            CurrentYear := Date2DMY(WorkDate(), 3);
            CurrentMonth := Date2DMY(WorkDate(), 2);
        end;

        if CurrentView = '' then
            CurrentView := 'monthly';

        // Build JSON data for calendar
        JsonBuilder.Add('year', CurrentYear);
        JsonBuilder.Add('month', CurrentMonth);
        JsonBuilder.Add('view', CurrentView);

        // Get compliance records
        ComplianceOverview.SetFilter("Filing Due Date", '>=%1', DMY2Date(1, 1, CurrentYear));
        ComplianceOverview.SetFilter("Filing Due Date", '<=%1', DMY2Date(31, 12, CurrentYear));

        if ComplianceOverview.FindSet() then
            repeat
                Clear(JsonItem);
                JsonItem.Add('id', ComplianceOverview.ID);
                JsonItem.Add('date', Format(ComplianceOverview."Filing Due Date", 0, '<Year4>-<Month,2>-<Day,2>'));
                JsonItem.Add('title', ComplianceOverview."Compliance Name");
                JsonItem.Add('category', Format(ComplianceOverview."Compliance Category"));
                JsonItem.Add('authority', ComplianceOverview."Governing Authority");
                JsonItem.Add('status', Format(ComplianceOverview.Status));
                JsonItem.Add('currentStatus', Format(ComplianceOverview."Current Status"));
                JsonItem.Add('complianceId', ComplianceOverview."Compliance ID");
                JsonArray.Add(JsonItem);
            until ComplianceOverview.Next() = 0;

        JsonBuilder.Add('events', JsonArray);
        JsonBuilder.WriteTo(JsonText);

        CurrPage.ComplianceCalendar.UpdateCalendarData(JsonText);
    end;

    local procedure ShowComplianceRecords(DateText: Text)
    var
        ComplianceOverview: Record "Compliance Overview";
        ComplianceList: Page "Compliance Overview List";
        SelectedDate: Date;
    begin
        // Convert date text to date
        if Evaluate(SelectedDate, DateText) then begin
            ComplianceOverview.SetRange("Filing Due Date", SelectedDate);
            ComplianceList.SetTableView(ComplianceOverview);
            ComplianceList.RunModal();
        end;
    end;
}

// Create a simple list page for displaying compliance records
page 50101 "Compliance Overview List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Compliance Overview";
    Caption = 'Compliance Records';

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field("ID"; Rec.ID)
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                }
                field("Compliance ID"; Rec."Compliance ID")
                {
                    ApplicationArea = All;
                    Caption = 'Compliance ID';
                }
                field("Compliance Name"; Rec."Compliance Name")
                {
                    ApplicationArea = All;
                    Caption = 'Compliance Name';
                }
                field("Compliance Category"; Rec."Compliance Category")
                {
                    ApplicationArea = All;
                    Caption = 'Category';
                }
                field("Governing Authority"; Rec."Governing Authority")
                {
                    ApplicationArea = All;
                    Caption = 'Governing Authority';
                }
                field("Filing Due Date"; Rec."Filing Due Date")
                {
                    ApplicationArea = All;
                    Caption = 'Filing Due Date';
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                }
                field("Current Status"; Rec."Current Status")
                {
                    ApplicationArea = All;
                    Caption = 'Current Status';
                }
                field("Payable Amount"; Rec."Payable Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Payable Amount';
                }
            }
        }
    }
}