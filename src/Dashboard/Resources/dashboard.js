// ====== GLOBAL VARIABLES & CONSTANTS ======
let logoBase64 = "";
let pmSelectedIcon = "visa";

const PM_ICONS = [
  { key: "visa", label: "" },
  { key: "mastercard", label: "" },
  { key: "paypal", label: "" },
  { key: "amex", label: "" },
  { key: "applepay", label: "" },
  { key: "googlepay", label: "" },
  { key: "bank", label: "" },
  { key: "cash", label: "" },
  { key: "other", label: "" },
];

// Make InvokeExtensibilityMethod safe in browser preview
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod =
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod || function () {};

// ====== INITIALIZATION ======
document.addEventListener("DOMContentLoaded", function () {
  initializeDashboard();
  createAnimatedBackground();
});

// ====== UI INITIALIZATION ======
function initializeDashboard() {
  document.body.innerHTML = getDashboardHTML();
  setupNavigation();
}

function getDashboardHTML() {
  return `
    <div class="dashboard-container">
      <aside class="sidebar">
        <div class="logo">
          <div class="logo-icon">S</div>
          <span>SubsTracker</span>
        </div>
        <nav class="nav-menu">
          <a href="#" class="nav-link active">Dashboard</a>
          <a href="#" class="nav-link">Initial Setup</a>
          <a href="#" class="nav-link">Subscription</a>
          <a href="#" class="nav-link">Compliance</a>
          <a href="#" class="nav-link">Notification</a>
          <a href="#" class="nav-link">Company Information</a>
        </nav>
      </aside>
      <main class="main-content">
        <div class="welcome-message">
          <h2>Welcome to SubsTracker</h2>
          <p>Select an option from the sidebar to navigate to different sections.</p>
        </div>
      </main>
    </div>
  `;
}

// ====== NAVIGATION ======
function setupNavigation() {
  const navLinks = document.querySelectorAll(".nav-link");
  navLinks.forEach((link) => {
    link.addEventListener("click", handleNavigationClick);
  });
}

function handleNavigationClick(e) {
  e.preventDefault();
  const pageName = this.textContent.trim();
  setActiveNavigation(pageName);

  switch (pageName) {
    case "Subscription":
      showSubscriptionButtons();
      stopComplianceStatsTimer?.();
      startSubscriptionStatsTimer();
      break;

    case "Compliance":
      showComplianceButtons();
      stopSubscriptionStatsTimer?.();
      startComplianceStatsTimer?.();
      break;

    default:
      stopSubscriptionStatsTimer?.();
      stopComplianceStatsTimer?.();
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        pageName,
      ]);
      break;
  }
}

function setActiveNavigation(pageName) {
  const navLinks = document.querySelectorAll(".nav-link");
  navLinks.forEach((link) => {
    link.classList.remove("active");
    if (link.textContent.trim() === pageName) link.classList.add("active");
  });
}

// ====== SUBSCRIPTION FUNCTIONS ======
function showSubscriptionButtons() {
  const mainContent = document.querySelector(".main-content");
  mainContent.innerHTML = `
    <div id="subscription-stats-container">
      <div class="stats-container">
        <div class="stat-box purple">
          <div class="stat-label">Total Subscriptions</div>
          <div id="sub-total" class="stat-value">0</div>
        </div>
        <div class="stat-box green">
          <div class="stat-label">Active</div>
          <div id="sub-active" class="stat-value">0</div>
        </div>
        <div class="stat-box yellow">
          <div class="stat-label">Inactive</div>
          <div id="sub-inactive" class="stat-value">0</div>
        </div>
      </div>
    </div>

    <div class="subscription-grid">
      ${createSubscriptionCard(
        "Add Subscription",
        "Create new subscription plans and add customers",
        "✨"
      )}
      ${createSubscriptionCard(
        "Manage Subscriptions",
        "View, update, or delete existing subscriptions",
        "⚙️"
      )}
      ${createSubscriptionCard(
        "Active Subscriptions",
        "View currently active subscription plans",
        "✅"
      )}
      ${createSubscriptionCard(
        "Inactive Subscriptions",
        "See subscriptions that are inactive",
        "🚫"
      )}
      ${createSubscriptionCard(
        "Renewals This Month",
        "Track all upcoming renewals this month",
        "📅"
      )}
    </div>
  `;
  animateCards();
}

