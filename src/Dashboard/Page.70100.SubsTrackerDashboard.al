page 70100 "SubsTracker Dashboard"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'SubsTracker Dashboard';

    layout
    {
        area(Content)
        {
            usercontrol(Dashboard; SubsTrackerDashboard)
            {
                ApplicationArea = All;

                trigger OnNavigationClick(PageName: Text)
                begin
                    HandleNavigation(PageName);
                end;

                trigger updateCompanyInformation(CompanyData: JsonObject)
                begin
                    UpdateCompanyInformation(CompanyData);
                end;

                trigger updateInitialSetup(SetupData: JsonObject)
                begin
                    UpdateInitialSetup(SetupData);
                end;

                trigger savePaymentMethod(PaymentData: JsonObject)
                begin
                    SavePaymentMethod(PaymentData);
                end;

                trigger getComplianceStats(FromDateTxt: Text; ToDateTxt: Text)
                begin
                    SendComplianceStatisticsWithRange(FromDateTxt, ToDateTxt);
                end;

                trigger getPaymentMethods()
                begin
                    SendPaymentMethods();
                end;

                trigger getDepartments()
                begin
                    SendDepartments();
                end;

                trigger getEmployees()
                begin
                    SendEmployees();
                end;

                trigger getSubscriptionCategories()
                begin
                    SendSubscriptionCategories();
                end;

                trigger getSubscriptionStats()
                begin
                    SendSubscriptionStatistics();
                end;
            }
        }
    }

    actions { }

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";

   local procedure HandleNavigation(PageName: Text)
var
    PM: Record "ST Payment Method";
    Dept: Record "Department Master";
    Cat: Record "Subscription Category";
    Emp: Record "Employee Ext";
    EntryNo: Integer;
    OwningSection: Text;
    NormPageName: Text;
