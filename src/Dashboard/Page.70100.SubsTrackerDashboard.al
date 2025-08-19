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

                trigger getPaymentMethods()
                begin
                    SendPaymentMethods();
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
                OpenCompliancePage();
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

            PageName = 'Auto Create All Number Series':
                AutoCreateAllNumberSeries();
            PageName = 'Open Initial Setup':
                PAGE.Run(PAGE::"Initial Setup");

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

    local procedure OpenDashboardPage()
    begin
        PAGE.Run(PAGE::"Compliance Chart");
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
        JContacts.Add('homePage', CompanyInfo."Home Page");
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
        SetupData: JsonObject;
        JSetup: JsonObject;
    begin
        if not InitialSetup.Get() then begin
            InitialSetup.Init();
            InitialSetup."Primary Key" := '';
            InitialSetup.Insert(true);
        end;

        JSetup.Add('subscriptionNos', InitialSetup."Subscription Nos.");
        JSetup.Add('complianceNos', InitialSetup."Compliance Nos.");
        SetupData.Add('setup', JSetup);

        CurrPage.Dashboard.displayInitialSetup(SetupData);
    end;

    local procedure UpdateInitialSetup(SetupData: JsonObject)
    var
        InitialSetup: Record "Initial Setup";
        JSetup: JsonObject;
        JToken: JsonToken;
    begin
        InitialSetup.Get();

        if SetupData.Get('setup', JToken) then begin
            JSetup := JToken.AsObject();
            if JSetup.Get('subscriptionNos', JToken) then
                InitialSetup."Subscription Nos." := JToken.AsValue().AsCode();
            if JSetup.Get('complianceNos', JToken) then
                InitialSetup."Compliance Nos." := JToken.AsValue().AsCode();
        end;

        InitialSetup.Modify(true);
    end;

    local procedure AutoCreateAllNumberSeries()
    var
        InitialSetup: Record "Initial Setup";
    begin
        InitialSetup.Get();
        InitialSetup.CreateDefaultSubscriptionNumberSeries();
        InitialSetup.CreateDefaultComplianceNumberSeries();
        LoadInitialSetup();
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
}
