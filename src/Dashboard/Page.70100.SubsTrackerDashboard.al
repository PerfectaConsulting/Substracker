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

                // Existing triggers
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

                // NEW: JS -> AL
                trigger savePaymentMethod(MethodData: JsonObject)
                begin
                    SavePaymentMethod(MethodData);
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

    // -------------------------- Navigation --------------------------
    local procedure HandleNavigation(PageName: Text)
    var
        ComplianceRec: Record "Compliance Overview";
        PM: Record "ST Payment Method";
        EntryNo: Integer;
    begin
        case true of
            // Sidebar
            PageName = 'Dashboard':
                OpenDashboardPage();
            PageName = 'Initial Setup':
                LoadInitialSetup();
            PageName = 'Subscription':
                OpenSubscriptionPage();
            PageName = 'Compliance':
                begin
                    OpenCompliancePage();
                    //SendComplianceStatistics(); // NEW: send stats to JS when Compliance is selected
                end;
            PageName = 'Notification':
                OpenNotificationPage();
            PageName = 'Company Information':
                LoadCompanyInformation();

            // Notifications
            PageName = 'Subscription Notifications':
                PAGE.Run(50139);
            PageName = 'Compliance Notifications':
                PAGE.Run(70131);

            // Subscription buttons
            PageName = 'Add Subscription':
                PAGE.Run(PAGE::"Add Subscription");
            PageName = 'Manage Subscriptions':
                PAGE.Run(PAGE::"Manage Subscriptions");
            PageName = 'Active Subscriptions':
                PAGE.Run(PAGE::"Active Subscriptions");
            PageName = 'Inactive Subscriptions':
                PAGE.Run(PAGE::"Inactive Subscriptions");
            PageName = 'Renewals This Month':
                PAGE.Run(PAGE::"Renewals This Month");

            // Compliance buttons
            PageName = 'Setup New Compliance Item':
                PAGE.RunModal(PAGE::"Compliance Type Selector");
            PageName = 'Submit a Compliance':
                PAGE.Run(PAGE::"Compliance List");
            PageName = 'View Submitted Compliance':
                PAGE.Run(PAGE::"Compliance Archive List");
            PageName = 'Pending Compliance Submissions':
                PAGE.Run(PAGE::"Pending Compliance List");
            PageName = 'This Month’s Submissions':
                PAGE.Run(PAGE::"Due This Month Compliance List");
                PageName = 'Open Employee Ext Setup':
    PAGE.Run(PAGE::"Employee Ext Setup");
PageName = 'Open Subscription Chart':
    PAGE.Run(70157); // Subscription Chart
PageName = 'Open Compliance Chart':
    PAGE.Run(PAGE::"Compliance Chart"); // 70156

            PageName = 'Auto Create All Number Series':
                AutoCreateAllNumberSeries();
            // PageName = 'Open Initial Setup':
            //     PAGE.Run(PAGE::"Initial Setup");
            // Rename route to "Assign Manually" but still accept the old label for safety
PageName in ['Assign Manually', 'Open Initial Setup']:
begin
    PAGE.Run(PAGE::"Initial Setup");  // user edits series manually
    LoadInitialSetup();               // <— refresh JS after page closes
end;
PageName = 'Add Department':
begin
    PAGE.Run(PAGE::"Department Master Card");
    SendDepartments(); // refresh list after closing the card
end;

 PageName = 'AddEmployee':
            begin
                PAGE.Run(PAGE::"Employee Ext Card");  // <-- opens page 50121
                SendEmployees();                      // refresh the list after close
                 
            end;

PageName.StartsWith('EditEmployee:'):
begin
    HandleEditEmployee(PageName);
end;
 


PageName.StartsWith('EditDepartment:'):
begin
    HandleEditDepartment(PageName);
end;

PageName = 'Add Subscription Categories':
begin
    PAGE.Run(PAGE::"Subscription Categories"); // page 50123
    SendSubscriptionCategories();              // refresh list after close
end;

PageName.StartsWith('EditSubscriptionCategory:'):
begin
    HandleEditSubscriptionCategory(PageName);
end;

 

PageName = 'LoadDepartments':
    SendDepartments();



            // NEW: open Payment Methods list page
            PageName = 'Manage Payment Methods':
                begin
                    PAGE.Run(PAGE::"ST Payment Methods");
                    SendPaymentMethods(); // Send updated list after page closes
                end;
            PageName.StartsWith('EditPaymentMethod:'):
                begin
                    Evaluate(EntryNo, CopyStr(PageName, 19)); // Extract ID after 'EditPaymentMethod:'
                    if PM.Get(EntryNo) then begin
                        PAGE.Run(PAGE::"ST Payment Method Card", PM);
                        SendPaymentMethods(); // Send updated list after page closes
                    end else
                        Error('Payment method with Entry No. %1 not found.', EntryNo);
                end;
            else
                Message('Unknown navigation: %1', PageName);
        end;

        CurrPage.Dashboard.setActiveNavigation(PageName);
    end;