function renderSubscriptionStatistics(stats) {
  const s = stats || {};
  const elT = document.getElementById("sub-total");
  const elA = document.getElementById("sub-active");
  const elI = document.getElementById("sub-inactive");
  const elR = document.getElementById("sub-renewals"); // optional if you added 4th box

  if (elT) elT.textContent = s.total ?? 0;
  if (elA) elA.textContent = s.active ?? 0;
  if (elI) elI.textContent = s.inactive ?? 0;
  if (elR) elR.textContent = s.renewals ?? 0;
}

let subscriptionStatsTimer = null;

function requestSubscriptionStats() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getSubscriptionStats", []);
}

function startSubscriptionStatsTimer() {
  if (subscriptionStatsTimer) clearInterval(subscriptionStatsTimer);
  requestSubscriptionStats(); // immediate
  subscriptionStatsTimer = setInterval(requestSubscriptionStats, 5000); // 5s
}

function stopSubscriptionStatsTimer() {
  if (subscriptionStatsTimer) {
    clearInterval(subscriptionStatsTimer);
    subscriptionStatsTimer = null;
  }
}

// ====== COMPLIANCE FUNCTIONS ======
function showComplianceButtons() {
  const mainContent = document.querySelector(".main-content");
  mainContent.innerHTML = `
    <div id="compliance-stats-container">
      <div class="stats-container">
        <div class="stat-box purple">
          <div class="stat-label">Total (This Year)</div>
          <div id="stat-total" class="stat-value">0</div>
        </div>
        <div class="stat-box green">
          <div class="stat-label">Active</div>
          <div id="stat-active" class="stat-value">0</div>
        </div>
        <div class="stat-box yellow">
          <div class="stat-label">Pending</div>
          <div id="stat-pending" class="stat-value">0</div>
        </div>
      </div>
    </div>

    <div class="subscription-grid">
      ${createSubscriptionCard(
        "Setup New Compliance Item",
        "Add Compliance items",
        "✨"
      )}
      ${createSubscriptionCard(
        "Submit a Compliance",
        "Add or submit compliance data",
        "🗂️"
      )}
      ${createSubscriptionCard(
        "View Submitted Compliance",
        "See all compliance entries which was Submitted ",
        "📬"
      )}
      ${createSubscriptionCard(
        "Pending Compliance Submissions",
        "Check compliance items that are pending",
        "⏳"
      )}
      ${createSubscriptionCard(
        "This Month's Submissions",
        "Track all submissions made this month",
        "📆"
      )}
    </div>
  `;
  animateCards();
}

function renderComplianceStatistics(stats) {
  const totalEl = document.getElementById("stat-total");
  const activeEl = document.getElementById("stat-active");
  const pendingEl = document.getElementById("stat-pending");

  // If elements exist, update values without re-rendering (no flicker)
  if (totalEl && activeEl && pendingEl) {
    const s = stats || {};
    totalEl.textContent = s.total ?? 0;
    activeEl.textContent = s.active ?? 0;
    pendingEl.textContent = s.pending ?? 0;
    return;
  }

  // Fallback (first render only): build the boxes if they weren't present
  const container = document.getElementById("compliance-stats-container");
  if (container) {
    container.innerHTML = `
      <div class="stats-container">
        <div class="stat-box purple">
          <div class="stat-label">Total (This Year)</div>
          <div id="stat-total" class="stat-value">${
            (stats && stats.total) ?? 0
          }</div>
        </div>
        <div class="stat-box green">
          <div class="stat-label">Active</div>
          <div id="stat-active" class="stat-value">${
            (stats && stats.active) ?? 0
          }</div>
        </div>
        <div class="stat-box yellow">
          <div class="stat-label">Pending</div>
          <div id="stat-pending" class="stat-value">${
            (stats && stats.pending) ?? 0
          }</div>
        </div>
      </div>
    `;
  }
}