begin
    // Normalize curly apostrophes (’) to straight (') for robust string matching
    NormPageName := ConvertStr(PageName, '’', '''');

    OwningSection := GetOwningSection(NormPageName);

    case true of
        NormPageName = 'Dashboard':
            begin
                CurrPage.Dashboard.showMainDashboard();
                SendSubscriptionStatistics();
            end;

        NormPageName = 'Initial Setup':
            LoadInitialSetup();

        // JS renders the Subscription tiles; AL just acknowledges.
        NormPageName = 'Subscription':
            ;

        // JS renders the Compliance tiles; AL just acknowledges.
        NormPageName = 'Compliance':
            ;

        NormPageName = 'Notification':
            ;

        NormPageName = 'Company Information':
            LoadCompanyInformation();

        NormPageName = 'Subscription Notifications':
            PAGE.Run(50139);

        NormPageName = 'Compliance Notifications':
            PAGE.Run(70131);

        NormPageName = 'Add Subscription':
            PAGE.Run(PAGE::"Add Subscription");

        NormPageName = 'Manage Subscriptions':
            PAGE.Run(PAGE::"Manage Subscriptions");

        NormPageName = 'Active Subscriptions':
            PAGE.Run(PAGE::"Active Subscriptions");

        NormPageName = 'Inactive Subscriptions':
            PAGE.Run(PAGE::"Inactive Subscriptions");

        NormPageName = 'Renewals This Month':
            PAGE.Run(PAGE::"Renewals This Month");

        // NormPageName = 'Setup New Compliance Item':
        //     PAGE.RunModal(PAGE::"Compliance Card");

       
 NormPageName = 'Setup New Compliance Item':
 
    begin
        
        
            Clear(NewComp);
            NewComp.Init();
            // Opening a page with an uninserted record that has an empty PK
            // usually forces Insert (New) mode on the Card page.
            PAGE.RunModal(PAGE::"Compliance Card", NewComp);
         
    end;




        NormPageName = 'Submit a Compliance':
            PAGE.Run(PAGE::"Compliance List");

        NormPageName = 'View Submitted Compliance':
            PAGE.Run(PAGE::"Compliance Archive List");

        NormPageName = 'Pending Compliance Submissions':
            PAGE.Run(PAGE::"Pending Compliance List");

        // IMPORTANT: straight apostrophe version
        NormPageName = 'This Month''s Submissions':
            PAGE.Run(PAGE::"Due This Month Compliance List");

        NormPageName = 'Open Employee Ext Setup':
            PAGE.Run(PAGE::"Employee Ext Setup");

        NormPageName = 'Open Subscription Chart':
            PAGE.Run(70157);

        NormPageName = 'Open Compliance Chart':
            PAGE.Run(PAGE::"Compliance Chart");

        NormPageName = 'Auto Create All Number Series':
            begin
                AutoCreateAllNumberSeries();
                LoadInitialSetup();
            end;

        NormPageName in ['Assign Manually', 'Open Initial Setup']:
            begin
                PAGE.RunModal(PAGE::"Initial Setup");
                LoadInitialSetup();
            end;

        NormPageName = 'Add Department':
            begin
                PAGE.RunModal(PAGE::"Department Master Card");
                SendDepartments();
            end;

        NormPageName = 'AddEmployee':
            begin
                PAGE.RunModal(PAGE::"Employee Ext Card");
                SendEmployees();
            end;

        NormPageName.StartsWith('EditEmployee:'):
            begin
                if EvaluateTextId(NormPageName, 'EditEmployee:', Emp."No.") then begin
                    if Emp.Get(Emp."No.") then
                        PAGE.RunModal(PAGE::"Employee Ext Card", Emp);
                    SendEmployees();
                end;
            end;

        NormPageName.StartsWith('EditDepartment:'):
            begin
                if EvaluateTextId(NormPageName, 'EditDepartment:', Dept.Code) then begin
                    if Dept.Get(Dept.Code) then
                        PAGE.RunModal(PAGE::"Department Master Card", Dept);
                    SendDepartments();
                end;
            end;

        NormPageName = 'Add Subscription Categories':
            begin
                PAGE.RunModal(PAGE::"Subscription Categories");
                SendSubscriptionCategories();
            end;

        NormPageName.StartsWith('EditSubscriptionCategory:'):
            begin
                if EvaluateTextId(NormPageName, 'EditSubscriptionCategory:', Cat.Code) then begin
                    if Cat.Get(Cat.Code) then
                        PAGE.RunModal(PAGE::"Subscription Categories", Cat);
                    SendSubscriptionCategories();
                end;
            end;

        NormPageName = 'Manage Payment Methods':
            begin
                PAGE.RunModal(PAGE::"ST Payment Methods");
                SendPaymentMethods();
            end;

        NormPageName.StartsWith('EditPaymentMethod:'):
            begin
                if EvaluateEntryNo(NormPageName, EntryNo) then begin
                    if PM.Get(EntryNo) then
                        PAGE.RunModal(PAGE::"ST Payment Method Card", PM);
                    SendPaymentMethods();
                end;
            end;

        else
            ;
    end;

    if OwningSection <> '' then
        CurrPage.Dashboard.setActiveNavigation(OwningSection);
end;

var
            NewComp: Record "Compliance Overview";


    local procedure GetOwningSection(PageName: Text): Text
var
    P: Text;
begin
    // Normalize curly apostrophes to straight apostrophes
    P := ConvertStr(PageName, '’', '''');

    if P in ['Dashboard', 'Open Subscription Chart'] then
        exit('Dashboard');
    if P in ['Initial Setup', 'Auto Create All Number Series', 'Assign Manually', 'Open Initial Setup', 'Manage Payment Methods'] then
        exit('Initial Setup');
    if (P = 'Company Information') or (P = 'Add Department') or (P = 'AddEmployee') or (P = 'Add Subscription Categories') or P.StartsWith('Edit') then
        exit('Company Information');
    if P in ['Compliance', 'Open Compliance Chart', 'Submit a Compliance', 'View Submitted Compliance', 'Pending Compliance Submissions', 'This Month''s Submissions', 'Setup New Compliance Item'] then
        exit('Compliance');
    if P in ['Subscription', 'Add Subscription', 'Manage Subscriptions', 'Active Subscriptions', 'Inactive Subscriptions', 'Renewals This Month'] then
        exit('Subscription');
    if P in ['Notification', 'Subscription Notifications', 'Compliance Notifications'] then
        exit('Notification');
    exit('');
end;


    local procedure EvaluateEntryNo(PageName: Text; var EntryNo: Integer): Boolean
    var
        IdText: Text;
    begin
        IdText := CopyStr(PageName, StrLen('EditPaymentMethod:') + 1);
        exit(Evaluate(EntryNo, IdText));
    end;

    local procedure EvaluateTextId(PageName: Text; Prefix: Text; var OutId: Code[20]): Boolean
    var
        Val: Text;
    begin
        Val := CopyStr(PageName, StrLen(Prefix) + 1);
        OutId := CopyStr(Val, 1, MaxStrLen(OutId));
        exit(OutId <> '');
    end;

    local procedure SendSubscriptionStatistics()
    var
        Sub: Record "Subscription";
        Stats: JsonObject;
        TotalSubs: Integer;
        ActiveSubs: Integer;
        InactiveSubs: Integer;
        RenewalsThisMonth: Integer;
        FirstDay: Date;
        LastDay: Date;
        MonthlySpendLCY: Decimal;
        YearlySpendLCY: Decimal;
        MonthlyContribution: Decimal;
    begin
        Sub.Reset();
        TotalSubs := Sub.Count;

        Sub.SetRange(Status, Sub.Status::Active);
        ActiveSubs := Sub.Count;

        Sub.Reset();
        Sub.SetRange(Status, Sub.Status::Inactive);
        InactiveSubs := Sub.Count;

        FirstDay := DMY2DATE(1, Date2DMY(Today(), 2), Date2DMY(Today(), 3));
        LastDay := CalcDate('<CM>', FirstDay) - 1;
        Sub.Reset();
        Sub.SetRange("End Date", FirstDay, LastDay);
        RenewalsThisMonth := Sub.Count;

        MonthlySpendLCY := 0;
        Sub.Reset();
        Sub.SetRange(Status, Sub.Status::Active);
        if Sub.FindSet() then
            repeat
                case Sub."Billing Cycle" of
                    Sub."Billing Cycle"::Weekly:
                        MonthlyContribution := Sub."Amount in LCY" * 52 / 12;
                    Sub."Billing Cycle"::Monthly:
                        MonthlyContribution := Sub."Amount in LCY";
                    Sub."Billing Cycle"::Quarterly:
                        MonthlyContribution := Sub."Amount in LCY" / 3;
                    Sub."Billing Cycle"::Yearly:
                        MonthlyContribution := Sub."Amount in LCY" / 12;
                    else
                        MonthlyContribution := Sub."Amount in LCY";
                end;
                MonthlySpendLCY += MonthlyContribution;
            until Sub.Next() = 0;

        YearlySpendLCY := MonthlySpendLCY * 12;
        MonthlySpendLCY := Round(MonthlySpendLCY, 0.01, '=');
        YearlySpendLCY := Round(YearlySpendLCY, 0.01, '=');

        Stats.Add('total', TotalSubs);
        Stats.Add('active', ActiveSubs);
        Stats.Add('inactive', InactiveSubs);
        Stats.Add('renewals', RenewalsThisMonth);
        Stats.Add('monthly', MonthlySpendLCY);
        Stats.Add('yearly', YearlySpendLCY);
        if GLSetup.Get() then
            Stats.Add('lcy', GLSetup."LCY Code")
        else
            Stats.Add('lcy', '');

        CurrPage.Dashboard.renderSubscriptionStatistics(Stats);
    end;

    local procedure SendComplianceStatistics()
    var
        ComplianceRec: Record "Compliance Overview";
        ArchiveRec: Record "Compliance Overview Archive";
        Stats: JsonObject;
        PendingCount: Integer;
        ActiveCount: Integer;
        FromDate: Date;
        ToDate: Date;
        SumAmt: Decimal;
        UseSift: Boolean;
    begin
        ComplianceRec.Reset();
        PendingCount := ComplianceRec.Count;

        ArchiveRec.Reset();
        ActiveCount := ArchiveRec.Count;

        FromDate := DMY2DATE(1, 1, Date2DMY(Today(), 3));
        ToDate := DMY2DATE(31, 12, Date2DMY(Today(), 3));

        ArchiveRec.Reset();
        ArchiveRec.SetRange("File Submitted", FromDate, ToDate);

        UseSift := false;
        if UseSift then begin
            ArchiveRec.CalcSums("Payable Amount");
            SumAmt := ArchiveRec."Payable Amount";
        end else begin
            SumAmt := 0;
            if ArchiveRec.FindSet() then
                repeat
                    SumAmt += ArchiveRec."Payable Amount";
                until ArchiveRec.Next() = 0;
        end;

        Stats.Add('yearly', SumAmt);
        Stats.Add('total', SumAmt);
        Stats.Add('active', ActiveCount);
        Stats.Add('pending', PendingCount);
        if GLSetup.Get() then
            Stats.Add('lcy', GLSetup."LCY Code")
        else
            Stats.Add('lcy', '');

        CurrPage.Dashboard.renderComplianceStatistics(Stats);
    end;

    local procedure SendComplianceStatisticsWithRange(FromDateTxt: Text; ToDateTxt: Text)
    var
        ComplianceRec: Record "Compliance Overview";
        ArchiveRec: Record "Compliance Overview Archive";
        Stats: JsonObject;
        PendingCount: Integer;
        ActiveCount: Integer;
        FromDate: Date;
        ToDate: Date;
        SumAmt: Decimal;
        UseSift: Boolean;
    begin
        if not ParseIsoDate(FromDateTxt, FromDate) then
            FromDate := 0D;
        if not ParseIsoDate(ToDateTxt, ToDate) then
            ToDate := 0D;

        ComplianceRec.Reset();
        PendingCount := ComplianceRec.Count;

        ArchiveRec.Reset();
        ActiveCount := ArchiveRec.Count;

        ArchiveRec.Reset();
        if (FromDate <> 0D) or (ToDate <> 0D) then
            ArchiveRec.SetRange("File Submitted", FromDate, ToDate);

        UseSift := false;
        if UseSift then begin
            ArchiveRec.CalcSums("Payable Amount");
            SumAmt := ArchiveRec."Payable Amount";
        end else begin
            SumAmt := 0;
            if ArchiveRec.FindSet() then
                repeat
                    SumAmt += ArchiveRec."Payable Amount";
                until ArchiveRec.Next() = 0;
        end;

        Stats.Add('yearly', SumAmt);
        Stats.Add('total', SumAmt);
        Stats.Add('active', ActiveCount);
        Stats.Add('pending', PendingCount);
        if GLSetup.Get() then
            Stats.Add('lcy', GLSetup."LCY Code")
        else
            Stats.Add('lcy', '');

        CurrPage.Dashboard.renderComplianceStatistics(Stats);
    end;

    local procedure SavePaymentMethod(MethodData: JsonObject)
    var
        PM: Record "ST Payment Method";
        Tok: JsonToken;
        Txt: Text;
        D: Date;
    begin
        PM.Init();

        if MethodData.Get('title', Tok) then
            PM."Title" := Tok.AsValue().AsText();

        if MethodData.Get('type', Tok) then
            case LowerCase(Tok.AsValue().AsText()) of
                'Credit Card': PM.Type := PM.Type::"Credit Card";
                'Debit Card': PM.Type := PM.Type::"Debit Card";
                'Bank Transfer': PM.Type := PM.Type::"Bank Transfer";
                'Cash': PM.Type := PM.Type::Cash;
                'Digital Wallet': PM.Type := PM.Type::"Digital Wallet";
                
            end;

        if MethodData.Get('description', Tok) then
            PM."Description" := Tok.AsValue().AsText();

        if MethodData.Get('icon', Tok) then
            PM."Icon" := Tok.AsValue().AsText();

        if MethodData.Get('managedBy', Tok) then
            PM."Managed By" := Tok.AsValue().AsText();

        if MethodData.Get('expiresAt', Tok) then begin
            Txt := Tok.AsValue().AsText();
            if (Txt <> '') and ParseIsoDate(Txt, D) then
                PM."Expires At" := D
            else
                PM."Expires At" := 0D;
        end;

        PM.Insert(true);
        SendPaymentMethods();
    end;

    local procedure SendPaymentMethods()
    var
        PM: Record "ST Payment Method";
        Arr: JsonArray;
        Obj: JsonObject;
    begin
        PM.Reset();
        if PM.FindSet() then
            repeat
                Clear(Obj);
                Obj.Add('id', PM."Entry No.");
                Obj.Add('title', PM."Title");
                Obj.Add('type', Format(PM."Type"));
                Obj.Add('description', PM."Description");
                Obj.Add('icon', PM."Icon");
                Obj.Add('managedBy', PM."Managed By");
                if PM."Expires At" <> 0D then
                    Obj.Add('expiresAt', Format(PM."Expires At"))
                else
                    Obj.Add('expiresAt', '');
                Arr.Add(Obj);
            until PM.Next() = 0;

        CurrPage.Dashboard.renderPaymentMethods(Arr);
    end;

    local procedure SendDepartments()
    var
        Dept: Record "Department Master";
        Arr: JsonArray;
        Obj: JsonObject;
    begin
        Dept.Reset();
        if Dept.FindSet() then
            repeat
                Clear(Obj);
                Obj.Add('code', Dept.Code);
                Obj.Add('name', Dept."Head of Department Name");
                Arr.Add(Obj);
            until Dept.Next() = 0;

        CurrPage.Dashboard.renderDepartments(Arr);
    end;

    local procedure SendEmployees()
    var
        Emp: Record "Employee Ext";
        Arr: JsonArray;
        Obj: JsonObject;
    begin
        Emp.Reset();
        if Emp.FindSet() then
            repeat
                Clear(Obj);
                Obj.Add('no', Emp."No.");
                Obj.Add('name', Emp."Full Name");
                Arr.Add(Obj);
            until Emp.Next() = 0;

        CurrPage.Dashboard.renderEmployees(Arr);
    end;

    local procedure SendSubscriptionCategories()
    var
        Cat: Record "Subscription Category";
        Arr: JsonArray;
        Obj: JsonObject;
    begin
        Cat.Reset();
        if Cat.FindSet() then
            repeat
                Clear(Obj);
                Obj.Add('code', Cat.Code);
                Obj.Add('name', Cat.Description);
                Arr.Add(Obj);
            until Cat.Next() = 0;

        CurrPage.Dashboard.renderSubscriptionCategories(Arr);
    end;

    local procedure LoadCompanyInformation()
    var
        CompanyData: JsonObject;
        JGeneral: JsonObject;
        JAddress: JsonObject;
        JContacts: JsonObject;
        JRegistration: JsonObject;
        JBanking: JsonObject;
        JShipping: JsonObject;
        InStr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        Base64Str: Text;
    begin
        CompanyInfo.Get();

        JGeneral.Add('name', CompanyInfo.Name);
        JGeneral.Add('name2', CompanyInfo."Name 2");
        JGeneral.Add('industrialClassification', CompanyInfo."Industrial Classification");
        JGeneral.Add('customSystemIndicatorText', CompanyInfo."Custom System Indicator Text");
        JGeneral.Add('responsibilityCenter', CompanyInfo."Responsibility Center");
        JGeneral.Add('baseCalendarCode', CompanyInfo."Base Calendar Code");

        if CompanyInfo.Picture.HasValue then begin
            CompanyInfo.CalcFields(Picture);
            CompanyInfo.Picture.CreateInStream(InStr);
            Base64Str := Base64Convert.ToBase64(InStr);
            JGeneral.Add('logo', Base64Str);
        end;

        JAddress.Add('address', CompanyInfo.Address);
        JAddress.Add('address2', CompanyInfo."Address 2");
        JAddress.Add('city', CompanyInfo.City);
        JAddress.Add('postCode', CompanyInfo."Post Code");
        JAddress.Add('county', CompanyInfo.County);
        JAddress.Add('countryRegionCode', CompanyInfo."Country/Region Code");

        JContacts.Add('phoneNo', CompanyInfo."Phone No.");
        JContacts.Add('phoneNo2', CompanyInfo."Phone No. 2");
        JContacts.Add('faxNo', CompanyInfo."Fax No.");
        JContacts.Add('eMail', CompanyInfo."E-Mail");
        JContacts.Add('contactPerson', CompanyInfo."Contact Person");

        JRegistration.Add('vatRegistrationNo', CompanyInfo."VAT Registration No.");
        JRegistration.Add('registrationNo', CompanyInfo."Registration No.");
        JRegistration.Add('customsPermitNo', CompanyInfo."Customs Permit No.");
        JRegistration.Add('customsPermitDate', Format(CompanyInfo."Customs Permit Date"));
        JRegistration.Add('eoriNumber', CompanyInfo."EORI Number");
        JRegistration.Add('gln', CompanyInfo.GLN);

        JBanking.Add('giroNo', CompanyInfo."Giro No.");
        JBanking.Add('bankName', CompanyInfo."Bank Name");
        JBanking.Add('bankBranchNo', CompanyInfo."Bank Branch No.");
        JBanking.Add('bankAccountNo', CompanyInfo."Bank Account No.");
        JBanking.Add('paymentRoutingNo', CompanyInfo."Payment Routing No.");
        JBanking.Add('iban', CompanyInfo.IBAN);
        JBanking.Add('swiftCode', CompanyInfo."SWIFT Code");

        JShipping.Add('shipToName', CompanyInfo."Ship-to Name");
        JShipping.Add('shipToName2', CompanyInfo."Ship-to Name 2");
        JShipping.Add('shipToAddress', CompanyInfo."Ship-to Address");
        JShipping.Add('shipToAddress2', CompanyInfo."Ship-to Address 2");
        JShipping.Add('shipToCity', CompanyInfo."Ship-to City");
        JShipping.Add('shipToPostCode', CompanyInfo."Ship-to Post Code");
        JShipping.Add('shipToCounty', CompanyInfo."Ship-to County");
        JShipping.Add('shipToCountryRegionCode', CompanyInfo."Ship-to Country/Region Code");
        JShipping.Add('shipToContact', CompanyInfo."Ship-to Contact");
        JShipping.Add('shipToPhoneNo', CompanyInfo."Ship-to Phone No.");
        JShipping.Add('locationCode', CompanyInfo."Location Code");

        CompanyData.Add('general', JGeneral);
        CompanyData.Add('address', JAddress);
        CompanyData.Add('contacts', JContacts);
        CompanyData.Add('registration', JRegistration);
        CompanyData.Add('banking', JBanking);
        CompanyData.Add('shipping', JShipping);

        CurrPage.Dashboard.displayCompanyInformation(CompanyData);
    end;

    local procedure UpdateCompanyInformation(CompanyData: JsonObject)
    var
        JGeneral: JsonObject;
        JAddress: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        LogoBase64: Text;
        JToken: JsonToken;
    begin
        CompanyInfo.Get();

        if CompanyData.Get('general', JToken) then begin
            JGeneral := JToken.AsObject();
            if JGeneral.Get('name', JToken) then
                CompanyInfo.Name := JToken.AsValue().AsText();

            if JGeneral.Get('logoBase64', JToken) then begin
                LogoBase64 := JToken.AsValue().AsText();
                if LogoBase64 <> '' then begin
                    TempBlob.CreateOutStream(OutStr);
                    Base64Convert.FromBase64(LogoBase64, OutStr);
                    TempBlob.CreateInStream(InStr);
                    CompanyInfo.Picture.CreateOutStream(OutStr);
                    CopyStream(OutStr, InStr);
                end;
            end;
        end;

        if CompanyData.Get('address', JToken) then begin
            JAddress := JToken.AsObject();
            if JAddress.Get('address', JToken) then
                CompanyInfo.Address := JToken.AsValue().AsText();
            if JAddress.Get('countryRegionCode', JToken) then
                CompanyInfo."Country/Region Code" := JToken.AsValue().AsText();
        end;

        CompanyInfo.Modify(true);
    end;

    local procedure LoadInitialSetup()
    var
        InitialSetup: Record "Initial Setup";
        EmpSetup: Record "Employee Ext Setup";
        SetupData: JsonObject;
        JSetup: JsonObject;
    begin
        if not InitialSetup.Get() then begin
            InitialSetup.Init();
            InitialSetup."Primary Key" := '';
            InitialSetup.Insert(true);
        end;

        if not EmpSetup.FindFirst() then begin
            EmpSetup.Init();
            EmpSetup.Insert(true);
        end;

        JSetup.Add('subscriptionNos', InitialSetup."Subscription Nos.");
        JSetup.Add('complianceNos', InitialSetup."Compliance Nos.");
        JSetup.Add('employeeExtNos', EmpSetup."Employee Ext Nos.");

        SetupData.Add('setup', JSetup);
        CurrPage.Dashboard.displayInitialSetup(SetupData);
    end;

    local procedure UpdateInitialSetup(SetupData: JsonObject)
    var
        InitialSetup: Record "Initial Setup";
        EmpSetup: Record "Employee Ext Setup";
        JSetup: JsonObject;
        JToken: JsonToken;
    begin
        InitialSetup.Get();

        if not EmpSetup.FindFirst() then begin
            EmpSetup.Init();
            EmpSetup.Insert(true);
        end;

        if SetupData.Get('setup', JToken) then begin
            JSetup := JToken.AsObject();
            if JSetup.Get('subscriptionNos', JToken) then
                InitialSetup."Subscription Nos." := JToken.AsValue().AsCode();
            if JSetup.Get('complianceNos', JToken) then
                InitialSetup."Compliance Nos." := JToken.AsValue().AsCode();
            if JSetup.Get('employeeExtNos', JToken) then begin
                EmpSetup."Employee Ext Nos." := JToken.AsValue().AsCode();
                EmpSetup.Modify(true);
            end;
        end;

        InitialSetup.Modify(true);
    end;

    local procedure AutoCreateAllNumberSeries()
    var
        InitialSetup: Record "Initial Setup";
        EmpSetup: Record "Employee Ext Setup";
    begin
        InitialSetup.Get();
        InitialSetup.CreateDefaultSubscriptionNumberSeries();
        InitialSetup.CreateDefaultComplianceNumberSeries();

        if not EmpSetup.FindFirst() then begin
            EmpSetup.Init();
            EmpSetup.Insert(true);
        end;

        CreateDefaultEmployeeNoSeries(EmpSetup);
        LoadInitialSetup();
    end;

    local procedure CreateDefaultEmployeeNoSeries(var EmpSetup: Record "Employee Ext Setup")
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        SeriesCode: Code[20];
    begin
        SeriesCode := 'EMP';

        if not NoSeries.Get(SeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := SeriesCode;
            NoSeries.Description := 'Employee Numbers';
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := SeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'EMP00001';
            NoSeriesLine."Ending No." := 'EMP99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert(true);
        end;

        EmpSetup."Employee Ext Nos." := SeriesCode;
        EmpSetup.Modify(true);
    end;

local procedure ParseIsoDate(DateTxt: Text; var OutDate: Date): Boolean
var
    Y: Integer;
    M: Integer;
    D: Integer;
    Parts: List of [Text];
    TY: Text;
    TM: Text;
    TD: Text;
begin
    OutDate := 0D;
    if DateTxt = '' then
        exit(false);

    // Instance method: Split on the *value* (not on the Text type)
    Parts := DateTxt.Split('-');  // returns List of [Text]
    if Parts.Count() <> 3 then
        exit(false);

    TY := Parts.Get(1);
    TM := Parts.Get(2);
    TD := Parts.Get(3);

    if not Evaluate(Y, TY) then
        exit(false);
    if not Evaluate(M, TM) then
        exit(false);
    if not Evaluate(D, TD) then
        exit(false);

    if (Y = 0) or (M = 0) or (D = 0) then
        exit(false);

    OutDate := DMY2DATE(D, M, Y);
    exit(OutDate <> 0D);
end;

}