var
    Emp: Record "Employee Ext";
    EmpNoTxt: Text;
local procedure SendComplianceStatisticsWithRange(FromDateTxt: Text; ToDateTxt: Text)
var
    ComplianceRec: Record "Compliance Overview";
    ArchiveRec: Record "Compliance Overview Archive";
    Stats: JsonObject;
    PendingCount: Integer;
    ActiveCount: Integer;
    PayableSum: Decimal;
    FromDate: Date;
    ToDate: Date;
begin
    // Parse dates coming from JS (yyyy-mm-dd)
    Evaluate(FromDate, FromDateTxt);
    Evaluate(ToDate,   ToDateTxt);

    // Pending = all records in Compliance Overview (unchanged)
    ComplianceRec.Reset();
    PendingCount := ComplianceRec.Count;

    // Active = all records in Archive (unchanged)
    ArchiveRec.Reset();
    ActiveCount := ArchiveRec.Count;

    // Sum Payable Amount within selected range using "File Submitted"
    ArchiveRec.Reset();
    if (FromDate <> 0D) or (ToDate <> 0D) then
        ArchiveRec.SetRange("File Submitted", FromDate, ToDate);

    PayableSum := 0;
    if ArchiveRec.FindSet() then
        repeat
            PayableSum += ArchiveRec."Payable Amount";
        until ArchiveRec.Next() = 0;

    // Send to JS (use 'yearly' key for clarity; also keep 'total' for backward compat)
    Stats.Add('yearly', PayableSum);
    Stats.Add('total',  PayableSum);
    Stats.Add('active', ActiveCount);
    Stats.Add('pending', PendingCount);

    CurrPage.Dashboard.renderComplianceStatistics(Stats);
end;

    local procedure HandleEditSubscriptionCategory(PageName: Text)
var
    Cat: Record "Subscription Category";
    CatCode: Code[20]; // adjust if your Code length differs
begin
    // Extract after 'EditSubscriptionCategory:'
    CatCode := CopyStr(PageName, StrLen('EditSubscriptionCategory:') + 1);

    if Cat.Get(CatCode) then begin
        PAGE.Run(PAGE::"Subscription Categories", Cat); // page 50123
        SendSubscriptionCategories();
    end else
        Message('Subscription Category %1 not found.', CatCode);
end;

local procedure SendSubscriptionCategories()
var
    Cat: Record "Subscription Category"; // table 50124
    Arr: JsonArray;
    Obj: JsonObject;
begin
    Cat.Reset();
    if Cat.FindSet() then
        repeat
            Clear(Obj);
            Obj.Add('code', Cat.Code);
            // 👇 Adjust the field if your display name differs (e.g., Cat.Name or Cat.Description)
            Obj.Add('name', Cat.Description);
            Arr.Add(Obj);
        until Cat.Next() = 0;

    CurrPage.Dashboard.renderSubscriptionCategories(Arr);
end;

local procedure HandleEditDepartment(PageName: Text)
var
    Dept: Record "Department Master";
    DeptCode: Code[20]; // adjust length if your "Code" differs
begin
    // Extract text after 'EditDepartment:'
    DeptCode := CopyStr(PageName, StrLen('EditDepartment:') + 1);

    if Dept.Get(DeptCode) then begin
        PAGE.Run(PAGE::"Department Master Card", Dept); // page 50116
        SendDepartments(); // refresh list after closing
    end else
        Message('Department %1 not found.', DeptCode);
end;

local procedure HandleEditEmployee(PageName: Text)
var
    Emp: Record "Employee Ext";
    EmpNoTxt: Text;
begin
    // Text after 'EditEmployee:'
    EmpNoTxt := CopyStr(PageName, StrLen('EditEmployee:') + 1);
    if Emp.Get(EmpNoTxt) then begin
        PAGE.Run(PAGE::"Employee Ext Card", Emp);
        SendEmployees();
    end else
        Message('Employee %1 not found.', EmpNoTxt);
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
            // 🔧 Adjust the two lines below if your table uses different field names
            Obj.Add('no', Emp."No.");
            Obj.Add('name', Emp."Full Name"); // use "Full Name" if that's your field
            Arr.Add(Obj);
        until Emp.Next() = 0;

    CurrPage.Dashboard.renderEmployees(Arr);