let complianceStatsTimer = null;

function requestComplianceStats() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
    "Compliance",
  ]);
}

function startComplianceStatsTimer() {
  if (complianceStatsTimer) clearInterval(complianceStatsTimer);
  requestComplianceStats(); // refresh immediately
  complianceStatsTimer = setInterval(requestComplianceStats, 5000); // every 5s
}

function stopComplianceStatsTimer() {
  if (complianceStatsTimer) {
    clearInterval(complianceStatsTimer);
    complianceStatsTimer = null;
  }
}

// ====== SUBSCRIPTION & COMPLIANCE CARDS COMMON FUNCTIONS ======
function createSubscriptionCard(title, description, icon) {
  return `
    <div class="subscription-card" onclick="navigateTo('${title.replace(
      /'/g,
      "\\'"
    )}')">
      <div class="icon-container">${icon}</div>
      <div class="card-title">${title}</div>
      <div class="card-description">${description}</div>
    </div>
  `;
}

function animateCards() {
  setTimeout(() => {
    const cards = document.querySelectorAll(".subscription-card");
    cards.forEach((card, index) => {
      card.style.opacity = "0";
      card.style.transform = "translateY(30px)";
      card.style.transition = "opacity 0.5s ease, transform 0.5s ease";
      setTimeout(() => {
        card.style.opacity = "1";
        card.style.transform = "translateY(0)";
      }, index * 100);
    });
  }, 50);
}

function navigateTo(label) {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
    label,
  ]);
}

function animateStats() {
  const boxes = document.querySelectorAll(".stat-box");
  boxes.forEach((box, idx) => {
    box.style.opacity = "0";
    box.style.transform = "translateY(20px)";
    box.style.transition = "opacity 0.4s ease, transform 0.4s ease";
    setTimeout(() => {
      box.style.opacity = "1";
      box.style.transform = "translateY(0)";
    }, idx * 150);
  });
}

// ====== NOTIFICATION TABS ======
function showNotificationTabs() {
  const mainContent = document.querySelector(".main-content");
  mainContent.innerHTML = `
    <div class="notification-container">
      <div class="tab-header">
        <button class="tab-button active" onclick="switchTab('subscription')">Subscription</button>
        <button class="tab-button" onclick="switchTab('compliance')">Compliance</button>
      </div>
      <div class="tab-content active" id="subscription-tab">
        <div class="tab-loading" id="subscription-loading">Loading Subscription Notifications...</div>
      </div>
      <div class="tab-content" id="compliance-tab">
        <div class="tab-loading" id="compliance-loading">Loading Compliance Notifications...</div>
      </div>
    </div>
  `;
  loadTabContent("subscription", 70132, "Subscription Notification");
}

function switchTab(tabName) {
  // Update tab buttons
  const tabButtons = document.querySelectorAll(".tab-button");
  tabButtons.forEach((button) => {
    button.classList.remove("active");
    if (button.textContent.toLowerCase() === tabName)
      button.classList.add("active");
  });

  // Update tab content
  const tabContents = document.querySelectorAll(".tab-content");
  tabContents.forEach((content) => content.classList.remove("active"));
  const activeTab = document.getElementById(`${tabName}-tab`);
  if (activeTab) activeTab.classList.add("active");

  // Load content based on selected tab
  if (tabName === "subscription") {
    loadTabContent("subscription", 70132, "Subscription Notification");
  } else if (tabName === "compliance") {
    loadTabContent("compliance", 70131, "Notification");
  }
}

