controladdin SubsTrackerDashboard
{
    RequestedHeight = 600;
    RequestedWidth = 1200;
    MinimumHeight = 400;
    MinimumWidth = 800;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = '../Dashboard/Resources/dashboard.js';
    StyleSheets = '../Dashboard/Resources/Dashboard.css';

    // Existing events
    event OnNavigationClick(PageName: Text);
    event updateCompanyInformation(CompanyData: JsonObject);
    event updateInitialSetup(SetupData: JsonObject);

    // New events for Payment Methods
    event savePaymentMethod(PaymentMethodData: JsonObject);
    event getPaymentMethods();

    // Existing procedures
    procedure setActiveNavigation(PageName: Text);
    procedure displayCompanyInformation(CompanyData: JsonObject);
    procedure displayInitialSetup(SetupData: JsonObject);

    // New procedure for Payment Methods
    procedure renderPaymentMethods(PaymentMethods: JsonArray);
}
