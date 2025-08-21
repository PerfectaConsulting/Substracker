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

    event OnNavigationClick(PageName: Text);
    event updateCompanyInformation(CompanyData: JsonObject);
    event updateInitialSetup(SetupData: JsonObject);

    event savePaymentMethod(PaymentMethodData: JsonObject);
    event getPaymentMethods();

    procedure setActiveNavigation(PageName: Text);
    procedure displayCompanyInformation(CompanyData: JsonObject);
    procedure displayInitialSetup(SetupData: JsonObject);
    procedure renderPaymentMethods(PaymentMethods: JsonArray);

    // NEW
    procedure renderComplianceStatistics(Stats: JsonObject);


    // Ask AL for subscription stats
event getSubscriptionStats();

// AL -> JS: render subscription stats
procedure renderSubscriptionStatistics(Stats: JsonObject);

// Ask AL to send departments
event getDepartments();
procedure renderDepartments(Departments: JsonArray);

// Add to interface for JS <-> AL bridge
event getEmployees();
procedure renderEmployees(Employees: JsonArray);


 event getSubscriptionCategories();
  procedure renderSubscriptionCategories(Categories: JsonArray);

     procedure showMainDashboard();
     event getComplianceStats(FromDateTxt: Text; ToDateTxt: Text);

}
