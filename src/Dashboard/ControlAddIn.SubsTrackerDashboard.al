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
    Images      = '../Dashboard/Resources/logo.png'; 

    // Events (JS -> AL)
    event OnNavigationClick(PageName: Text);
    event updateCompanyInformation(CompanyData: JsonObject);
    event updateInitialSetup(SetupData: JsonObject);
    event savePaymentMethod(PaymentMethodData: JsonObject);
    event getPaymentMethods();
    event getSubscriptionStats();
    event getDepartments();
    event getEmployees();
    event getSubscriptionCategories();
    event getComplianceStats(FromDateTxt: Text; ToDateTxt: Text);
    event getSubscriptions(Filter: JsonObject);
    event getCompliances(Filter: JsonObject);            // NEW

    // Procedures (AL -> JS)
    procedure setActiveNavigation(PageName: Text);
    procedure showMainDashboard();
    procedure displayCompanyInformation(CompanyData: JsonObject);
    procedure displayInitialSetup(SetupData: JsonObject);
    procedure renderPaymentMethods(PaymentMethods: JsonArray);
    procedure renderSubscriptionStatistics(Stats: JsonObject);
    procedure renderComplianceStatistics(Stats: JsonObject);
    procedure renderDepartments(Departments: JsonArray);
    procedure renderEmployees(Employees: JsonArray);
    procedure renderSubscriptionCategories(Categories: JsonArray);
    procedure renderSubscriptions(Subscriptions: JsonArray);
    procedure renderCompliances(Compliances: JsonArray); // NEW
}
