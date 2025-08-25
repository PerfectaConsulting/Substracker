page 70157 "Subscription Chart"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Subscription Dashboard';

    layout
    {
        area(Content)
        {
            // ===================== KPIs =====================
            group(KPIGroup)
            {
                Caption = 'Key Performance Indicators';

                field(TotalSubs; TotalSubscriptionCount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Subscriptions';
                    Editable = false;
                    StyleExpr = 'Strong';
                }
                field(ActiveSubs; ActiveSubscriptionCount)
                {
                    ApplicationArea = All;
                    Caption = 'Active Subscriptions';
                    Editable = false;
                    StyleExpr = 'Strong';
                }
                field(MonthlySpend; MonthlySpendText)
                {
                    ApplicationArea = All;
                    Caption = 'Monthly Spend (MRR)';
                    Editable = false;
                }
                field(YearlySpend; YearlySpendText)
                {
                    ApplicationArea = All;
                    Caption = 'Yearly Spend (ARR)';
                    Editable = false;
                }
                field(UpcomingRenewals; UpcomingRenewalsCount)
                {
                    ApplicationArea = All;
                    Caption = 'Upcoming Renewals (Next 30d)';
                    Editable = false;
                }
                field(LastUpdated; LastUpdatedText)
                {
                    ApplicationArea = All;
                    Caption = 'Last Updated';
                    Editable = false;
                    StyleExpr = 'Subordinate';
                }
            }

            // ===================== Filters =====================
            group(FilterGroup)
            {
                Caption = 'Filters & Options';

                field(DateFrom; DateFromFilter)
                {
                    ApplicationArea = All;
                    Caption = 'From Date';
                    trigger OnValidate()
                    begin
                        RefreshAllData();
                    end;
                }
                field(DateTo; DateToFilter)
                {
                    ApplicationArea = All;
                    Caption = 'To Date';
                    trigger OnValidate()
                    begin
                        RefreshAllData();
                    end;
                }
                field(Category; CategoryFilterCode)
                {
                    ApplicationArea = All;
                    Caption = 'Category';
                    TableRelation = "Subscription Category".Code;
                    trigger OnValidate()
                    begin
                        RefreshAllData();
                    end;
                }
                field(ActiveOnlyField; ActiveOnly)
                {
                    ApplicationArea = All;
                    Caption = 'Active Only';
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
                    trigger OnValidate()
                    begin
                        RefreshAllCharts();
                    end;
                }
            }

            // ===================== Charts =====================
            group(ChartsBlock)
            {
                Caption = 'Charts Overview';

                group(MRRGroup)
                {
                    Caption = 'Spending Trend (MRR by Month)';

                    usercontrol(MRRChart; BusinessChart)
                    {
                        ApplicationArea = All;
                        trigger AddInReady()
                        begin
                            InitializeMRRChart();
                        end;
                    }
                }

                group(StatusGroup)
                {
                    Caption = 'Status Overview (Count)';

                    usercontrol(StatusChart; BusinessChart)
                    {
                        ApplicationArea = All;
                        trigger AddInReady()
                        begin
                            InitializeStatusChart();
                        end;
                    }
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
                trigger OnAction()
                begin
                    RefreshAllData();
                end;
            }

            action(ManageSubscriptions)
            {
                ApplicationArea = All;
                Caption = 'Manage Subscriptions';
                Image = Setup;
                trigger OnAction()
                begin
                    PAGE.Run(PAGE::"Manage Subscriptions");
                end;
            }

            action(OpenActiveSubs)
            {
                ApplicationArea = All;
                Caption = 'Active Subscriptions';
                Image = List;
                trigger OnAction()
                begin
                    PAGE.Run(PAGE::"Active Subscriptions");
                end;
            }
        }
    }

    // ===================== Variables =====================
    var
        // Filters/options
        DateFromFilter: Date;
        DateToFilter: Date;
        CategoryFilterCode: Code[20];
        ActiveOnly: Boolean;
        ChartTypeOption: Option "Pie Chart","Doughnut Chart","Column Chart","Line Chart","Area Chart","Point Chart";

        // KPIs
        TotalSubscriptionCount: Integer;
        ActiveSubscriptionCount: Integer;
        MonthlySpendText: Text;
        YearlySpendText: Text;
        UpcomingRenewalsCount: Integer;
        LastUpdatedText: Text;

        // helpers
        LCYCode: Code[10];

    // ===================== Triggers =====================
    trigger OnOpenPage()
    begin
        DateToFilter := Today();
        DateFromFilter := CalcDate('-12M', Today());
        ActiveOnly := true;
        ChartTypeOption := ChartTypeOption::"Line Chart";
        RefreshAllData();
    end;

    // ===================== High-level refresh =====================
    local procedure RefreshAllData()
    begin
        CalculateKPIs();
        RefreshAllCharts();
        CurrPage.Update(false);
    end;

    local procedure RefreshAllCharts()
    begin
        InitializeMRRChart();
        InitializeStatusChart();
    end;

    // ===================== KPIs =====================
    local procedure CalculateKPIs()
    var
        Sub: Record "Subscription";
        GLSetup: Record "General Ledger Setup";
        MRR: Decimal;
        ARR: Decimal;
        AmtLCY: Decimal;
        CntTotal: Integer;
        CntActive: Integer;
        Renewals30: Integer;
        InWindow: Boolean;
    begin
        if GLSetup.Get() then
            LCYCode := GLSetup."LCY Code"
        else
            Clear(LCYCode);

        MRR := 0;
        ARR := 0;
        CntTotal := 0;
        CntActive := 0;
        Renewals30 := 0;

        Sub.Reset();
        if CategoryFilterCode <> '' then
            Sub.SetRange("Category Code", CategoryFilterCode);

        if Sub.FindSet() then
            repeat
                // headline counters (by category only)
                CntTotal += 1;
                if Sub.Status = Sub.Status::Active then
                    CntActive += 1;

                // active-only filter for contribution
                if ActiveOnly and (Sub.Status <> Sub.Status::Active) then
                    continue;

                // only if subscription period intersects window
                InWindow := PeriodIntersects(DateFromFilter, DateToFilter, Sub."Start Date", Sub."End Date");
                if not InWindow then
                    continue;

                // amount to use: LCY then fallback to Amount
                AmtLCY := Sub."Amount in LCY";
                if AmtLCY = 0 then
                    AmtLCY := Sub.Amount;

                // normalize to monthly
                MRR += NormalizeToMonthly(AmtLCY, Sub."Billing Cycle");

                // upcoming renewals next 30 days
                if (Sub."End Date" <> 0D) and (Sub."End Date" >= Today()) and (Sub."End Date" <= CalcDate('+30D', Today())) then
                    Renewals30 += 1;
            until Sub.Next() = 0;

        ARR := MRR * 12;

        TotalSubscriptionCount := CntTotal;
        ActiveSubscriptionCount := CntActive;
        MonthlySpendText := FormatLCY(MRR, LCYCode);
        YearlySpendText := FormatLCY(ARR, LCYCode);
        UpcomingRenewalsCount := Renewals30;
        LastUpdatedText := Format(CurrentDateTime(), 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>');
    end;

    // ===================== Charts =====================
    local procedure InitializeMRRChart()
    var
        Buf: Record "Business Chart Buffer" temporary;
    begin
        LoadMRRByMonth(Buf);
        Buf.UpdateChart(CurrPage.MRRChart);
    end;

    local procedure InitializeStatusChart()
    var
        Buf: Record "Business Chart Buffer" temporary;
    begin
        LoadStatusOverview(Buf);
        Buf.UpdateChart(CurrPage.StatusChart);
    end;

    local procedure LoadMRRByMonth(var Buf: Record "Business Chart Buffer" temporary)
    var
        Sub: Record "Subscription";
        Months: List of [Text];
        Totals: Dictionary of [Text, Decimal];
        mStart: Date;
        mWindowEnd: Date;
        m: Date;
        label: Text;
        AmtLCY: Decimal;
        monthly: Decimal;
        SelectedType: Enum "Business Chart Type";
        i: Integer;
        spanStart: Date;
        spanEnd: Date;
    begin
        // prepare month labels in window
        mStart := MakeMonthStart(DateFromFilter);
        mWindowEnd := MakeMonthStart(DateToFilter);

        Clear(Months);
        Clear(Totals);

        m := mStart;
        while m <= mWindowEnd do begin
            label := MonthKey(m);
            Months.Add(label);
            Totals.Add(label, 0);
            m := CalcDate('+1M', m);
        end;

        // sum contributions
        Sub.Reset();
        if CategoryFilterCode <> '' then
            Sub.SetRange("Category Code", CategoryFilterCode);

        if Sub.FindSet() then
            repeat
                if ActiveOnly and (Sub.Status <> Sub.Status::Active) then
                    continue;

                // effective span within the window
                spanStart := MakeMonthStart(ChooseNonZero(Sub."Start Date", mStart));
                spanEnd   := MakeMonthStart(ChooseNonZero(Sub."End Date", DateToFilter));
                if spanEnd = 0D then
                    spanEnd := mWindowEnd;

                if spanStart > mWindowEnd then
                    continue;
                if spanEnd < mStart then
                    continue;

                // clamp to window
                if spanStart < mStart then
                    spanStart := mStart;
                if spanEnd > mWindowEnd then
                    spanEnd := mWindowEnd;

                // amount to use
                AmtLCY := Sub."Amount in LCY";
                if AmtLCY = 0 then
                    AmtLCY := Sub.Amount;

                monthly := NormalizeToMonthly(AmtLCY, Sub."Billing Cycle");

                // walk months and add monthly value
                m := spanStart;
                while m <= spanEnd do begin
                    label := MonthKey(m);
                    if Totals.ContainsKey(label) then
                        Totals.Set(label, Totals.Get(label) + monthly);
                    m := CalcDate('+1M', m);
                end;
            until Sub.Next() = 0;

        // build chart
        SelectedType := GetChartType();
        Buf.Initialize();
        Buf."Chart Type" := SelectedType;
        Buf.SetXAxis('Month', Buf."Data Type"::String);
        Buf.AddMeasure('MRR', 1, Buf."Data Type"::Decimal, SelectedType);

        for i := 1 to Months.Count() do begin
            label := Months.Get(i);
            Buf.AddColumn(label);
            Buf.SetValue('MRR', i - 1, Round(Totals.Get(label), 0.01, '='));
        end;
    end;

    local procedure LoadStatusOverview(var Buf: Record "Business Chart Buffer" temporary)
    var
        Sub: Record "Subscription";
        StatusCount: Dictionary of [Text, Integer];
        StatusList: List of [Text];
        s: Text;
        i: Integer;
        SelectedType: Enum "Business Chart Type";
        InWindow: Boolean;
    begin
        Clear(StatusCount);
        Clear(StatusList);

        Sub.Reset();
        if CategoryFilterCode <> '' then
            Sub.SetRange("Category Code", CategoryFilterCode);

        if Sub.FindSet() then
            repeat
                if ActiveOnly and (Sub.Status <> Sub.Status::Active) then
                    continue;

                InWindow := PeriodIntersects(DateFromFilter, DateToFilter, Sub."Start Date", Sub."End Date");
                if not InWindow then
                    continue;

                s := Format(Sub.Status);
                if StatusCount.ContainsKey(s) then
                    StatusCount.Set(s, StatusCount.Get(s) + 1)
                else begin
                    StatusCount.Add(s, 1);
                    StatusList.Add(s);
                end;
            until Sub.Next() = 0;

        SelectedType := GetChartType();
        Buf.Initialize();
        Buf."Chart Type" := SelectedType;
        Buf.SetXAxis('Status', Buf."Data Type"::String);
        Buf.AddMeasure('Count', 1, Buf."Data Type"::Integer, SelectedType);

        for i := 1 to StatusList.Count() do begin
            s := StatusList.Get(i);
            Buf.AddColumn(s);
            Buf.SetValue('Count', i - 1, StatusCount.Get(s));
        end;
    end;

    // ===================== Helpers =====================
    local procedure PeriodIntersects(FromD: Date; ToD: Date; StartD: Date; EndD: Date): Boolean
    begin
        if StartD = 0D then
            StartD := DMY2DATE(1, 1, 1900);
        if EndD = 0D then
            EndD := DMY2DATE(31, 12, 9999);
        exit((StartD <= ToD) and (EndD >= FromD));
    end;

    local procedure NormalizeToMonthly(Amt: Decimal; Cycle: Enum "Billing Cycle"): Decimal
    begin
        case Cycle of
            Cycle::Weekly:    exit(Amt * 52 / 12);
            Cycle::Monthly:   exit(Amt);
            Cycle::Quarterly: exit(Amt / 3);
            Cycle::Yearly:    exit(Amt / 12);
            else              exit(Amt);
        end;
    end;

    local procedure FormatLCY(Value: Decimal; Code: Code[10]): Text
    begin
        if Code <> '' then
            exit(Format(Value, 0, '<Precision,2:2><Standard Format,0>') + ' ' + Code)
        else
            exit(Format(Value, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    local procedure GetChartType(): Enum "Business Chart Type"
    var
        B: Record "Business Chart Buffer" temporary;
    begin
        case ChartTypeOption of
            ChartTypeOption::"Pie Chart":      exit(B."Chart Type"::Pie);
            ChartTypeOption::"Doughnut Chart": exit(B."Chart Type"::Doughnut);
            ChartTypeOption::"Column Chart":   exit(B."Chart Type"::Column);
            ChartTypeOption::"Line Chart":     exit(B."Chart Type"::Line);
            ChartTypeOption::"Area Chart":     exit(B."Chart Type"::Area);
            ChartTypeOption::"Point Chart":    exit(B."Chart Type"::Point);
            else                               exit(B."Chart Type"::Column);
        end;
    end;

    local procedure MakeMonthStart(D: Date): Date
    begin
        if D = 0D then
            exit(0D);
        exit(DMY2DATE(1, Date2DMY(D, 2), Date2DMY(D, 3)));
    end;

    local procedure MonthKey(D: Date): Text
    begin
        exit(Format(D, 0, '<Month Text,3> <Year4>'));
    end;

    local procedure ChooseNonZero(Value: Date; Fallback: Date): Date
    begin
        if Value = 0D then
            exit(Fallback)
        else
            exit(Value);
    end;
}



// page 70157 "Subscription Chart"
// {
//     PageType = Card;
//     ApplicationArea = All;
//     UsageCategory = ReportsAndAnalysis;
//     Caption = 'Subscription Dashboard';

//     layout
//     {
//         area(Content)
//         {
//             // ======= KPI STRIP =======
//             group(SubscriptionKPIs)
//             {
//                 Caption = 'Key Performance Indicators';

//                 field(TotalSubscriptions; TotalSubCount)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Total Subscriptions';
//                     StyleExpr = 'Strong';
//                     Editable = false;
//                     ToolTip = 'Total number of subscriptions (respects Category filter).';
//                 }
//                 field(ActiveSubscriptions; ActiveSubCount)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Active Subscriptions';
//                     Editable = false;
//                     ToolTip = 'Number of active subscriptions (respects filters).';
//                 }
//                 field(MonthlySpend; MonthlySpendText)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Monthly Spend (MRR)';
//                     StyleExpr = 'Strong';
//                     Editable = false;
//                     ToolTip = 'Normalized monthly recurring spend at the end of the selected date range.';
//                 }
//                 field(YearlySpend; YearlySpendText)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Yearly Spend (ARR)';
//                     Editable = false;
//                     ToolTip = 'Approx. annual recurring spend (12 × MRR).';
//                 }
//                 field(UpcomingRenewals; UpcomingRenewalsText)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Upcoming Renewals (Next 30 Days)';
//                     Editable = false;
//                     ToolTip = 'Subscriptions with End Date in the next 30 days (from To Date).';
//                 }
//                 field(LastUpdated; LastUpdateText)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Last Updated';
//                     StyleExpr = 'Subordinate';
//                     Editable = false;
//                 }
//             }

//             // ======= FILTERS =======
//             group(FilterOptions)
//             {
//                 Caption = 'Filters & Options';

//                 field(DateFromFilter; DateFromFilter)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'From Date';
//                     ToolTip = 'Start of analysis range (used by trend series & some KPIs).';
//                     trigger OnValidate()
//                     begin
//                         RefreshAllData();
//                     end;
//                 }
//                 field(DateToFilter; DateToFilter)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'To Date';
//                     ToolTip = 'End of analysis range (used by trend series & some KPIs).';
//                     trigger OnValidate()
//                     begin
//                         RefreshAllData();
//                     end;
//                 }
//                 field(CategoryFilter; CategoryFilter)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Category';
//                     ToolTip = 'Filter by subscription category.';
//                     TableRelation = "Subscription Category".Code;
//                     trigger OnValidate()
//                     begin
//                         RefreshAllData();
//                     end;
//                 }
//                 field(ActiveOnlyOption; ActiveOnlyOption)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Active Only';
//                     ToolTip = 'Limit all charts and KPIs to active subscriptions only.';
//                     trigger OnValidate()
//                     begin
//                         RefreshAllData();
//                     end;
//                 }
//                 field(ChartTypeField; ChartTypeOption)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Chart Type';
//                     OptionCaption = 'Pie Chart,Doughnut Chart,Column Chart,Line Chart,Area Chart,Point Chart';
//                     ToolTip = 'Default visualization for the charts below.';
//                     trigger OnValidate()
//                     begin
//                         RefreshAllCharts();
//                     end;
//                 }
//             }

//             // ======= CHARTS =======
//             group(ChartsContainer)
//             {
//                 Caption = 'Charts Overview';

//                 group(TrendChartGroup)
//                 {
//                     Caption = 'Spending Trend (MRR by Month)';

//                     usercontrol(TrendChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
//                     {
//                         ApplicationArea = All;

//                         trigger AddInReady()
//                         begin
//                             InitializeTrendChart();
//                         end;

//                         trigger DataPointClicked(Point: JsonObject)
//                         begin
//                             // No-op for now (could drill to list filtered by month)
//                         end;
//                     }
//                 }

//                 group(CategoryChartGroup)
//                 {
//                     Caption = 'Category Breakdown (MRR at End of Range)';

//                     usercontrol(CategoryChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
//                     {
//                         ApplicationArea = All;

//                         trigger AddInReady()
//                         begin
//                             InitializeCategoryChart();
//                         end;

//                         trigger DataPointClicked(Point: JsonObject)
//                         var
//                             Tok: JsonToken;
//                             Cat: Code[20];
//                         begin
//                             if Point.Get('AxisLabel', Tok) then begin
//                                 Cat := Tok.AsValue().AsText();
//                                 if Cat <> '' then begin
//                                     CategoryFilter := Cat;
//                                     RefreshAllData();
//                                 end;
//                             end;
//                         end;
//                     }
//                 }

//                 group(StatusChartGroup)
//                 {
//                     Caption = 'Status Overview (Count)';

//                     usercontrol(StatusChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
//                     {
//                         ApplicationArea = All;

//                         trigger AddInReady()
//                         begin
//                             InitializeStatusChart();
//                         end;

//                         trigger DataPointClicked(Point: JsonObject)
//                         var
//                             Tok: JsonToken;
//                             StatusName: Text;
//                         begin
//                             if Point.Get('AxisLabel', Tok) then begin
//                                 StatusName := Tok.AsValue().AsText();
//                                 Message('Status: %1', StatusName);
//                             end;
//                         end;
//                     }
//                 }

//                 group(VendorChartGroup)
//                 {
//                     Caption = 'Top Vendors by MRR (End of Range)';

//                     usercontrol(VendorChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
//                     {
//                         ApplicationArea = All;

//                         trigger AddInReady()
//                         begin
//                             InitializeVendorChart();
//                         end;

//                         trigger DataPointClicked(Point: JsonObject)
//                         var
//                             Tok: JsonToken;
//                             Vend: Text[100];
//                         begin
//                             if Point.Get('AxisLabel', Tok) then begin
//                                 Vend := Tok.AsValue().AsText();
//                                 Message('Vendor: %1', Vend);
//                             end;
//                         end;
//                     }
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(RefreshData)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Refresh All Data';
//                 Image = Refresh;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 PromotedIsBig = true;
//                 trigger OnAction()
//                 begin
//                     RefreshAllData();
//                     Message('Dashboard data has been refreshed.');
//                 end;
//             }

//             action(OpenList)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Manage Subscriptions';
//                 Image = List;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 trigger OnAction()
//                 begin
//                     PAGE.Run(PAGE::"Manage Subscriptions"); // use your existing list page
//                 end;
//             }

//             action(OpenActive)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Active Subscriptions';
//                 Image = ViewDetails;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 trigger OnAction()
//                 begin
//                     PAGE.Run(PAGE::"Active Subscriptions"); // your existing page
//                 end;
//             }
//         }
//     }

//     var
//         // Filters/Options
//         DateFromFilter: Date;
//         DateToFilter: Date;
//         CategoryFilter: Code[20];
//         ActiveOnlyOption: Boolean;
//         ChartTypeOption: Option "Pie Chart","Doughnut Chart","Column Chart","Line Chart","Area Chart","Point Chart";

//         // KPIs
//         TotalSubCount: Integer;
//         ActiveSubCount: Integer;
//         MonthlySpendText: Text;
//         YearlySpendText: Text;
//         UpcomingRenewalsText: Text;
//         LastUpdateText: Text;

//         // Internal
//         LCYCode: Code[10];

//     trigger OnOpenPage()
//     var
//         GLSetup: Record "General Ledger Setup";
//     begin
//         // Defaults
//         ChartTypeOption := ChartTypeOption::"Line Chart";
//         ActiveOnlyOption := true;
//         DateToFilter := Today();
//         DateFromFilter := CalcDate('-12M', Today());

//         if GLSetup.Get() then
//             LCYCode := GLSetup."LCY Code";

//         RefreshAllData();
//     end;

//     // ================== DATA REFRESH ==================
//     local procedure RefreshAllData()
//     begin
//         CalculateKPIs();
//         RefreshAllCharts();
//         CurrPage.Update(false);
//     end;

//     local procedure RefreshAllCharts()
//     begin
//         InitializeTrendChart();
//         InitializeCategoryChart();
//         InitializeStatusChart();
//         InitializeVendorChart();
//     end;

//     // ================== KPI CALCULATION ==================
//     local procedure CalculateKPIs()
//     var
//         Sub: Record "Subscription";
//         FirstDay: Date;
//         LastDay: Date;
//         MRR: Decimal;
//         ARR: Decimal;
//         RenewalsNext30: Integer;
//     begin
//         // Counts
//         Sub.Reset();
//         ApplyCommonFilters(Sub, false);
//         TotalSubCount := Sub.Count();

//         Sub.Reset();
//         ApplyCommonFilters(Sub, true); // active only
//         ActiveSubCount := Sub.Count();

//         // MRR/ARR as-of the end of range (month containing DateToFilter)
//         FirstDay := DMY2DATE(1, Date2DMY(DateToFilter, 2), Date2DMY(DateToFilter, 3));
//         LastDay := CalcDate('<CM>', FirstDay) - 1;

//         MRR := CalcMRRForMonth(FirstDay, LastDay);
//         ARR := MRR * 12;

//         MonthlySpendText := FormatAmount(MRR);
//         YearlySpendText := FormatAmount(ARR);

//         // Upcoming renewals: End Date between ToDate and +30 days
//         Sub.Reset();
//         ApplyCommonFilters(Sub, ActiveOnlyOption);
//         Sub.SetRange("End Date", DateToFilter, CalcDate('+30D', DateToFilter));
//         RenewalsNext30 := Sub.Count();
//         UpcomingRenewalsText := Format(RenewalsNext30);

//         LastUpdateText := Format(CurrentDateTime(), 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>');
//     end;

//     // ================== CHART INITIALIZERS ==================
//     local procedure InitializeTrendChart()
//     var
//         B: Record "Business Chart Buffer" temporary;
//     begin
//         LoadMRRTrend(B);
//         B.Update(CurrPage.TrendChart);
//     end;

//     local procedure InitializeCategoryChart()
//     var
//         B: Record "Business Chart Buffer" temporary;
//     begin
//         LoadMRRByCategory(B);
//         B.Update(CurrPage.CategoryChart);
//     end;

//     local procedure InitializeStatusChart()
//     var
//         B: Record "Business Chart Buffer" temporary;
//     begin
//         LoadCountByStatus(B);
//         B.Update(CurrPage.StatusChart);
//     end;

//     local procedure InitializeVendorChart()
//     var
//         B: Record "Business Chart Buffer" temporary;
//     begin
//         LoadTopVendorsByMRR(B);
//         B.Update(CurrPage.VendorChart);
//     end;

//     // ================== DATA LOADERS ==================
//     local procedure LoadMRRTrend(var B: Record "Business Chart Buffer" temporary)
//     var
//         MonthStart: Date;
//         MonthEnd: Date;
//         i: Integer;
//         LabelTxt: Text;
//         Val: Decimal;
//         ChartType: Enum "Business Chart Type";
//     begin
//         ChartType := GetChartType();
//         B.Initialize();
//         B."Chart Type" := ChartType;
//         B.SetXAxis('Month', B."Data Type"::String);
//         B.AddMeasure('MRR', 1, B."Data Type"::Decimal, ChartType);

//         // Start at the first day of the From month
//         MonthStart := DMY2DATE(1, Date2DMY(DateFromFilter, 2), Date2DMY(DateFromFilter, 3));
//         repeat
//             MonthEnd := CalcDate('<CM>', MonthStart) - 1;

//             Val := CalcMRRForMonth(MonthStart, MonthEnd);
//             LabelTxt := Format(MonthStart, 0, '<Month Text,3> <Year4>');

//             B.AddColumn(LabelTxt);
//             i += 1;
//             B.SetValue('MRR', i - 1, Round(Val, 0.01, '='));

//             MonthStart := CalcDate('<+1M>', MonthStart);
//         until MonthStart > DateToFilter;
//     end;

//     local procedure LoadMRRByCategory(var B: Record "Business Chart Buffer" temporary)
//     var
//         Sub: Record "Subscription";
//         CatMap: Dictionary of [Code[20], Decimal];
//         CatList: List of [Code[20]];
//         Cat: Code[20];
//         Val: Decimal;
//         i: Integer;
//         ChartType: Enum "Business Chart Type";
//     begin
//         ChartType := GetChartType();
//         B.Initialize();
//         B."Chart Type" := ChartType;
//         B.SetXAxis('Category', B."Data Type"::String);
//         B.AddMeasure('MRR', 1, B."Data Type"::Decimal, ChartType);

//         Sub.Reset();
//         ApplyCommonFilters(Sub, ActiveOnlyOption);

//         // MRR as-of end of range, grouped by Category
//         if Sub.FindSet() then
//             repeat
//                 if IsActiveBetween(Sub, DateToFilter, DateToFilter) then begin
//                     Val := GetMonthlyContribution(Sub);
//                     if CatMap.ContainsKey(Sub."Category Code") then
//                         CatMap.Set(Sub."Category Code", CatMap.Get(Sub."Category Code") + Val)
//                     else
//                         CatMap.Add(Sub."Category Code", Val);
//                 end;
//             until Sub.Next() = 0;

//         CatList := CatMap.Keys();
//         for i := 1 to CatList.Count() do begin
//             Cat := CatList.Get(i);
//             B.AddColumn(Cat); // show code; swap to description if you prefer Sub."Category Description"
//             B.SetValue('MRR', i - 1, Round(CatMap.Get(Cat), 0.01, '='));
//         end;
//     end;

//     local procedure LoadCountByStatus(var B: Record "Business Chart Buffer" temporary)
//     var
//         Sub: Record "Subscription";
//         CActive: Integer;
//         CInactive: Integer;
//         CCancelled: Integer;
//         CExpired: Integer;
//         ChartType: Enum "Business Chart Type";
//     begin
//         ChartType := GetChartType();
//         B.Initialize();
//         B."Chart Type" := ChartType;
//         B.SetXAxis('Status', B."Data Type"::String);
//         B.AddMeasure('Count', 1, B."Data Type"::Integer, ChartType);

//         Sub.Reset();
//         ApplyCommonFilters(Sub, false);

//         if Sub.FindSet() then
//             repeat
//                 case Sub.Status of
//                     Sub.Status::Active:    CActive += 1;
//                     Sub.Status::Inactive:  CInactive += 1;
//                     Sub.Status::Cancelled: CCancelled += 1;
//                     Sub.Status::Expired:   CExpired += 1;
//                 end;
//             until Sub.Next() = 0;

//         B.AddColumn('Active');    B.SetValue('Count', 0, CActive);
//         B.AddColumn('Inactive');  B.SetValue('Count', 1, CInactive);
//         B.AddColumn('Cancelled'); B.SetValue('Count', 2, CCancelled);
//         B.AddColumn('Expired');   B.SetValue('Count', 3, CExpired);
//     end;

//     local procedure LoadTopVendorsByMRR(var B: Record "Business Chart Buffer" temporary)
//     var
//         Sub: Record "Subscription";
//         VendMap: Dictionary of [Text[100], Decimal];
//         VendList: List of [Text[100]];
//         Vend: Text[100];
//         Val: Decimal;
//         i: Integer;
//         ChartType: Enum "Business Chart Type";
//         TopN: Integer;
//     begin
//         ChartType := GetChartType();
//         B.Initialize();
//         B."Chart Type" := ChartType;
//         B.SetXAxis('Vendor', B."Data Type"::String);
//         B.AddMeasure('MRR', 1, B."Data Type"::Decimal, ChartType);

//         Sub.Reset();
//         ApplyCommonFilters(Sub, ActiveOnlyOption);

//         if Sub.FindSet() then
//             repeat
//                 if IsActiveBetween(Sub, DateToFilter, DateToFilter) then begin
//                     Val := GetMonthlyContribution(Sub);
//                     if VendMap.ContainsKey(Sub.Vendor) then
//                         VendMap.Set(Sub.Vendor, VendMap.Get(Sub.Vendor) + Val)
//                     else
//                         VendMap.Add(Sub.Vendor, Val);
//                 end;
//             until Sub.Next() = 0;

//         // Take Top 10 by value
//         VendList := VendMap.Keys();
//         // (List has no sort; in production you could transfer to temp table & sort; here we just take first 10)
//         TopN := Minimum(VendList.Count(), 10);
//         for i := 1 to TopN do begin
//             Vend := VendList.Get(i);
//             B.AddColumn(Vend);
//             B.SetValue('MRR', i - 1, Round(VendMap.Get(Vend), 0.01, '='));
//         end;
//     end;

//     // ================== HELPERS ==================
//     local procedure GetChartType(): Enum "Business Chart Type"
//     var
//         Tmp: Record "Business Chart Buffer" temporary;
//     begin
//         case ChartTypeOption of
//             ChartTypeOption::"Pie Chart":      exit(Tmp."Chart Type"::Pie);
//             ChartTypeOption::"Doughnut Chart": exit(Tmp."Chart Type"::Doughnut);
//             ChartTypeOption::"Column Chart":   exit(Tmp."Chart Type"::Column);
//             ChartTypeOption::"Line Chart":     exit(Tmp."Chart Type"::Line);
//             ChartTypeOption::"Area Chart":     exit(Tmp."Chart Type"::Area);
//             ChartTypeOption::"Point Chart":    exit(Tmp."Chart Type"::Point);
//         end;
//     end;

//     local procedure ApplyCommonFilters(var Sub: Record "Subscription"; EnforceActive: Boolean)
//     begin
//         // Category
//         if CategoryFilter <> '' then
//             Sub.SetRange("Category Code", CategoryFilter);

//         // Active only toggle or enforced
//         if ActiveOnlyOption or EnforceActive then
//             Sub.SetRange(Status, Sub.Status::Active);
//     end;

//     local procedure GetMonthlyContribution(Sub: Record "Subscription"): Decimal
//     var
//         v: Decimal;
//     begin
//         case Sub."Billing Cycle" of
//             Sub."Billing Cycle"::Weekly:    v := Sub."Amount in LCY" * 52 / 12;
//             Sub."Billing Cycle"::Monthly:   v := Sub."Amount in LCY";
//             Sub."Billing Cycle"::Quarterly: v := Sub."Amount in LCY" / 3;
//             Sub."Billing Cycle"::Yearly:    v := Sub."Amount in LCY" / 12;
//             else                            v := Sub."Amount in LCY";
//         end;
//         exit(v);
//     end;

//     local procedure IsActiveBetween(Sub: Record "Subscription"; RangeStart: Date; RangeEnd: Date): Boolean
//     var
//         StartOk: Boolean;
//         EndOk: Boolean;
//     begin
//         // A subscription contributes in a month if it overlaps the month window
//         StartOk := (Sub."Start Date" = 0D) or (Sub."Start Date" <= RangeEnd);
//         EndOk := (Sub."End Date" = 0D) or (Sub."End Date" >= RangeStart);
//         exit(StartOk and EndOk);
//     end;

//     local procedure CalcMRRForMonth(MStart: Date; MEnd: Date): Decimal
//     var
//         Sub: Record "Subscription";
//         Sum: Decimal;
//     begin
//         Sum := 0;
//         Sub.Reset();
//         ApplyCommonFilters(Sub, ActiveOnlyOption);
//         if Sub.FindSet() then
//             repeat
//                 if IsActiveBetween(Sub, MStart, MEnd) then
//                     Sum += GetMonthlyContribution(Sub);
//             until Sub.Next() = 0;

//         exit(Sum);
//     end;

//     local procedure FormatAmount(Amount: Decimal): Text
//     begin
//         if LCYCode <> '' then
//             exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>') + ' ' + LCYCode);
//         exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>'));
//     end;

//     local procedure Minimum(A: Integer; B: Integer): Integer
//     begin
//         if A < B then
//             exit(A)
//         else
//             exit(B);
//     end;
// }