end;

    local procedure OpenDashboardPage()
begin
    // Render the new JS-based main dashboard
    CurrPage.Dashboard.showMainDashboard();

    // Optionally push initial data right away
    SendSubscriptionStatistics();
    //SendComplianceStatistics();
end;


    local procedure OpenInitialSetupPage()
    begin
        // JS handles
    end;

    local procedure OpenSubscriptionPage()
    begin
    end;

    local procedure OpenCompliancePage()
    begin
    end;

    local procedure OpenNotificationPage()
    begin
    end;


    // -------------------------- Company Info --------------------------
    local procedure LoadCompanyInformation()
    var
        CompanyInfo: Record "Company Information";
        CompanyData: JsonObject;
        JGeneral: JsonObject;
        JAddress: JsonObject;
        JContacts: JsonObject;
        JRegistration: JsonObject;
        JBanking: JsonObject;
        JShipping: JsonObject;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        Base64Str: Text;
    begin
        CompanyInfo.Get();

        // General
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

        // Address
        JAddress.Add('address', CompanyInfo.Address);
        JAddress.Add('address2', CompanyInfo."Address 2");
        JAddress.Add('city', CompanyInfo.City);
        JAddress.Add('postCode', CompanyInfo."Post Code");
        JAddress.Add('county', CompanyInfo.County);
        JAddress.Add('countryRegionCode', CompanyInfo."Country/Region Code");

        // Contacts
        JContacts.Add('phoneNo', CompanyInfo."Phone No.");
        JContacts.Add('phoneNo2', CompanyInfo."Phone No. 2");
        JContacts.Add('faxNo', CompanyInfo."Fax No.");
        JContacts.Add('eMail', CompanyInfo."E-Mail");
       // JContacts.Add('homePage', CompanyInfo."Home Page");
        JContacts.Add('contactPerson', CompanyInfo."Contact Person");

        // Registration
        JRegistration.Add('vatRegistrationNo', CompanyInfo."VAT Registration No.");
        JRegistration.Add('registrationNo', CompanyInfo."Registration No.");
        JRegistration.Add('customsPermitNo', CompanyInfo."Customs Permit No.");
        JRegistration.Add('customsPermitDate', Format(CompanyInfo."Customs Permit Date"));
        JRegistration.Add('eoriNumber', CompanyInfo."EORI Number");
        JRegistration.Add('gln', CompanyInfo.GLN);

        // Banking
        JBanking.Add('giroNo', CompanyInfo."Giro No.");
        JBanking.Add('bankName', CompanyInfo."Bank Name");
        JBanking.Add('bankBranchNo', CompanyInfo."Bank Branch No.");
        JBanking.Add('bankAccountNo', CompanyInfo."Bank Account No.");
        JBanking.Add('paymentRoutingNo', CompanyInfo."Payment Routing No.");
        JBanking.Add('iban', CompanyInfo.IBAN);
        JBanking.Add('swiftCode', CompanyInfo."SWIFT Code");

        // Shipping
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

        // Bundle
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
        CompanyInfo: Record "Company Information";
        JGeneral: JsonObject;
        JAddress: JsonObject;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
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

    // ------------------------ Initial Setup -------------------------
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

    // Ensure Employee Ext Setup record exists
    if not EmpSetup.FindFirst() then begin
        EmpSetup.Init();
        EmpSetup.Insert(true);
    end;

    JSetup.Add('subscriptionNos', InitialSetup."Subscription Nos.");
    JSetup.Add('complianceNos', InitialSetup."Compliance Nos.");
    JSetup.Add('employeeExtNos', EmpSetup."Employee Ext Nos."); // NEW

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

    // Ensure Employee Ext Setup record exists
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

        // NEW: Employee
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

    // Ensure EmpSetup record exists
    if not EmpSetup.FindFirst() then begin
        EmpSetup.Init();
        EmpSetup.Insert(true);
    end;

    // Create/assign default EMP number series if missing
    CreateDefaultEmployeeNoSeries(EmpSetup);

    // Re-send values to JS
    LoadInitialSetup();
end;

// Creates series EMP (EMP00001..EMP99999) if it doesn't exist and assigns it
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


    // -------------------- NEW: Compliance Statistics ----------------------