function loadTabContent(tabName, pageId, pageTitle) {
  const tabContent = document.getElementById(`${tabName}-tab`);
  const loadingElement = document.getElementById(`${tabName}-loading`);

  if (!tabContent || !loadingElement) return;
  if (tabContent.querySelector(".page-embed")) return;

  setTimeout(() => {
    loadingElement.innerHTML = `
      <div style="text-align:center; padding:20px;">
        <h3 style="color:white; margin-bottom:20px; font-size:24px;">${pageTitle}</h3>
        <div style="background: rgba(255,255,255,.1); backdrop-filter: blur(10px); padding:30px; border-radius:16px; border:1px solid rgba(255,255,255,.1);">
          <p style="color: rgba(255,255,255,.8); margin-bottom:16px;">Business Central Page Integration</p>
          <p style="color: rgba(255,255,255,.6); font-size:16px;">Page ID: ${pageId} - "${pageTitle}"</p>
          <button class="btn" onclick="openBusinessCentralPage('${
            tabName.charAt(0).toUpperCase() + tabName.slice(1)
          } Notifications')">Open in Business Central</button>
        </div>
      </div>
    `;
  }, 500);
}

function openBusinessCentralPage(actionName) {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
    actionName,
  ]);
}

// ====== COMPANY INFORMATION ======
function displayCompanyInformation(companyData) {
  const mainContent = document.querySelector(".main-content");
  mainContent.innerHTML = `
    <div class="company-container">
      <h1 class="company-title">Company Details</h1>
      <p class="company-subtitle">Manage company information, departments, employees, and system settings.</p>
      <div class="tab-header">
        <button class="tab-button-company active" onclick="switchCompanyTab('company')"><span class="tab-icon">📁</span> Company Information</button>
        <button class="tab-button-company" onclick="switchCompanyTab('department')"><span class="tab-icon">📋</span> Department List</button>
        <button class="tab-button-company" onclick="switchCompanyTab('employee')"><span class="tab-icon">👥</span> Employee</button>
        <button class="tab-button-company" onclick="switchCompanyTab('subscription')"><span class="tab-icon">❄️</span> Subscription Category</button>
        <button class="tab-button-company" onclick="switchCompanyTab('user')"><span class="tab-icon">👤</span> User Management</button>
      </div>
      <div class="tab-content-company active" id="company-tab">
        <h3 class="section-title">Company Information</h3>
        <p class="section-subtitle">Update your company details and branding</p>
        <form id="company-form">
          <div class="form-row">
            <div class="form-group">
              <label for="company-name">Company Name</label>
              <input type="text" id="company-name" value="${
                companyData.general.name || ""
              }" placeholder="Enter company name">
            </div>
            <div class="form-group logo-group">
              <label>Company Logo</label>
              <div class="logo-upload">
                <input type="file" id="logo-upload" accept="image/png, image/jpeg" style="display:none;">
                <label for="logo-upload" class="upload-label"><span class="upload-icon">↑</span>Upload Logo</label>
                <p>PNG, JPG up to 5MB</p>
                <img id="logo-preview" src="${
                  companyData.general.logo
                    ? "data:image/png;base64," + companyData.general.logo
                    : ""
                }" style="${companyData.general.logo ? "" : "display:none;"}">
              </div>
            </div>
          </div>
          <div class="form-group">
            <label for="address">Address</label>
            <input type="text" id="address" value="${
              companyData.address.address || ""
            }" placeholder="Enter company address">
          </div>
          <div class="form-group">
            <label for="country">Country</label>
            <input type="text" id="country" value="${
              companyData.address.countryRegionCode || ""
            }" placeholder="Enter country">
          </div>
          <div class="form-group">
            <label for="financial-year">Financial Year End</label>
            <input type="text" id="financial-year" placeholder="dd-mm-yyyy">
          </div>
          <button type="button" class="btn save-btn" onclick="saveCompanyInformation()">Save Company Information</button>
        </form>
      </div>
     <div class="tab-content-company" id="department-tab">
  <div class="form-row" style="margin-bottom:12px;">
    <button type="button" class="btn" onclick="openAddDepartmentPage()">Add Department</button>
  </div>
  <div id="department-list" class="payment-list"></div>
</div>
      <div class="tab-content-company" id="employee-tab"><p>Employee content coming soon.</p></div>
      <div class="tab-content-company" id="subscription-tab"><p>Subscription Category content coming soon.</p></div>
      <div class="tab-content-company" id="user-tab"><p>User Management content coming soon.</p></div>
    </div>
  `;

  // Setup logo upload handler
  setupLogoUploadHandler();

  // Animate container
  animateContainer(mainContent.querySelector(".company-container"));
}

