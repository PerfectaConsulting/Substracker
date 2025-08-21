page 50110 "Add Subscription"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Subscription";
    UsageCategory = Administration;
    Caption = 'Add Subscription';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General Information';

                grid(GeneralGrid)
                {
                    GridLayout = Columns;

                    group(Column1)
                    {
                        ShowCaption = false;

                        field("No."; Rec."No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the number of the subscription.';

                            trigger OnAssistEdit()
                            begin
                                if Rec.AssistEdit(xRec) then
                                    CurrPage.Update();
                            end;
                        }

                        field("Service Name"; Rec."Service Name")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specify the name of the subscription service.';

                            trigger OnValidate()
                            begin
                                AutoSaveRecord();
                            end;
                        }

                        field("Vendor"; Rec.Vendor)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specify the vendor providing the subscription service.';

                            trigger OnValidate()
                            begin
                                AutoSaveRecord();
                            end;
                        }
                    }

                    group(Column2)
                    {
                        ShowCaption = false;

                        field("Category Code"; Rec."Category Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Select the category for this subscription.';

                            trigger OnValidate()
                            var
                                SubscriptionCategory: Record "Subscription Category";
                            begin
                                if Rec."Category Code" <> '' then
                                    if SubscriptionCategory.Get(Rec."Category Code") then
                                        Rec."Category Description" := SubscriptionCategory.Description;
                                AutoSaveRecord();
                            end;
                        }

                        field("Departments"; DepartmentDisplayText)
                        {
                            ApplicationArea = All;
                            Caption = 'Departments';
                            ToolTip = 'Select multiple departments for this subscription. Click to open department selection.';
                            Editable = false;
                            ShowMandatory = true;

                            trigger OnAssistEdit()
                            begin
                                SelectMultipleDepartments();
                                SafeRefreshPage();
                            end;

                            trigger OnDrillDown()
                            begin
                                SelectMultipleDepartments();
                                SafeRefreshPage();
                            end;
                        }

                        field("Primary Employee"; PrimaryEmployeeNo)
                        {
                            ApplicationArea = All;
                            Caption = 'Primary Employee';
                            ToolTip = 'Shows the primary employee assigned to this subscription. Click to manage all end users.';
                            TableRelation = "Employee Ext"."No." where(Status = const(Active), Blocked = const(false));
                            Editable = false;

                            trigger OnAssistEdit()
                            begin
                                OpenSubscriptionEmployees();
                            end;

                            trigger OnDrillDown()
                            begin
                                OpenSubscriptionEmployees();
                            end;
                        }
                    }

                    group(Column3)
                    {
                        ShowCaption = false;

                        field("End User Count"; EndUserCount)
                        {
                            ApplicationArea = All;
                            Caption = 'End Users Count';
                            ToolTip = 'Shows the total number of end users assigned to this subscription.';
                            Editable = false;
                            BlankZero = true;

                            trigger OnDrillDown()
                            begin
                                OpenSubscriptionEmployees();
                            end;
                        }

                        field("End-user"; Rec."End-user")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Select the end user for this subscription.';
                            Caption = 'Owner (Legacy)';
                            Importance = Additional;
                            TableRelation = "Employee Ext"."No." where(Status = const(Active), Blocked = const(false));

                            trigger OnValidate()
                            begin
                                AutoSaveRecord();
                            end;
                        }

                        field("Status"; Rec.Status)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Shows the current status of the subscription.';
                            StyleExpr = StatusStyleExpr;

                            trigger OnValidate()
                            begin
                                AutoSaveRecord();
                            end;
                        }
                    }
                }
            }

            group(SubscriptionDetails)
            {
                Caption = 'Subscription Details';

                grid(DetailsGrid)
                {
                    GridLayout = Columns;

                    group(Column1_Details)
                    {
                        ShowCaption = false;

                        field("Payment Method"; Rec."Payment Method")
{
    ApplicationArea = All;
    ToolTip = 'Select the payment method for this subscription.';
    TableRelation = "ST Payment Method"."Entry No.";

    trigger OnLookup(var Text: Text): Boolean
    var
        STPaymentMethod: Record "ST Payment Method";
        STPaymentMethodsPage: Page "ST Payment Methods"; // Assuming you have a list page for "ST Payment Method" table
    begin
        STPaymentMethod.Reset(); // Optional: Add filters if needed
        STPaymentMethodsPage.SetTableView(STPaymentMethod);
        STPaymentMethodsPage.LookupMode(true);
        if STPaymentMethodsPage.RunModal() = ACTION::LookupOK then begin
            STPaymentMethodsPage.GetRecord(STPaymentMethod);
            Rec."Payment Method" := STPaymentMethod.Description;
            PaymentMethodDescription := STPaymentMethod.Title; // Set the page variable to the Title field
            exit(true);
        end;
        exit(false);
    end;
}

field("Payment Method Description"; PaymentMethodDescription)
{
    ApplicationArea = All;
    Caption = 'Payment Method Name';
    Editable = false;
    Style = StandardAccent;
}

                        field("Currency Code"; Rec."Currency Code")
                        {
                            ApplicationArea = All;
                            TableRelation = Currency.Code;
                            trigger OnValidate()
                            begin
                                CalculateAmountLCY();
                                AutoSaveRecord();
                            end;
                        }
                    }

                    group(Column2_Details)
                    {
                        ShowCaption = false;

                        field("Amount"; Rec.Amount)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Enter the subscription amount in the selected currency.';

                            trigger OnValidate()
                            begin
                                CalculateAmountLCY();
                                AutoSaveRecord();
                            end;
                        }

                        field("Amount in LCY"; Rec."Amount in LCY")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Shows the subscription amount converted to local currency using current exchange rate.';
                            Editable = false;
                            BlankZero = true;
                            Style = StandardAccent;
                        }

                        field("Billing Cycle"; Rec."Billing Cycle")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Select how often the subscription is billed.';

                            trigger OnValidate()
                            begin
                                AutoSaveRecord();
                            end;
                        }
                    }

                    group(Column3_Details)
                    {
                        ShowCaption = false;

                        field("Start Date"; Rec."Start Date")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Enter when the subscription starts.';

                            trigger OnValidate()
                            begin
                                if Rec."Start Date" <> 0D then
                                    SafeCalculateEndDate();
                                AutoSaveRecord();
                            end;
                        }

                        field("End Date"; Rec."End Date")
                        {
                            ApplicationArea = All;
                            ToolTip = 'End Date is automatically calculated based on Start Date and Billing Cycle.';
                            Editable = true;
                            StyleExpr = EndDateStyleExpr;
                            ShowMandatory = false;
                            Style = StandardAccent;

                            trigger OnValidate()
                            begin
                                if Rec."Start Date" <> 0D then begin
                                    SafeCalculateEndDate();
                                    Message('End Date has been automatically recalculated based on Start Date (%1) and Billing Cycle (%2).', Rec."Start Date", Rec."Billing Cycle");
                                end else begin
                                    Error('Please enter a Start Date first. The End Date will be calculated automatically.');
                                end;

                                AutoSaveRecord();
                            end;
                        }

                        field("Reminder Days"; Rec."Reminder Days")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Enter how many days before renewal to send reminders.';

                            trigger OnValidate()
                            begin
                                AutoSaveRecord();
                            end;
                        }
                        field("Reminder Policy"; Rec."Reminder Policy")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Select the reminder policy for this subscription.';

                            trigger OnValidate()
                            begin
                                AutoSaveRecord();
                            end;
                        }
                    }
                }

                //     group(ReminderGroup)
                //     {
                //         Caption = 'Reminder Settings';

                //         field("Reminder Policy"; Rec."Reminder Policy")
                //         {
                //             ApplicationArea = All;
                //             ToolTip = 'Select the reminder policy for this subscription.';

                //             trigger OnValidate()
                //             begin
                //                 AutoSaveRecord();
                //             end;
                //         }
                //     }
            }

            group(Additional)
            {
                Caption = 'Additional Information';

                field("Note"; Rec.Note)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter any additional notes about this subscription.';
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        AutoSaveRecord();
                    end;
                }
            }

            group(DepartmentDetails)
            {
                Caption = 'Department Details';
                part(DepartmentSelection; "Department Selection")
                {
                    ApplicationArea = All;
                    SubPageLink = "Subscription No." = field("No.");
                }
            }

            group(EndUsersDetails)
            {
                Caption = 'End Users';
                part(EndUsersSubpage; "End User Subpage")
                {
                    ApplicationArea = All;
                    SubPageLink = "Subscription No." = field("No.");
                    UpdatePropagation = Both;
                }
            }
        }

        area(FactBoxes)
        {
            part(SubscriptionHistory; "Subscription History FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Subscription No." = field("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SelectDepartmentsAction)
            {
                ApplicationArea = All;
                Caption = 'Select Departments';
                ToolTip = 'Select multiple departments for this subscription.';
                Image = SelectEntries;

                trigger OnAction()
                begin
                    SelectMultipleDepartments();
                    SafeRefreshPage();
                end;
            }

            action(ManageSubscriptionEmployees)
            {
                ApplicationArea = All;
                Caption = 'Manage End Users';
                ToolTip = 'Manage employees assigned as end users to this subscription.';
                Image = Users;
                Enabled = EndUsersEnabled;

                trigger OnAction()
                begin
                    OpenSubscriptionEmployees();
                end;
            }

            action(ManageUsers)
            {
                ApplicationArea = All;
                Caption = 'Legacy Users';
                ToolTip = 'Manage legacy users assigned to this subscription.';
                Image = UserSetup;
                Enabled = UsersEnabled;
                Visible = false;
            }

            action(RenewSubscriptionAction)
            {
                ApplicationArea = All;
                Caption = 'Renew Subscription';
                ToolTip = 'Renew this subscription for another billing cycle.';
                Image = Refresh;
                Enabled = RenewEnabled;

                trigger OnAction()
                begin
                    ProcessRenewal();
                end;
            }

            action(CancelSubscriptionAction)
            {
                ApplicationArea = All;
                Caption = 'Cancel Subscription';
                ToolTip = 'Cancel this subscription.';
                Image = Cancel;
                Enabled = CancelEnabled;

                trigger OnAction()
                begin
                    ProcessCancellation();
                end;
            }

            action(UpdateEndDateAction)
            {
                ApplicationArea = All;
                Caption = 'Update End Date';
                ToolTip = 'Update the end date based on billing cycle.';
                Image = Calculate;

                trigger OnAction()
                begin
                    SafeUpdateEndDate();
                end;
            }

            action(SaveAndGoToListAction)
            {
                ApplicationArea = All;
                Caption = 'Save & Go to List';
                ToolTip = 'Save this subscription and navigate to the subscription list.';
                Image = PostedOrder;

                trigger OnAction()
                begin
                    SaveAndGoToList();
                end;
            }

            action(ViewHistory)
            {
                ApplicationArea = All;
                Caption = 'View History';
                ToolTip = 'View the renewal and cancellation history for this subscription.';
                Image = History;

                trigger OnAction()
                var
                    SubscriptionLedger: Record "Subscription Ledger Entry";
                    SubscriptionLedgerPage: Page "Subscription Ledger Entries";
                begin
                    if Rec."No." = '' then
                        exit;

                    SubscriptionLedger.SetRange("Subscription No.", Rec."No.");
                    SubscriptionLedger.SetFilter("Change Type", '%1|%2',
                        SubscriptionLedger."Change Type"::Renewal,
                        SubscriptionLedger."Change Type"::Cancellation);
                    SubscriptionLedgerPage.SetTableView(SubscriptionLedger);
                    SubscriptionLedgerPage.Run();
                end;
            }

            action(RecalculateLCYAmount)
            {
                ApplicationArea = All;
                Caption = 'Recalculate LCY Amount';
                ToolTip = 'Recalculate the local currency amount using current exchange rates.';
                Image = Calculate;

                trigger OnAction()
                begin
                    CalculateAmountLCY();
                    CurrPage.Update(false);
                    Message('Amount in LCY has been recalculated based on current exchange rates.');
                end;
            }
        }

        area(navigation)
        {
            action(SubscriptionSetup)
            {
                ApplicationArea = All;
                Caption = 'Subscription Setup';
                ToolTip = 'Open subscription setup to configure number series.';
                Image = Setup;
                RunObject = Page "Subscription Setup";
            }

            action(ManageCategories)
            {
                ApplicationArea = All;
                Caption = 'Manage Categories';
                ToolTip = 'Create and manage subscription categories.';
                Image = Category;
                RunObject = Page "Subscription Categories";
            }

            action(ManageDepartments)
            {
                ApplicationArea = All;
                Caption = 'Manage Departments';
                ToolTip = 'Create and manage departments.';
                Image = Departments;
                RunObject = Page Departments;
            }

            action(ViewAllEndUsers)
            {
                ApplicationArea = All;
                Caption = 'End Users for this Subscription';
                ToolTip = 'View end users assigned to this subscription.';
                Image = Users;

                trigger OnAction()
                var
                    EndUserRec: Record "End User";
                    EndUserListPage: Page "End User List";
                begin
                    if Rec."No." = '' then begin
                        Message('Please save the subscription before viewing end users.');
                        exit;
                    end;

                    EndUserRec.SetRange("Subscription No.", Rec."No.");
                    EndUserListPage.SetTableView(EndUserRec);
                    EndUserListPage.Run();

                    SafeRefreshDisplayInfo();
                end;
            }

            action(ManageCurrencies)
            {
                ApplicationArea = All;
                Caption = 'Manage Currencies';
                ToolTip = 'Manage currencies and exchange rates.';
                Image = Currency;
                RunObject = Page Currencies;
            }

            action(ManageEmployeeExt)
            {
                ApplicationArea = All;
                Caption = 'Manage Employee Extensions';
                ToolTip = 'Manage employee extension records.';
                Image = Employee;
                RunObject = Page "Employee Ext List";
            }

            action(ManagePaymentMethods)
            {
                ApplicationArea = All;
                Caption = 'Manage Payment Methods';
                ToolTip = 'Manage custom payment methods.';
                Image = Payment;
                RunObject = Page "Custom Payment Method List";
            }
        }

        area(Promoted)
        {
            group(Process)
            {
                Caption = 'Process';
                actionref(SelectDepartments_Promoted; SelectDepartmentsAction) { }
                actionref(ManageSubscriptionEmployees_Promoted; ManageSubscriptionEmployees) { }
                actionref(RenewSubscription_Promoted; RenewSubscriptionAction) { }
                actionref(CancelSubscription_Promoted; CancelSubscriptionAction) { }
                actionref(UpdateEndDate_Promoted; UpdateEndDateAction) { }
                actionref(SaveAndGoToList_Promoted; SaveAndGoToListAction) { }
                actionref(RecalculateLCY_Promoted; RecalculateLCYAmount) { }
            }
            group(History)
            {
                Caption = 'History';
                actionref(ViewHistory_Promoted; ViewHistory) { }
            }
            group(Setup)
            {
                Caption = 'Setup';
                actionref(ManageCategories_Promoted; ManageCategories) { }
                actionref(ManageDepartments_Promoted; ManageDepartments) { }
                actionref(ViewAllEndUsers_Promoted; ViewAllEndUsers) { }
                actionref(ManageCurrencies_Promoted; ManageCurrencies) { }
                actionref(ManageEmployeeExt_Promoted; ManageEmployeeExt) { }
                actionref(ManagePaymentMethods_Promoted; ManagePaymentMethods) { }
            }
        }
    }

    var
        OriginalStartDate: Date;
        OriginalEndDate: Date;
        IsNewRecord: Boolean;
        StatusStyleExpr: Text;
        EndDateStyleExpr: Text;
        RenewEnabled: Boolean;
        CancelEnabled: Boolean;
        DepartmentDisplayText: Text[250];
        UsersEnabled: Boolean;
        EndUsersEnabled: Boolean;
        PrimaryEmployeeNo: Code[20];
        EndUserCount: Integer;
        LastRefreshTime: Time;
        CacheValidSeconds: Integer;
        PaymentMethodDescription: Text[100];

    trigger OnAfterGetRecord()
    begin
        InitializeVariables();
        SafeUpdateStatusAndRefresh();
        SafeUpdateDisplayInfoWithCache();
        UpdatePaymentMethodDescription();
        SetConditionalFormatting();
        SetActionStates();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SafeUpdateStatusAndRefresh();
        SafeUpdateDisplayInfoWithCache();
        UpdatePaymentMethodDescription();
        SetConditionalFormatting();
        SetActionStates();
    end;

    local procedure UpdatePaymentMethodDescription()
    var
        CustomPaymentMethod: Record "Custom Payment Method";
    begin
        Clear(PaymentMethodDescription);

        if Rec."Payment Method" <> '' then begin
            if CustomPaymentMethod.Get(Rec."Payment Method") then
                PaymentMethodDescription := CustomPaymentMethod.Name
            else
                PaymentMethodDescription := '<Payment Method not found>';
        end;
    end;

    // [All other procedures remain the same as in your original code]
    local procedure InitializeVariables()
    begin
        OriginalStartDate := Rec."Start Date";
        OriginalEndDate := Rec."End Date";
        IsNewRecord := Rec."Subscription ID" = 0;

        if CacheValidSeconds = 0 then
            CacheValidSeconds := 5;

        if LastRefreshTime = 0T then
            LastRefreshTime := Time;
    end;

    local procedure SafeUpdateStatusAndRefresh()
    begin
        if Rec.UpdateStatusAndRefresh() then
            SafeRefreshPage();
    end;

    local procedure SafeUpdateDisplayInfoWithCache()
    var
        CurrentTime: Time;
        ShouldRefresh: Boolean;
    begin
        CurrentTime := Time;

        ShouldRefresh := SafeTimeComparison(CurrentTime, LastRefreshTime);

        if ShouldRefresh then begin
            SafeRefreshDisplayInfo();
            LastRefreshTime := CurrentTime;
        end;
    end;

    local procedure SafeTimeComparison(TimeA: Time; TimeB: Time): Boolean
    var
        CacheThresholdMs: Integer;
    begin
        CacheThresholdMs := CacheValidSeconds * 1000;

        if TimeA = 0T then
            exit(true);
        if TimeB = 0T then
            exit(true);

        if Abs(TimeA - TimeB) > CacheThresholdMs then
            exit(true)
        else
            exit(false);
    end;

    local procedure SafeRefreshDisplayInfo()
    begin
        UpdateDepartmentDisplayText();
        UpdateEndUserInfo();
    end;

    local procedure SafeRefreshPage()
    begin
        CurrPage.Update(false);
    end;

    local procedure CalculateAmountLCY()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ExchangeRate: Decimal;
        GLSetup: Record "General Ledger Setup";
    begin
        Rec."Amount in LCY" := 0;

        if (Rec."Currency Code" = '') or (Rec.Amount = 0) then begin
            if Rec."Currency Code" = '' then begin
                GLSetup.Get();
                if GLSetup."LCY Code" <> '' then
                    Rec."Amount in LCY" := Rec.Amount;
            end;
            exit;
        end;

        ExchangeRate := GetCurrentExchangeRate(Rec."Currency Code");

        if ExchangeRate <> 0 then begin
            Rec."Amount in LCY" := Rec.Amount * ExchangeRate;
        end else begin
            Message('No exchange rate found for currency %1. Please set up exchange rates in the Currency Exchange Rates page.', Rec."Currency Code");
        end;
    end;

    local procedure GetCurrentExchangeRate(CurrencyCode: Code[10]): Decimal
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

    local procedure OpenSubscriptionEmployees()
    var
        EndUser: Record "End User";
        EndUserList: Page "End User List";
    begin
        if Rec."No." = '' then begin
            Message('Please save the subscription first before managing end users.');
            exit;
        end;

        EndUser.SetRange("Subscription No.", Rec."No.");
        EndUserList.SetTableView(EndUser);
        EndUserList.Run();

        SafeRefreshDisplayInfo();
        SafeRefreshPage();
    end;

    local procedure UpdateEndUserInfo()
    var
        EndUser: Record "End User";
    begin
        Clear(PrimaryEmployeeNo);
        EndUserCount := 0;

        if Rec."No." = '' then
            exit;

        EndUser.SetRange("Subscription No.", Rec."No.");
        EndUser.SetLoadFields("Employee No.", "Primary End User");

        if EndUser.FindSet() then
            repeat
                if EndUser."Primary End User" then
                    PrimaryEmployeeNo := EndUser."Employee No.";
                EndUserCount += 1;
            until EndUser.Next() = 0;
    end;

    local procedure SelectMultipleDepartments()
    var
        DepartmentMaster: Record "Department Master";
        DepartmentList: Page "Department Multi-Selection";
        SubscriptionDept: Record "Department";
        TempDepartmentMaster: Record "Department Master" temporary;
        ExistingDeptCheck: Record "Department";
        IsFirstDepartment: Boolean;
    begin
        if Rec."No." = '' then begin
            if Rec."Subscription ID" = 0 then begin
                if ShouldCreateRecord() then begin
                    Rec.Insert(true);
                    IsNewRecord := false;
                end else begin
                    Message('Please enter basic subscription information first.');
                    exit;
                end;
            end;
        end;

        ExistingDeptCheck.SetRange("Subscription No.", Rec."No.");
        IsFirstDepartment := ExistingDeptCheck.IsEmpty();

        SubscriptionDept.SetRange("Subscription No.", Rec."No.");
        SubscriptionDept.SetLoadFields("Department Code");
        if SubscriptionDept.FindSet() then
            repeat
                if DepartmentMaster.Get(SubscriptionDept."Department Code") then begin
                    TempDepartmentMaster := DepartmentMaster;
                    TempDepartmentMaster.Insert();
                end;
            until SubscriptionDept.Next() = 0;

        DepartmentList.SetSelectionFilter(TempDepartmentMaster);
        DepartmentList.LookupMode(true);
        if DepartmentList.RunModal() = Action::LookupOK then begin
            SubscriptionDept.SetRange("Subscription No.", Rec."No.");
            SubscriptionDept.DeleteAll(true);

            DepartmentList.GetSelectionFilter(TempDepartmentMaster);
            if TempDepartmentMaster.FindSet() then begin
                repeat
                    SubscriptionDept.Init();
                    SubscriptionDept."Subscription No." := Rec."No.";
                    SubscriptionDept."Department Code" := TempDepartmentMaster.Code;
                    SubscriptionDept."Department Description" := TempDepartmentMaster.Description;

                    if IsFirstDepartment then begin
                        Clear(ExistingDeptCheck);
                        ExistingDeptCheck.SetRange("Subscription No.", Rec."No.");
                        if ExistingDeptCheck.IsEmpty() then
                            SubscriptionDept."Primary Department" := true;
                        IsFirstDepartment := false;
                    end;

                    SubscriptionDept.Insert(true);
                until TempDepartmentMaster.Next() = 0;
            end;

            SafeRefreshDisplayInfo();
        end;
    end;

    local procedure UpdateDepartmentDisplayText()
    var
        SubscriptionDept: Record "Department";
        StringBuilder: TextBuilder;
        DepartmentCount: Integer;
    begin
        DepartmentDisplayText := '';
        DepartmentCount := 0;

        if Rec."No." = '' then begin
            DepartmentDisplayText := '<Select Departments>';
            exit;
        end;

        SubscriptionDept.SetRange("Subscription No.", Rec."No.");
        SubscriptionDept.SetLoadFields("Department Code");

        if SubscriptionDept.FindSet() then begin
            repeat
                DepartmentCount += 1;
                if DepartmentCount <= 3 then begin
                    if DepartmentCount > 1 then
                        StringBuilder.Append(', ');
                    StringBuilder.Append(SubscriptionDept."Department Code");
                end else begin
                    StringBuilder.Append('...');
                    break;
                end;
            until SubscriptionDept.Next() = 0;

            if DepartmentCount > 1 then
                DepartmentDisplayText := StrSubstNo('%1 (%2 departments)', StringBuilder.ToText(), DepartmentCount)
            else
                DepartmentDisplayText := StringBuilder.ToText();
        end else
            DepartmentDisplayText := '<Select Departments>';
    end;

    local procedure AutoSaveRecord()
    var
        OldStartDate: Date;
        OldEndDate: Date;
    begin
        OldStartDate := OriginalStartDate;
        OldEndDate := OriginalEndDate;

        if Rec."Subscription ID" = 0 then begin
            if ShouldCreateRecord() then begin
                Rec.Insert(true);
                IsNewRecord := false;
            end;
        end else begin
            if (Rec."Start Date" <> OldStartDate) or (Rec."End Date" <> OldEndDate) then
                Rec.CreateLedgerEntry("Subscription Change Type"::Update, OldStartDate, OldEndDate);
            Rec.Modify(true);
        end;

        OriginalStartDate := Rec."Start Date";
        OriginalEndDate := Rec."End Date";

        SetConditionalFormatting();
        SetActionStates();
    end;

    local procedure ShouldCreateRecord(): Boolean
    begin
        exit(
            (Rec."Service Name" <> '') or
            (Rec.Vendor <> '') or
            (Rec."Category Code" <> '') or
            (Rec.Amount <> 0) or
            (Rec."Reminder Policy" <> Rec."Reminder Policy"::" ")
        );
    end;

    local procedure SafeCalculateEndDate()
    begin
        if Rec."Start Date" = 0D then
            exit;

        if Rec."Start Date" < DMY2Date(1, 1, 1900) then begin
            Message('Invalid start date. Please enter a valid date.');
            exit;
        end;

        if Rec."Start Date" > DMY2Date(31, 12, 2099) then begin
            Message('Start date cannot be beyond year 2099.');
            exit;
        end;

        case Rec."Billing Cycle" of
            Rec."Billing Cycle"::Weekly:
                Rec."End Date" := CalcDate('<+1W-1D>', Rec."Start Date");
            Rec."Billing Cycle"::Monthly:
                Rec."End Date" := CalcDate('<+1M-1D>', Rec."Start Date");
            Rec."Billing Cycle"::Quarterly:
                Rec."End Date" := CalcDate('<+3M-1D>', Rec."Start Date");
            Rec."Billing Cycle"::Yearly:
                Rec."End Date" := CalcDate('<+1Y-1D>', Rec."Start Date");
            else
                Rec."End Date" := CalcDate('<+1M-1D>', Rec."Start Date");
        end;
    end;

    local procedure SafeUpdateEndDate()
    var
        OldStartDate: Date;
        OldEndDate: Date;
    begin
        if Rec."Start Date" = 0D then begin
            Message('Please enter a start date first.');
            exit;
        end;

        if Rec."Start Date" < DMY2Date(1, 1, 1900) then begin
            Message('Invalid start date. Please enter a valid date.');
            exit;
        end;

        OldStartDate := Rec."Start Date";
        OldEndDate := Rec."End Date";

        case Rec."Billing Cycle" of
            Rec."Billing Cycle"::Weekly:
                if Rec."End Date" = 0D then
                    Rec."End Date" := CalcDate('<+1W-1D>', Rec."Start Date")
                else
                    Rec."End Date" := CalcDate('<+1W>', Rec."End Date");
            Rec."Billing Cycle"::Monthly:
                if Rec."End Date" = 0D then
                    Rec."End Date" := CalcDate('<+1M-1D>', Rec."Start Date")
                else
                    Rec."End Date" := CalcDate('<+1M>', Rec."End Date");
            Rec."Billing Cycle"::Quarterly:
                if Rec."End Date" = 0D then
                    Rec."End Date" := CalcDate('<+3M-1D>', Rec."Start Date")
                else
                    Rec."End Date" := CalcDate('<+3M>', Rec."End Date");
            Rec."Billing Cycle"::Yearly:
                if Rec."End Date" = 0D then
                    Rec."End Date" := CalcDate('<+1Y-1D>', Rec."Start Date")
                else
                    Rec."End Date" := CalcDate('<+1Y>', Rec."End Date");
        end;

        Rec.CreateLedgerEntry("Subscription Change Type"::Update, OldStartDate, OldEndDate);
        Rec.Modify(true);
        SafeRefreshPage();
    end;

    local procedure ProcessRenewal()
    var
        OldStartDate: Date;
        OldEndDate: Date;
        OldStatus: Enum "Subscription Status";
    begin
        if Rec."No." = '' then
            exit;

        if Confirm('Do you want to renew this subscription?') then begin
            OldStartDate := Rec."Start Date";
            OldEndDate := Rec."End Date";
            OldStatus := Rec.Status;

            Rec.RenewSubscription();
            Rec.Modify(true);

            SafeRefreshDisplayInfo();
            SafeRefreshPage();
            SetConditionalFormatting();
            SetActionStates();

            if OldStatus <> Rec.Status then
                Message('Subscription "%1" renewed.\Old Status: %2 → %3\Old End Date: %4 → %5',
                    Rec."Service Name", OldStatus, Rec.Status, OldEndDate, Rec."End Date")
            else
                Message('Subscription "%1" renewed.\Old End Date: %2 → %3',
                    Rec."Service Name", OldEndDate, Rec."End Date");
        end;
    end;

    local procedure ProcessCancellation()
    var
        OldStatus: Enum "Subscription Status";
    begin
        if Rec."No." = '' then
            exit;

        if Confirm('Cancel subscription "%1"?', false, Rec."Service Name") then begin
            OldStatus := Rec.Status;

            Rec.CreateLedgerEntry("Subscription Change Type"::Cancellation, Rec."Start Date", Rec."End Date");
            Rec.Status := Rec.Status::Cancelled;
            Rec.Modify(true);

            SafeRefreshDisplayInfo();
            SafeRefreshPage();
            SetConditionalFormatting();
            SetActionStates();

            Message('Subscription "%1" status changed from %2 to %3.',
                Rec."Service Name", OldStatus, Rec.Status);
        end;
    end;

    local procedure SaveAndGoToList()
    var
        ManageSubscriptionsPage: Page "Manage Subscriptions";
        SubscriptionRec: Record "Subscription";
    begin
        if Rec."Service Name" = '' then
            exit;

        if Rec."Category Code" = '' then
            exit;

        if Rec.Amount = 0 then
            exit;

        if Rec."Subscription ID" = 0 then begin
            if ShouldCreateRecord() then
                Rec.Insert(true)
            else
                exit;
        end else
            Rec.Modify(true);

        SubscriptionRec.SetRange("No.", Rec."No.");
        ManageSubscriptionsPage.SetTableView(SubscriptionRec);
        CurrPage.Close();
        ManageSubscriptionsPage.Run();
    end;

    local procedure SetConditionalFormatting()
    begin
        StatusStyleExpr := Rec.GetStatusWithStyle(StatusStyleExpr);

        if Rec."End Date" <> 0D then
            if Rec."End Date" < Today then
                EndDateStyleExpr := 'Unfavorable'
            else if Rec."End Date" <= CalcDate('<+7D>', Today) then
                EndDateStyleExpr := 'Attention'
            else if Rec."End Date" <= CalcDate('<+30D>', Today) then
                EndDateStyleExpr := 'Standard'
            else
                EndDateStyleExpr := 'Favorable'
        else
            EndDateStyleExpr := 'Standard';
    end;

    local procedure SetActionStates()
    begin
        RenewEnabled := (Rec."No." <> '') and
                        (Rec.Status in [Rec.Status::Active, Rec.Status::Expired]) and
                        (Rec."Start Date" <> 0D) and
                        (Rec."End Date" <> 0D);

        CancelEnabled := (Rec."No." <> '') and
                         (Rec.Status = Rec.Status::Active);

        UsersEnabled := (Rec."No." <> '');
        EndUsersEnabled := (Rec."No." <> '');
    end;
}
