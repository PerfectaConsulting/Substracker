table 50110 "Subscription"
{
    DataClassification = ToBeClassified;
    Caption = 'Subscription';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

             trigger OnValidate()
    var
        InitialSetup: Record "Initial Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        if "No." <> xRec."No." then begin
            // If user types a manual number, verify the selected series allows manual nos.
            InitialSetup.Get();
            if InitialSetup."Subscription Nos." <> '' then
                NoSeriesMgt.TestManual(InitialSetup."Subscription Nos.");

            // Reset link so InitSeries/SelectSeries will relink correctly
            "No. Series" := '';
        end;
    end;
        }

        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }

        field(3; "Subscription ID"; Integer)
        {
            Caption = 'Subscription ID';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(10; "Service Name"; Text[100])
        {
            Caption = 'Service Name';
            DataClassification = CustomerContent;
        }

        field(11; "Vendor"; Text[100])
        {
            Caption = 'Vendor';
            DataClassification = CustomerContent;
        }

        field(12; "Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalculateAmountLCY();
            end;
        }

        field(13; "Billing Cycle"; Enum "Billing Cycle")
        {
            Caption = 'Billing Cycle';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateEndDate();
            end;
        }

        field(14; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmountLCY();
            end;
        }

        field(15; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Start Date" <> 0D then
                    CalculateEndDate();
                ValidateDates();
            end;
        }
        field(17; "Status"; Enum "Subscription Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(18; "Reminder Days"; Integer)
        {
            Caption = 'Reminder Days';
            DataClassification = CustomerContent;
            MinValue = 1;
        }

        field(19; "Reminder Policy"; Enum "Reminder Policy")
        {
            Caption = 'Reminder Policy';
            DataClassification = CustomerContent;
        }
        field(20; "Note"; Text[250])
        {
            Caption = 'Note';
            DataClassification = CustomerContent;
        }
        field(24; "Category Description"; Text[100])
        {
            Caption = 'Category Description';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(26; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                ValidateDates();
            end;
        }

        field(30; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(31; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(32; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(33; "Last Modified By"; Code[50])
        {
            Caption = 'Last Modified By';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(50; "Amount in LCY"; Decimal)
        {
            Caption = 'Amount in LCY';
            Editable = false;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            DecimalPlaces = 2 : 2;
        }

        field(51; "Primary Department"; Code[30])
        {
            Caption = 'Primary Department';
            FieldClass = FlowField;
            CalcFormula = lookup("Department"."Department Code"
                        where("Subscription No." = field("No."),
                              "Primary Department" = const(true)));
        }

        field(52; "Primary Department Description"; Text[100])
        {
            Caption = 'Primary Department Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Department"."Department Description"
                        where("Subscription No." = field("No."),
                              "Primary Department" = const(true)));
        }

        field(53; "Department Count"; Integer)
        {
            Caption = 'Department Count';
            FieldClass = FlowField;
            CalcFormula = count("Department" where("Subscription No." = field("No.")));
        }

        field(55; "End-user"; Code[50])
        {
            Caption = 'End-user';
            TableRelation = "Employee Ext";
            DataClassification = CustomerContent;
        }

        field(56; "Department"; Code[30])
        {
            Caption = 'Department';
            TableRelation = "Department Master".Code;
            DataClassification = CustomerContent;
        }

        field(57; "Payment Method"; Code[20])
        {
            Caption = 'Payment Method';
            TableRelation = "Custom Payment Method".Code;
            DataClassification = CustomerContent;
        }

        field(58; Departments; Text[250])
        {
            Caption = 'Departments';
            DataClassification = CustomerContent;
            ToolTip = 'Displays the list of departments assigned to this subscription';
            Editable = false;
        }
        field(59; "Invoice Number"; Text[20])
        {
            Caption = 'Invoice Number';
            DataClassification = CustomerContent;
            ToolTip = 'Displays the Invoice Number assigned to this subscription';
            Editable = true;
        }

        field(50004; "Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Category Code';
            TableRelation = "Subscription Category".Code;

            trigger OnValidate()
            var
                SubscriptionCategory: Record "Subscription Category";
            begin
                if "Category Code" <> '' then begin
                    if SubscriptionCategory.Get("Category Code") then begin
                        "Category Description" := SubscriptionCategory.Description;
                    end else begin
                        Error('Category Code %1 does not exist.', "Category Code");
                    end;
                end else begin
                    "Category Description" := '';
                end;
            end;
        }

        // NEW FIELD: Billing Cycle Count
        field(50005; "Billing Cycle Count"; Integer)
        {
            Caption = 'Billing Cycle Count';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how many times the selected billing cycle should occur before renewal.';
            MinValue = 1;
            InitValue = 1;

            trigger OnValidate()
            begin
                CalculateEndDate();
            end;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(SubscriptionID; "Subscription ID") { }
        key(NextRenewalDate; "End Date") { }
        key(Status; Status) { }
        key(ServiceName; "Service Name") { }
        key(Category; "Category Code") { }
        key(Currency; "Currency Code") { }
        key(AmountLCY; "Amount in LCY") { }
    }

    // ✅ ADD THIS FIELDGROUPS SECTION FOR MULTI-COLUMN DROPDOWNS
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Service Name", "Category Code", Status)
        {
            // This defines what columns show in dropdown lists when this table is used in TableRelation
        }
    }

    var
        SubscriptionSetup: Record "Subscription Setup";
        NoSeries: Codeunit "No. Series";

    trigger OnInsert()
    var
    InitialSetup: Record "Initial Setup";
    NoSeriesMgt: Codeunit "No. Series";
    begin
         if "No." = '' then begin
        InitialSetup.Get();
        InitialSetup.TestField("Subscription Nos.");

        // Get next number from the series chosen in Initial Setup
        "No." := NoSeriesMgt.GetNextNo(
            InitialSetup."Subscription Nos.",  // series
            WorkDate(),                        // posting date
            true);                             // increment

        // Link the record to that series
        "No. Series" := InitialSetup."Subscription Nos.";
    end;
        "Created Date" := CurrentDateTime;
        "Created By" := UserId;
        "Last Modified Date" := CurrentDateTime;
        "Last Modified By" := UserId;

        if Status = Status::" " then
            Status := Status::Active;

        // Ensure Billing Cycle Count has a default value
        if "Billing Cycle Count" = 0 then
            "Billing Cycle Count" := 1;

        CalculateAmountLCY();
        CreateLedgerEntry("Subscription Change Type"::Creation, 0D, 0D);
    end;

    trigger OnModify()
    begin
        "Last Modified Date" := CurrentDateTime;
        "Last Modified By" := UserId;

        if Status <> xRec.Status then begin
            Commit();
        end;
    end;

    trigger OnDelete()
    begin
        CreateLedgerEntry("Subscription Change Type"::Cancellation, "Start Date", "End Date");
    end;

    procedure AssistEdit(OldSubscription: Record "Subscription"): Boolean
    var
        SelectedNoSeries: Code[20];
    begin
        SubscriptionSetup.GetRecordOnce();
        SubscriptionSetup.TestField("Subscription Nos.");

        if NoSeries.LookupRelatedNoSeries(SubscriptionSetup."Subscription Nos.", OldSubscription."No. Series", SelectedNoSeries) then begin
            "No. Series" := SelectedNoSeries;
            "No." := NoSeries.GetNextNo(SelectedNoSeries);
            exit(true);
        end;
    end;

    procedure CalculateEndDate()
    var
        CycleCount: Integer;
        DateFormulaText: Text;
        EndDateFormula: DateFormula;
    begin
        // Exit if Start Date is not set
        if "Start Date" = 0D then begin
            "End Date" := 0D;
            exit;
        end;

        // Ensure Billing Cycle Count is at least 1
        CycleCount := "Billing Cycle Count";
        if CycleCount < 1 then begin
            CycleCount := 1;
            "Billing Cycle Count" := 1;
        end;

        // Build the DateFormula string based on Billing Cycle and Count
        case "Billing Cycle" of
            "Billing Cycle"::Weekly:
                DateFormulaText := StrSubstNo('<%1W-1D>', CycleCount);
            "Billing Cycle"::Monthly:
                DateFormulaText := StrSubstNo('<%1M-1D>', CycleCount);
            "Billing Cycle"::Quarterly:
                DateFormulaText := StrSubstNo('<%1M-1D>', CycleCount * 3);
            "Billing Cycle"::Yearly:
                DateFormulaText := StrSubstNo('<%1Y-1D>', CycleCount);
            else
                DateFormulaText := '<1M-1D>'; // Default fallback
        end;

        // Convert text to DateFormula and calculate End Date
        if Evaluate(EndDateFormula, DateFormulaText) then begin
            "End Date" := CalcDate(EndDateFormula, "Start Date");
        end else begin
            // Fallback if DateFormula evaluation fails
            "End Date" := CalcDate('<1M-1D>', "Start Date");
        end;
    end;

    procedure CalculateAmountLCY()
    var
        ExchangeRate: Decimal;
        GLSetup: Record "General Ledger Setup";
    begin
        "Amount in LCY" := 0;

        if Amount = 0 then
            exit;

        if "Currency Code" = '' then begin
            if GLSetup.Get() then
                "Amount in LCY" := Amount
            else
                "Amount in LCY" := Amount;
            exit;
        end;

        ExchangeRate := GetCurrentExchangeRate("Currency Code");

        if ExchangeRate <> 0 then begin
            "Amount in LCY" := Amount * ExchangeRate;
        end else begin
            "Amount in LCY" := 0;
        end;
    end;

    procedure GetCurrentExchangeRate(CurrencyCode: Code[10]): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ExchangeRateAmount: Decimal;
        RelationalExchRateAmount: Decimal;
    begin
        CurrencyExchangeRate.SetRange("Currency Code", CurrencyCode);
        CurrencyExchangeRate.SetFilter("Starting Date", '<=%1', Today);
        CurrencyExchangeRate.SetCurrentKey("Currency Code", "Starting Date");
        CurrencyExchangeRate.Ascending(false);

        if CurrencyExchangeRate.FindFirst() then begin
            ExchangeRateAmount := CurrencyExchangeRate."Exchange Rate Amount";
            RelationalExchRateAmount := CurrencyExchangeRate."Relational Exch. Rate Amount";

            if ExchangeRateAmount = 0 then
                ExchangeRateAmount := 1;
            if RelationalExchRateAmount = 0 then
                RelationalExchRateAmount := 1;

            if ExchangeRateAmount <> 0 then
                exit(RelationalExchRateAmount / ExchangeRateAmount)
            else
                exit(0);
        end else begin
            exit(0);
        end;
    end;

    procedure RenewSubscription()
    var
        OldStartDate: Date;
        OldEndDate: Date;
        CycleCount: Integer;
        DateFormulaText: Text;
        RenewalFormula: DateFormula;
    begin
        OldStartDate := "Start Date";
        OldEndDate := "End Date";

        // Ensure Billing Cycle Count is at least 1
        CycleCount := "Billing Cycle Count";
        if CycleCount < 1 then
            CycleCount := 1;

        // Build renewal DateFormula
        case "Billing Cycle" of
            "Billing Cycle"::Weekly:
                DateFormulaText := StrSubstNo('<%1W>', CycleCount);
            "Billing Cycle"::Monthly:
                DateFormulaText := StrSubstNo('<%1M>', CycleCount);
            "Billing Cycle"::Quarterly:
                DateFormulaText := StrSubstNo('<%1M>', CycleCount * 3);
            "Billing Cycle"::Yearly:
                DateFormulaText := StrSubstNo('<%1Y>', CycleCount);
            else
                DateFormulaText := '<1M>';
        end;

        // Calculate new dates based on current End Date
        if Evaluate(RenewalFormula, DateFormulaText) then begin
            "Start Date" := "End Date" + 1;
            "End Date" := CalcDate(RenewalFormula, "Start Date") - 1;
        end;

        if Status in [Status::Expired, Status::Inactive, Status::Cancelled] then
            Status := Status::Active;

        CreateLedgerEntry("Subscription Change Type"::Renewal, OldStartDate, OldEndDate);
    end;

    procedure IsExpiringSoon(): Boolean
    begin
        if ("End Date" <> 0D) and ("Reminder Days" > 0) then
            exit("End Date" <= CalcDate('<+' + Format("Reminder Days") + 'D>', Today));
    end;

    procedure GetCategoryDescription(): Text[100]
    var
        SubscriptionCategory: Record "Subscription Category";
    begin
        if ("Category Code" <> '') and SubscriptionCategory.Get("Category Code") then
            exit(SubscriptionCategory.Description);
        exit('');
    end;

    procedure ValidateCategory()
    var
        SubscriptionCategory: Record "Subscription Category";
    begin
        if "Category Code" <> '' then begin
            if not SubscriptionCategory.Get("Category Code") then
                Error('Category "%1" does not exist.', "Category Code");
        end;
    end;

    procedure ValidateDates()
    begin
        if ("Start Date" <> 0D) and ("End Date" <> 0D) then begin
            if "End Date" <= "Start Date" then
                Error('End Date must be after Start Date.\Start Date: %1\End Date: %2', "Start Date", "End Date");
        end;
    end;

    procedure CreateLedgerEntry(ChangeType: Enum "Subscription Change Type"; OldStartDate: Date; OldEndDate: Date)
    var
        SubscriptionLedger: Record "Subscription Ledger Entry";
    begin
        SubscriptionLedger.Init();
        SubscriptionLedger."Subscription No." := "No.";
        SubscriptionLedger."Service Name" := "Service Name";
        SubscriptionLedger.Vendor := Vendor;
        SubscriptionLedger."Category Code" := "Category Code";
        SubscriptionLedger.Amount := Amount;
        SubscriptionLedger."Currency Code" := "Currency Code";
        SubscriptionLedger."Amount in LCY" := "Amount in LCY";
        SubscriptionLedger."Billing Cycle" := "Billing Cycle";
        SubscriptionLedger."Start Date" := "Start Date";
        SubscriptionLedger."End Date" := "End Date";
        SubscriptionLedger.Status := Status;
        SubscriptionLedger."Reminder Days" := "Reminder Days";
        SubscriptionLedger."Reminder Policy" := "Reminder Policy";
        SubscriptionLedger.Note := Note;
        SubscriptionLedger."Change Date" := CurrentDateTime;
        SubscriptionLedger."Changed By" := UserId;
        SubscriptionLedger."Change Type" := ChangeType;
        SubscriptionLedger."Previous Start Date" := OldStartDate;
        SubscriptionLedger."Previous End Date" := OldEndDate;

        if not SubscriptionLedger.Insert(true) then
            Message('Warning: Could not create ledger entry for subscription %1', "No.");
    end;

    procedure CancelSubscription()
    begin
        CreateLedgerEntry("Subscription Change Type"::Cancellation, "Start Date", "End Date");
        Status := Status::Cancelled;
        Modify(true);
    end;

    procedure GetStatusText(): Text
    begin
        case Status of
            Status::Active:
                exit('Active');
            Status::Inactive:
                exit('Inactive');
            Status::Cancelled:
                exit('Cancelled');
            Status::Expired:
                exit('Expired');
            else
                exit('Unknown');
        end;
    end;

    procedure IsActive(): Boolean
    begin
        exit(Status = Status::Active);
    end;

    procedure HasExpired(): Boolean
    begin
        exit(("End Date" <> 0D) and ("End Date" < Today));
    end;

    procedure UpdateStatus() ResultChanged: Boolean
    var
        OldStatus: Enum "Subscription Status";
    begin
        OldStatus := Status;

        if HasExpired() and (Status = Status::Active) then begin
            Status := Status::Expired;
            ResultChanged := true;
        end;

        if ResultChanged then
            Modify(true);
    end;

    procedure UpdateStatusAndRefresh() ResultChanged: Boolean
    var
        OldStatus: Enum "Subscription Status";
    begin
        OldStatus := Status;

        if HasExpired() and (Status = Status::Active) then begin
            Status := Status::Expired;
            ResultChanged := true;
        end;

        if ResultChanged then begin
            Modify(true);
        end;
    end;

    procedure TrackFieldChanges(var OldSubscription: Record "Subscription")
    begin
        if (Rec."Start Date" <> OldSubscription."Start Date") or
           (Rec."End Date" <> OldSubscription."End Date") or
           (Rec.Amount <> OldSubscription.Amount) or
           (Rec."Currency Code" <> OldSubscription."Currency Code") or
           (Rec."Billing Cycle" <> OldSubscription."Billing Cycle") then begin
            CreateLedgerEntry("Subscription Change Type"::Update, OldSubscription."Start Date", OldSubscription."End Date");
        end;
    end;

    procedure GetBillingCycleText(): Text
    begin
        case "Billing Cycle" of
            "Billing Cycle"::Weekly:
                exit('Weekly');
            "Billing Cycle"::Monthly:
                exit('Monthly');
            "Billing Cycle"::Quarterly:
                exit('Quarterly');
            "Billing Cycle"::Yearly:
                exit('Yearly');
            else
                exit('Unknown');
        end;
    end;

    procedure GetBillingCycleDays(): Integer
    begin
        case "Billing Cycle" of
            "Billing Cycle"::Weekly:
                exit(7);
            "Billing Cycle"::Monthly:
                exit(30);
            "Billing Cycle"::Quarterly:
                exit(90);
            "Billing Cycle"::Yearly:
                exit(365);
            else
                exit(30);
        end;
    end;

    procedure GetStatusWithStyle(var StyleExpr: Text): Text
    begin
        case Status of
            Status::Active:
                begin
                    StyleExpr := 'Favorable';
                    exit('Active');
                end;
            Status::Cancelled:
                begin
                    StyleExpr := 'Unfavorable';
                    exit('Cancelled');
                end;
            Status::Expired:
                begin
                    StyleExpr := 'Attention';
                    exit('Expired');
                end;
            Status::Inactive:
                begin
                    StyleExpr := 'Subordinate';
                    exit('Inactive');
                end;
            else begin
                StyleExpr := 'Standard';
                exit('Unknown');
            end;
        end;
    end;

    procedure CanRenew(): Boolean
    begin
        exit(Status in [Status::Cancelled, Status::Expired, Status::Inactive]);
    end;

    procedure CanCancel(): Boolean
    begin
        exit(Status = Status::Active);
    end;

    procedure GetFormattedAmount(): Text
    var
        Currency: Record Currency;
    begin
        if "Currency Code" <> '' then begin
            if Currency.Get("Currency Code") then
                exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>') + ' ' + "Currency Code")
            else
                exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>') + ' ' + "Currency Code");
        end else
            exit(Format(Amount, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    procedure GetFormattedAmountLCY(): Text
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if GLSetup.Get() then begin
            if GLSetup."LCY Code" <> '' then
                exit(Format("Amount in LCY", 0, '<Precision,2:2><Standard Format,0>') + ' ' + GLSetup."LCY Code")
            else
                exit(Format("Amount in LCY", 0, '<Precision,2:2><Standard Format,0>'));
        end else
            exit(Format("Amount in LCY", 0, '<Precision,2:2><Standard Format,0>'));
    end;

    procedure GetExchangeRateInfo(): Text
    var
        ExchangeRate: Decimal;
    begin
        if "Currency Code" = '' then
            exit('Local Currency');

        ExchangeRate := GetCurrentExchangeRate("Currency Code");
        if ExchangeRate <> 0 then
            exit(StrSubstNo('Exchange Rate: %1', Format(ExchangeRate, 0, '<Precision,6:6><Standard Format,0>')))
        else
            exit('No Exchange Rate Found');
    end;

    procedure ValidateCurrency(): Boolean
    var
        Currency: Record Currency;
        ExchangeRate: Decimal;
    begin
        if "Currency Code" = '' then
            exit(true);

        if not Currency.Get("Currency Code") then begin
            Error('Currency Code %1 does not exist in the Currency table.', "Currency Code");
            exit(false);
        end;

        ExchangeRate := GetCurrentExchangeRate("Currency Code");
        if ExchangeRate = 0 then begin
            Message('Warning: No exchange rate found for currency %1. Please set up exchange rates in the Currency Exchange Rates page.', "Currency Code");
        end;

        exit(true);
    end;
}