function setupLogoUploadHandler() {
  const fileInput = document.getElementById("logo-upload");
  const preview = document.getElementById("logo-preview");

  fileInput.addEventListener("change", function (e) {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = function (event) {
        preview.src = event.target.result;
        preview.style.display = "block";
        logoBase64 = event.target.result.split(",")[1];
      };
      reader.readAsDataURL(file);
    }
  });
}

function switchCompanyTab(tabName) {
  const tabButtons = document.querySelectorAll(".tab-button-company");
  tabButtons.forEach((button) => {
    button.classList.remove("active");
    if (button.textContent.toLowerCase().includes(tabName))
      button.classList.add("active");
  });

  const tabContents = document.querySelectorAll(".tab-content-company");
  tabContents.forEach((c) => c.classList.remove("active"));
  const activeTab = document.getElementById(`${tabName}-tab`);
  if (activeTab) activeTab.classList.add("active");

  // NEW: fetch departments when opening Department tab
  if (tabName === "department") {
    loadDepartments();
  }
}

function saveCompanyInformation() {
  const companyData = {
    general: {
      name: document.getElementById("company-name").value,
      logoBase64: logoBase64,
    },
    address: {
      address: document.getElementById("address").value,
      countryRegionCode: document.getElementById("country").value,
    },
  };

  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("updateCompanyInformation", [
    companyData,
  ]);
}

// ====== INITIAL SETUP ======
function displayInitialSetup(setupData) {
  const mainContent = document.querySelector(".main-content");
  mainContent.innerHTML = `
    <div class="company-container">
      <h1 class="company-title">Initial Setup</h1>
      <p class="company-subtitle">Configure number series, payment methods, and reminders.</p>

      <div class="tab-header">
        <button class="tab-button-company active" onclick="switchInitialSetupTab('number-series')">
          <span class="tab-icon">🔢</span> Number Series
        </button>
        <button class="tab-button-company" onclick="switchInitialSetupTab('payment-methods')">
          <span class="tab-icon">💳</span> Payment Methods
        </button>
        <button class="tab-button-company" onclick="switchInitialSetupTab('reminder-policy')">
          <span class="tab-icon">🔔</span> Reminder Policy
        </button>
      </div>

      <!-- Number Series -->
      <div class="tab-content-company active" id="number-series-tab">
        <h3 class="section-title">Number Series</h3>
        <p class="section-subtitle">Configure number series for subscriptions and compliance.</p>
        <form id="number-series-form">
          <div class="form-row">
            <div class="form-group">
              <label for="subscription-nos">Subscription Nos.</label>
              <input type="text" id="subscription-nos" value="${
                setupData.setup.subscriptionNos || ""
              }" disabled>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="compliance-nos">Compliance Nos.</label>
              <input type="text" id="compliance-nos" value="${
                setupData.setup.complianceNos || ""
              }" disabled>
            </div>
          </div>

          <!-- NEW: read-only mirror of Employee series -->
          <div class="form-row">
            <div class="form-group">
              <label for="employee-ext-nos">Employee Nos. (managed via “Assign Manually”)</label>
              <input type="text" id="employee-ext-nos" value="${
                setupData.setup.employeeExtNos || ""
              }" disabled>
            </div>
          </div>

          <div class="form-row">
            <button type="button" class="btn" onclick="autoCreateAllNumberSeries()">Auto Create Number Series</button>
            <button type="button" class="btn" onclick="openInitialSetupManually()">Assign Manually</button>
          </div>
        </form>
      </div>

      <!-- Payment Methods -->
      <div class="tab-content-company" id="payment-methods-tab">
        <h3 class="section-title">Payment Methods</h3>
        <p class="section-subtitle">Create and manage supported payment methods.</p>
        <div class="form-row">
          <button type="button" class="btn" onclick="openPaymentMethodModal()">Add Methods</button>
          <button type="button" class="btn" onclick="openPaymentMethodsPage()">Open Payment Methods Page</button>
        </div>
        <div id="payment-methods-list" class="payment-list"></div>
        <!-- modal stays as-is -->
      </div>

      <!-- Reminder Policy -->
      <div class="tab-content-company" id="reminder-policy-tab">
        <p>Reminder Policy configuration coming soon.</p>
      </div>
    </div>
  `;

  animateContainer(mainContent.querySelector(".company-container"));
}