local procedure SendComplianceStatistics()
var
    ComplianceRec: Record "Compliance Overview";
    ArchiveRec: Record "Compliance Overview Archive";
    Stats: JsonObject;

    PendingCount: Integer;
    ActiveCount: Integer;

    PayableSumCY: Decimal;
    FromDate: Date;
    ToDate: Date;
    CurrentYear: Integer;
begin
    // Pending = all records in Compliance Overview (unchanged)
    ComplianceRec.Reset();
    PendingCount := ComplianceRec.Count;

    // Active = all records in Archive
    ArchiveRec.Reset();
    ActiveCount := ArchiveRec.Count;

    // Sum of Payable Amount for CURRENT YEAR based on "File Submitted" (Archive)
    CurrentYear := Date2DMY(Today(), 3);
    FromDate := DMY2DATE(1, 1, CurrentYear);
    ToDate := DMY2DATE(31, 12, CurrentYear);

    ArchiveRec.Reset();
    ArchiveRec.SetRange("File Submitted", FromDate, ToDate);

    PayableSumCY := 0;
    if ArchiveRec.FindSet() then
        repeat
            PayableSumCY += ArchiveRec."Payable Amount";
        until ArchiveRec.Next() = 0;

    // Send to JS: use 'total' for the first tile
    Stats.Add('total', PayableSumCY);
    Stats.Add('active', ActiveCount);
    Stats.Add('pending', PendingCount);

    CurrPage.Dashboard.renderComplianceStatistics(Stats);
end;

    // -------------------- NEW: Payment Methods ----------------------
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

        if MethodData.Get('type', Tok) then begin
            case LowerCase(Tok.AsValue().AsText()) of
                'type1':
                    PM.Type := PM.Type::type1;
                'type2':
                    PM.Type := PM.Type::type2;
                else
                    Error('Unknown payment method type: %1', Tok.AsValue().AsText());
            end;
        end;

        if MethodData.Get('description', Tok) then
            PM."Description" := Tok.AsValue().AsText();

        if MethodData.Get('icon', Tok) then
            PM."Icon" := Tok.AsValue().AsText();

        if MethodData.Get('managedBy', Tok) then
            PM."Managed By" := Tok.AsValue().AsText();

        if MethodData.Get('expiresAt', Tok) then begin
            Txt := Tok.AsValue().AsText();
            if Txt <> '' then
                Evaluate(D, Txt);
            PM."Expires At" := D;
        end;

        PM.Insert(true);
        SendPaymentMethods(); // return refreshed list to JS
    end;

    local procedure SendPaymentMethods()
    var
        PM: Record "ST Payment Method";
        Arr: JsonArray;
        Obj: JsonObject;
    begin
        if PM.FindSet() then
            repeat
                Clear(Obj);
                Obj.Add('id', PM."Entry No.");
                Obj.Add('title', PM."Title");
                Obj.Add('type', PM."Type");
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

    GLSetup: Record "General Ledger Setup"; // <-- added
begin
    // ---- Totals
    Sub.Reset();
    TotalSubs := Sub.Count;

    Sub.Reset();
    Sub.SetRange(Status, Sub.Status::Active);
    ActiveSubs := Sub.Count;

    Sub.Reset();
    Sub.SetRange(Status, Sub.Status::Inactive);
    InactiveSubs := Sub.Count;

    // ---- Renewals this month
    FirstDay := DMY2DATE(1, Date2DMY(Today(), 2), Date2DMY(Today(), 3));
    LastDay := CalcDate('<CM>', FirstDay) - 1;
    Sub.Reset();
    Sub.SetRange("End Date", FirstDay, LastDay);
    RenewalsThisMonth := Sub.Count;

    // ---- Monthly/Yearly spend (normalize active subs to monthly)
    MonthlySpendLCY := 0;
    YearlySpendLCY := 0;

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

    // ---- Payload
    Stats.Add('total', TotalSubs);
    Stats.Add('active', ActiveSubs);
    Stats.Add('inactive', InactiveSubs);
    Stats.Add('renewals', RenewalsThisMonth);
    Stats.Add('monthly', MonthlySpendLCY);
    Stats.Add('yearly', YearlySpendLCY);

    // Add LCY so JS can render currency
    if GLSetup.Get() then
        Stats.Add('lcy', GLSetup."LCY Code")
    else
        Stats.Add('lcy', '');

    CurrPage.Dashboard.renderSubscriptionStatistics(Stats);
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
            // Adjust if your fields differ
            Obj.Add('code', Dept.Code);
            Obj.Add('name', Dept."Head of Department Name");
            Arr.Add(Obj);
        until Dept.Next() = 0;

    CurrPage.Dashboard.renderDepartments(Arr);
end;



}


