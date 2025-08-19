page 70156 "Compliance Chart"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Compliance Dashboard';

    layout
    {
        area(Content)
        {
            // KPI Section at the top
            group(ComplianceKPIs)
            {
                Caption = 'Key Performance Indicators';

                field(TotalCompliances; TotalComplianceCount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Compliances';
                    StyleExpr = 'Strong';
                    ToolTip = 'Shows the total number of compliance items in the system';
                    Editable = false;
                }

                field(OverdueCompliances; OverdueCount)
                {
                    ApplicationArea = All;
                    Caption = 'Overdue Items';
                    StyleExpr = OverdueStyleExpr;
                    ToolTip = 'Number of compliance items that are past their due date';
                    Editable = false;
                }

                field(ComplianceRate; ComplianceRateText)
                {
                    ApplicationArea = All;
                    Caption = 'Compliance Rate';
                    StyleExpr = ComplianceRateStyleExpr;
                    ToolTip = 'Percentage of compliances that are filed or completed on time';
                    Editable = false;
                }

                field(LastUpdated; LastUpdateText)
                {
                    ApplicationArea = All;
                    Caption = 'Last Updated';
                    StyleExpr = 'Subordinate';
                    ToolTip = 'When this data was last refreshed';
                    Editable = false;
                }
            }

            // Filters and Options
            group(FilterOptions)
            {
                Caption = 'Filters & Display Options';

                field(DateFromFilter; DateFromFilter)
                {
                    ApplicationArea = All;
                    Caption = 'From Date';
                    ToolTip = 'Filter compliance data from this date onwards';

                    trigger OnValidate()
                    begin
                        RefreshAllData();
                    end;
                }

                field(DateToFilter; DateToFilter)
                {
                    ApplicationArea = All;
                    Caption = 'To Date';
                    ToolTip = 'Filter compliance data up to this date';

                    trigger OnValidate()
                    begin
                        RefreshAllData();
                    end;
                }

                field(ChartTypeField; ChartTypeOption)
                {
                    ApplicationArea = All;
                    Caption = 'Chart Type';
                    OptionCaption = 'Pie Chart,Doughnut Chart,Column Chart,Line Chart,Area Chart,Point Chart';
                    ToolTip = 'Select how to display the compliance data visually';

                    trigger OnValidate()
                    begin
                        RefreshAllCharts();
                    end;
                }

                field(ShowPercentages; ShowPercentagesOption)
                {
                    ApplicationArea = All;
                    Caption = 'Show Percentages';
                    ToolTip = 'Display percentage values in addition to counts';

                    trigger OnValidate()
                    begin
                        RefreshAllCharts();
                    end;
                }
            }

            // Charts in a more organized layout
            group(ChartsContainer)
            {
                Caption = 'Charts Overview';

                group(NameChartGroup)
                {
                    Caption = 'Top 15 Compliances by Name';

                    usercontrol(NameChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
                    {
                        ApplicationArea = All;

                        trigger DataPointClicked(Point: JsonObject)
                        begin
                            HandleNameChartClick(Point);
                        end;

                        trigger DataPointDoubleClicked(Point: JsonObject)
                        begin
                            HandleNameChartDoubleClick(Point);
                        end;

                        trigger AddInReady()
                        begin
                            InitializeNameChart();
                        end;
                    }
                }

                group(CategoryChartGroup)
                {
                    Caption = 'Compliance Distribution by Category';

                    usercontrol(CategoryChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
                    {
                        ApplicationArea = All;

                        trigger DataPointClicked(Point: JsonObject)
                        begin
                            HandleCategoryChartClick(Point);
                        end;

                        trigger DataPointDoubleClicked(Point: JsonObject)
                        begin
                            HandleCategoryChartDoubleClick(Point);
                        end;

                        trigger AddInReady()
                        begin
                            InitializeCategoryChart();
                        end;
                    }
                }

                group(StatusChartGroup)
                {
                    Caption = 'Compliance Status Overview';

                    usercontrol(StatusChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
                    {
                        ApplicationArea = All;

                        trigger DataPointClicked(Point: JsonObject)
                        begin
                            HandleStatusChartClick(Point);
                        end;

                        trigger DataPointDoubleClicked(Point: JsonObject)
                        begin
                            HandleStatusChartDoubleClick(Point);
                        end;

                        trigger AddInReady()
                        begin
                            InitializeStatusChart();
                        end;
                    }
                }
            }

            // Summary Information
            group(SummaryInfo)
            {
                Caption = 'Summary Information';

                field(MostCommonCategory; MostCommonCategoryText)
                {
                    ApplicationArea = All;
                    Caption = 'Most Common Category';
                    StyleExpr = 'Strong';
                    Editable = false;
                }

                field(UpcomingDeadlines; UpcomingDeadlinesText)
                {
                    ApplicationArea = All;
                    Caption = 'Upcoming Deadlines (Next 30 Days)';
                    StyleExpr = UpcomingDeadlinesStyleExpr;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshData)
            {
                ApplicationArea = All;
                Caption = 'Refresh All Data';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Refresh all charts and KPIs with latest data';

                trigger OnAction()
                begin
                    RefreshAllData();
                    Message('Dashboard data has been refreshed.');
                end;
            }

            action(ViewCompliances)
            {
                ApplicationArea = All;
                Caption = 'View Pending Compliances';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open the complete compliance overview list';

                trigger OnAction()
                begin
                    // Navigate to compliance list page - adjust page number as needed
                    PAGE.Run(70104); // Replace with actual page number
                end;
            }

            action(ViewOverdue)
            {
                ApplicationArea = All;
                Caption = 'View Submitted Items';
                Image = Warning;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View only overdue compliance items';

                trigger OnAction()
                begin
                    PAGE.Run(70150);
                end;
            }
        }
    }

    var
        ChartTypeOption: Option "Pie Chart","Doughnut Chart","Column Chart","Line Chart","Area Chart","Point Chart";
        ShowPercentagesOption: Boolean;
        DateFromFilter: Date;
        DateToFilter: Date;
        TotalComplianceCount: Integer;
        OverdueCount: Integer;
        ComplianceRateText: Text;
        LastUpdateText: Text;
        MostCommonCategoryText: Text;
        UpcomingDeadlinesText: Text;
        OverdueStyleExpr: Text;
        ComplianceRateStyleExpr: Text;
        UpcomingDeadlinesStyleExpr: Text;

    trigger OnOpenPage()
    begin
        ChartTypeOption := ChartTypeOption::"Pie Chart";
        ShowPercentagesOption := true;

        // Set default date filters (last 12 months)
        DateToFilter := Today();
        DateFromFilter := CalcDate('-12M', Today());

        RefreshAllData();
    end;

    // Comprehensive data refresh
    local procedure RefreshAllData()
    begin
        CalculateKPIs();
        RefreshAllCharts();
        CalculateSummaryInfo();
        CurrPage.Update(false);
    end;

    // Calculate Key Performance Indicators
    local procedure CalculateKPIs()
    var
        ComplianceArchive: Record "Compliance Overview Archive";
        FiledCount: Integer;
        ComplianceRate: Decimal;
    begin
        TotalComplianceCount := 0;
        OverdueCount := 0;
        FiledCount := 0;

        ComplianceArchive.SetFilter("Filing Due Date", '%1..%2', DateFromFilter, DateToFilter);

        if ComplianceArchive.FindSet() then
            repeat
                TotalComplianceCount += 1;

                // Count overdue items
                if (ComplianceArchive."Filing Due Date" <> 0D) and
                   (ComplianceArchive."Filing Due Date" < Today()) and
                   (ComplianceArchive."Current Status" in [ComplianceArchive."Current Status"::Active, ComplianceArchive."Current Status"::InProgress]) then
                    OverdueCount += 1;

                // Count filed items
                if ComplianceArchive."Current Status" = ComplianceArchive."Current Status"::Filed then
                    FiledCount += 1;
            until ComplianceArchive.Next() = 0;

        // Calculate compliance rate
        if TotalComplianceCount > 0 then begin
            ComplianceRate := (FiledCount / TotalComplianceCount) * 100;
            ComplianceRateText := Format(ComplianceRate, 0, '<Precision,2:2><Standard Format,0>') + '%';
        end else begin
            ComplianceRateText := '0%';
        end;

        // Set style expressions based on values
        if OverdueCount > 0 then
            OverdueStyleExpr := 'Unfavorable'
        else
            OverdueStyleExpr := 'Favorable';

        if ComplianceRate >= 90 then
            ComplianceRateStyleExpr := 'Favorable'
        else if ComplianceRate >= 70 then
            ComplianceRateStyleExpr := 'Ambiguous'
        else
            ComplianceRateStyleExpr := 'Unfavorable';

        LastUpdateText := Format(CurrentDateTime(), 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>');
    end;

    // Calculate summary information
    local procedure CalculateSummaryInfo()
    var
        ComplianceArchive: Record "Compliance Overview Archive";
        CategoryCount: Dictionary of [Text, Integer];
        CategoryName: Text;
        MaxCount: Integer;
        UpcomingCount: Integer;
        FutureDate: Date;
    begin
        // Find most common category
        ComplianceArchive.SetFilter("Filing Due Date", '%1..%2', DateFromFilter, DateToFilter);

        if ComplianceArchive.FindSet() then
            repeat
                CategoryName := Format(ComplianceArchive."Compliance Category");

                if CategoryCount.ContainsKey(CategoryName) then
                    CategoryCount.Set(CategoryName, CategoryCount.Get(CategoryName) + 1)
                else
                    CategoryCount.Add(CategoryName, 1);
            until ComplianceArchive.Next() = 0;

        // Find category with highest count
        MaxCount := 0;
        foreach CategoryName in CategoryCount.Keys() do begin
            if CategoryCount.Get(CategoryName) > MaxCount then begin
                MaxCount := CategoryCount.Get(CategoryName);
                MostCommonCategoryText := CategoryName + ' (' + Format(MaxCount) + ' items)';
            end;
        end;

        // Count upcoming deadlines (next 30 days)
        FutureDate := CalcDate('+30D', Today());
        ComplianceArchive.Reset();
        ComplianceArchive.SetRange("Filing Due Date", Today(), FutureDate);
        ComplianceArchive.SetFilter("Current Status", '<>%1', ComplianceArchive."Current Status"::Filed);
        UpcomingCount := ComplianceArchive.Count();

        UpcomingDeadlinesText := Format(UpcomingCount) + ' items';

        if UpcomingCount > 10 then
            UpcomingDeadlinesStyleExpr := 'Attention'
        else if UpcomingCount > 5 then
            UpcomingDeadlinesStyleExpr := 'Ambiguous'
        else
            UpcomingDeadlinesStyleExpr := 'Favorable';
    end;

    // Refresh all charts
    local procedure RefreshAllCharts()
    begin
        InitializeCategoryChart();
        InitializeNameChart();
        InitializeStatusChart();
    end;

    // Chart click handlers with actual functionality
    local procedure HandleNameChartClick(Point: JsonObject)
    var
        ComplianceArchive: Record "Compliance Overview Archive";
        ComplianceName: Text;
        NameToken: JsonToken;
    begin
        if Point.Get('AxisLabel', NameToken) then begin
            ComplianceName := NameToken.AsValue().AsText();
            ComplianceArchive.SetRange("Compliance Name", ComplianceName);
            PAGE.RunModal(50000, ComplianceArchive); // Replace with actual page number
        end;
    end;

    local procedure HandleCategoryChartClick(Point: JsonObject)
    var
        CategoryName: Text;
        CategoryToken: JsonToken;
    begin
        if Point.Get('AxisLabel', CategoryToken) then begin
            CategoryName := CategoryToken.AsValue().AsText();
            Message('Clicked on category: %1', CategoryName);
        end;
    end;

    local procedure HandleStatusChartClick(Point: JsonObject)
    var
        StatusName: Text;
        StatusToken: JsonToken;
    begin
        if Point.Get('AxisLabel', StatusToken) then begin
            StatusName := StatusToken.AsValue().AsText();
            Message('Clicked on status: %1', StatusName);
        end;
    end;

    local procedure HandleNameChartDoubleClick(Point: JsonObject)
    begin
        Message('Double-clicked on compliance name chart');
    end;

    local procedure HandleCategoryChartDoubleClick(Point: JsonObject)
    begin
        Message('Double-clicked on category chart');
    end;

    local procedure HandleStatusChartDoubleClick(Point: JsonObject)
    begin
        Message('Double-clicked on status chart');
    end;



    // Convert Option to Business Chart Type Enum
    local procedure GetChartType(): Enum "Business Chart Type"
    var
        TempBusinessChartBuffer: Record "Business Chart Buffer" temporary;
    begin
        case ChartTypeOption of
            ChartTypeOption::"Pie Chart":
                exit(TempBusinessChartBuffer."Chart Type"::Pie);
            ChartTypeOption::"Doughnut Chart":
                exit(TempBusinessChartBuffer."Chart Type"::Doughnut);
            ChartTypeOption::"Column Chart":
                exit(TempBusinessChartBuffer."Chart Type"::Column);
            ChartTypeOption::"Line Chart":
                exit(TempBusinessChartBuffer."Chart Type"::Line);
            ChartTypeOption::"Area Chart":
                exit(TempBusinessChartBuffer."Chart Type"::Area);
            ChartTypeOption::"Point Chart":
                exit(TempBusinessChartBuffer."Chart Type"::Point);
            else
                exit(TempBusinessChartBuffer."Chart Type"::Pie);
        end;
    end;

    // Initialize Status Chart (now functional)
    local procedure InitializeStatusChart()
    var
        TempBusinessChartBuffer: Record "Business Chart Buffer" temporary;
    begin
        LoadComplianceByCurrentStatus(TempBusinessChartBuffer);
        TempBusinessChartBuffer.Update(CurrPage.StatusChart);
    end;

    // Initialize Category Chart
    local procedure InitializeCategoryChart()
    var
        TempBusinessChartBuffer: Record "Business Chart Buffer" temporary;
    begin
        LoadComplianceByCategory(TempBusinessChartBuffer);
        TempBusinessChartBuffer.Update(CurrPage.CategoryChart);
    end;

    // Initialize Name Chart
    local procedure InitializeNameChart()
    var
        TempBusinessChartBuffer: Record "Business Chart Buffer" temporary;
    begin
        LoadComplianceByName(TempBusinessChartBuffer);
        TempBusinessChartBuffer.Update(CurrPage.NameChart);
    end;

    // Updated chart loading methods with date filtering
    local procedure LoadComplianceByName(var TempBusinessChartBuffer: Record "Business Chart Buffer" temporary)
    var
        ComplianceArchive: Record "Compliance Overview Archive";
        NameCount: Dictionary of [Text, Integer];
        NameList: List of [Text];
        ComplianceName: Text;
        Count: Integer;
        i: Integer;
        SelectedChartType: Enum "Business Chart Type";
    begin
        SelectedChartType := GetChartType();

        // Apply date filters
        ComplianceArchive.SetFilter("Filing Due Date", '%1..%2', DateFromFilter, DateToFilter);

        if ComplianceArchive.FindSet() then
            repeat
                ComplianceName := ComplianceArchive."Compliance Name";
                if ComplianceName = '' then
                    ComplianceName := 'Unnamed Compliance';

                if NameCount.ContainsKey(ComplianceName) then
                    NameCount.Set(ComplianceName, NameCount.Get(ComplianceName) + 1)
                else
                    NameCount.Add(ComplianceName, 1);
            until ComplianceArchive.Next() = 0;

        TempBusinessChartBuffer.Initialize();
        TempBusinessChartBuffer."Chart Type" := SelectedChartType;
        TempBusinessChartBuffer.SetXAxis('Compliance Name', TempBusinessChartBuffer."Data Type"::String);
        TempBusinessChartBuffer.AddMeasure('Count', 1, TempBusinessChartBuffer."Data Type"::Integer, SelectedChartType);

        NameList := NameCount.Keys();
        for i := 1 to MinValue(NameList.Count(), 15) do begin
            ComplianceName := NameList.Get(i);
            Count := NameCount.Get(ComplianceName);
            TempBusinessChartBuffer.AddColumn(ComplianceName);
            TempBusinessChartBuffer.SetValue('Count', i - 1, Count);
        end;
    end;

    local procedure LoadComplianceByCategory(var TempBusinessChartBuffer: Record "Business Chart Buffer" temporary)
    var
        ComplianceArchive: Record "Compliance Overview Archive";
        CategoryCount: Dictionary of [Text, Integer];
        CategoryList: List of [Text];
        CategoryName: Text;
        Count: Integer;
        i: Integer;
        SelectedChartType: Enum "Business Chart Type";
    begin
        SelectedChartType := GetChartType();

        // Apply date filters
        ComplianceArchive.SetFilter("Filing Due Date", '%1..%2', DateFromFilter, DateToFilter);

        if ComplianceArchive.FindSet() then
            repeat
                CategoryName := Format(ComplianceArchive."Compliance Category");

                if CategoryCount.ContainsKey(CategoryName) then
                    CategoryCount.Set(CategoryName, CategoryCount.Get(CategoryName) + 1)
                else
                    CategoryCount.Add(CategoryName, 1);
            until ComplianceArchive.Next() = 0;

        TempBusinessChartBuffer.Initialize();
        TempBusinessChartBuffer."Chart Type" := SelectedChartType;
        TempBusinessChartBuffer.SetXAxis('Category', TempBusinessChartBuffer."Data Type"::String);
        TempBusinessChartBuffer.AddMeasure('Count', 1, TempBusinessChartBuffer."Data Type"::Integer, SelectedChartType);

        CategoryList := CategoryCount.Keys();
        for i := 1 to CategoryList.Count() do begin
            CategoryName := CategoryList.Get(i);
            Count := CategoryCount.Get(CategoryName);
            TempBusinessChartBuffer.AddColumn(CategoryName);
            TempBusinessChartBuffer.SetValue('Count', i - 1, Count);
        end;
    end;

    local procedure LoadComplianceByCurrentStatus(var TempBusinessChartBuffer: Record "Business Chart Buffer" temporary)
    var
        ComplianceArchive: Record "Compliance Overview Archive";
        StatusCount: Dictionary of [Text, Integer];
        StatusList: List of [Text];
        StatusName: Text;
        Count: Integer;
        i: Integer;
    begin
        // Apply date filters
        ComplianceArchive.SetFilter("Filing Due Date", '%1..%2', DateFromFilter, DateToFilter);

        if ComplianceArchive.FindSet() then
            repeat
                StatusName := Format(ComplianceArchive."Current Status");

                if StatusCount.ContainsKey(StatusName) then
                    StatusCount.Set(StatusName, StatusCount.Get(StatusName) + 1)
                else
                    StatusCount.Add(StatusName, 1);
            until ComplianceArchive.Next() = 0;

        TempBusinessChartBuffer.Initialize();
        TempBusinessChartBuffer."Chart Type" := GetChartType();
        TempBusinessChartBuffer.SetXAxis('Status', TempBusinessChartBuffer."Data Type"::String);
        TempBusinessChartBuffer.AddMeasure('Count', 1, TempBusinessChartBuffer."Data Type"::Integer, GetChartType());

        StatusList := StatusCount.Keys();
        for i := 1 to StatusList.Count() do begin
            StatusName := StatusList.Get(i);
            Count := StatusCount.Get(StatusName);
            TempBusinessChartBuffer.AddColumn(StatusName);
            TempBusinessChartBuffer.SetValue('Count', i - 1, Count);
        end;
    end;

    local procedure MinValue(Value1: Integer; Value2: Integer): Integer
    begin
        if Value1 < Value2 then
            exit(Value1)
        else
            exit(Value2);
    end;
}