function saveInitialSetup() {
  const payload = {
    setup: {
      subscriptionNos: document.getElementById("subscription-nos").value.trim(),
      complianceNos: document.getElementById("compliance-nos").value.trim(),
      employeeExtNos: document.getElementById("employee-ext-nos").value.trim(),
    },
  };
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("updateInitialSetup", [
    payload,
  ]);
}

function openEmployeeExtSetup() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
    "Open Employee Ext Setup",
  ]);
}

function switchInitialSetupTab(tabName) {
  const tabButtons = document.querySelectorAll(".tab-button-company");
  tabButtons.forEach((button) => {
    button.classList.remove("active");
    if (button.textContent.toLowerCase().includes(tabName.replace("-", " ")))
      button.classList.add("active");
  });

  const tabContents = document.querySelectorAll(".tab-content-company");
  tabContents.forEach((content) => content.classList.remove("active"));
  const activeTab = document.getElementById(`${tabName}-tab`);
  if (activeTab) activeTab.classList.add("active");

  // Refresh list when Payment Methods is selected
  if (tabName === "payment-methods") {
    loadPaymentMethods();
  }
}

function autoCreateAllNumberSeries() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
    "Auto Create All Number Series",
  ]);
}

function openInitialSetupManually() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "OnNavigationClick",
    ["Assign Manually"],
    false,
    function () {
      // after the card closes, reload the data so UI shows new series immediately
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Initial Setup",
      ]);
    }
  );
}

function OpenInitialSetupPage() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
    "Initial Setup",
  ]);
}

// ====== PAYMENT METHODS ======
function buildIconGrid() {
  const grid = document.getElementById("pm-icon-grid");
  if (!grid) return;

  grid.innerHTML = PM_ICONS.map(
    (i) => `
      <div class="icon-pill ${i.key === pmSelectedIcon ? "active" : ""}"
           data-icon="${i.key}"
           title="${i.key}">${i.label}</div>
    `
  ).join("");

  grid.querySelectorAll(".icon-pill").forEach((el) => {
    el.addEventListener("click", () => {
      pmSelectedIcon = el.getAttribute("data-icon");
      grid
        .querySelectorAll(".icon-pill")
        .forEach((x) => x.classList.remove("active"));
      el.classList.add("active");
    });
  });
}

function openPaymentMethodModal() {
  const modal = document.getElementById("pm-modal");
  if (!modal) return;

  // Reset form
  document.getElementById("pm-title").value = "";
  document.getElementById("pm-type").value = "";
  document.getElementById("pm-desc").value = "";
  document.getElementById("pm-managedby").value = "";
  document.getElementById("pm-expires").value = "";
  pmSelectedIcon = "visa";

  // Build icon grid
  buildIconGrid();

  // Show modal
  modal.style.display = "flex";
}

function closePaymentMethodModal() {
  const modal = document.getElementById("pm-modal");
  if (modal) modal.style.display = "none";
}

function createPaymentMethodFromModal() {
  const title = document.getElementById("pm-title").value.trim();
  const type = document.getElementById("pm-type").value.trim();

  if (!title || !type) {
    alert("Please provide both Title and Type.");
    return;
  }

  const payload = {
    title,
    type,
    description: document.getElementById("pm-desc").value.trim(),
    icon: pmSelectedIcon,
    managedBy: document.getElementById("pm-managedby").value.trim(),
    expiresAt: document.getElementById("pm-expires").value.trim(),
  };

  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "savePaymentMethod",
    [payload],
    false,
    function () {
      loadPaymentMethods();
      closePaymentMethodModal();
    }
  );
}

function openPaymentMethodsPage() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "OnNavigationClick",
    ["Manage Payment Methods"],
    false,
    function () {
      loadPaymentMethods();
    }
  );
}

function loadPaymentMethods() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getPaymentMethods", []);
}

// Called from AL
function renderPaymentMethods(methods) {
  // If AL passed a JSON array object, convert to list of JS objects
  const arr = Array.isArray(methods) ? methods : methods?.value || [];
  const list = document.getElementById("payment-methods-list");

  if (!list) return;

  list.innerHTML = arr.map(createPaymentCardHTML).join("");
  animateCards();
}

function createPaymentCardHTML(method) {
  return `
    <div class="payment-card" onclick="editPaymentMethod('${method.id}')">
      <div class="icon-pill" data-icon="${method.icon}"></div>
      <div class="title">${escapeHtml(method.title)}</div>
      <div class="meta">${escapeHtml(method.description || "")}</div>
    </div>
  `;
}

function editPaymentMethod(id) {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "OnNavigationClick",
    ["EditPaymentMethod:" + id],
    false,
    function () {
      loadPaymentMethods();
    }
  );
}

function displayIconLabel(key) {
  const icon = PM_ICONS.find((i) => i.key === key);
  return icon ? icon.label : "💳";
}

// ====== UTILITY FUNCTIONS ======
function createAnimatedBackground() {
  const body = document.body;
  ["blob-1", "blob-2", "blob-3"].forEach((cls) => {
    const div = document.createElement("div");
    div.className = "bg-blob " + cls;
    body.appendChild(div);
  });
}

function animateContainer(container) {
  if (!container) return;

  container.style.opacity = "0";
  container.style.transform = "translateY(20px)";
  container.style.transition = "opacity 0.5s ease, transform 0.5s ease";

  setTimeout(() => {
    container.style.opacity = "1";
    container.style.transform = "translateY(0)";
  }, 50);
}

function escapeHtml(s) {
  return (s || "").replace(
    /[&<>"']/g,
    (m) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[
        m
      ])
  );
}

// optional: pause when tab hidden, resume when visible on Compliance
document.addEventListener("visibilitychange", () => {
  const onCompliance =
    document.querySelector(".nav-link.active")?.textContent.trim() ===
    "Compliance";
  if (document.hidden) stopComplianceStatsTimer();
  else if (onCompliance) startComplianceStatsTimer();
});

window.addEventListener("beforeunload", stopComplianceStatsTimer);

function openAddDepartmentPage() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "OnNavigationClick",
    ["Add Department"],
    false,
    function () {
      // refresh list after user closes the card
      loadDepartments();
    }
  );
}

function loadDepartments() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getDepartments", []);
}

// Called from AL
function renderDepartments(departments) {
  const arr = Array.isArray(departments)
    ? departments
    : departments?.value || [];
  const list = document.getElementById("department-list");
  if (!list) return;

  if (arr.length === 0) {
    list.innerHTML = `<div style="opacity:.8;">No departments found.</div>`;
    return;
  }

  list.innerHTML = arr
    .map(
      (d) => `
      <div class="payment-card">
        <div class="title">${escapeHtml(d.name || "")}</div>
        <div class="meta">${escapeHtml(d.code || "")}</div>
      </div>`
    )
    .join("");
}
