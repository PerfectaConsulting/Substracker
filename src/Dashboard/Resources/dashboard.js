/* =========================================================
   SubsTracker Dashboard Control Add-in (BC 26)
   Sections:
   1) Config & State
   2) Bootstrap
   3) Layout & Templates
   4) Navigation
   5) Filters
   6) KPIs & Rendering
   7) Polling Manager
   8) Data Bridges (BC <-> JS)
   9) List Rendering (Payments/Depts/Employees/Categories)
   10) Utilities
   ========================================================= */

/* =========================
   1) Config & State
   ========================= */
const POLL_MS = 5000;

const PM_ICONS = [
  { key: "visa", label: "VISA" },
  { key: "mastercard", label: "MC" },
  { key: "paypal", label: "PP" },
  { key: "amex", label: "AMEX" },
  { key: "applepay", label: "" },
  { key: "googlepay", label: "G" },
  { key: "bank", label: "🏦" },
  { key: "cash", label: "💵" },
  { key: "other", label: "…" },
];

let pmSelectedIcon = "visa";
let logoBase64 = "";
// --- Resolve folder where this JS file lives (…/Dashboard/Resources/) ---
let ASSET_BASE = "";
(function resolveAssetBase() {
  const s = document.querySelector('script[src*="dashboard.js"]');
  if (s && s.src) {
    ASSET_BASE = s.src.replace(/dashboard\.js(\?.*)?$/i, "");
  }
})();

const Poller = {
  sub: null,
  comp: null,
  start(name, fn) {
    this.stop(name);
    fn();
    this[name] = setInterval(fn, POLL_MS);
  },
  stop(name) {
    if (this[name]) {
      clearInterval(this[name]);
      this[name] = null;
    }
  },
  stopAll() {
    this.stop("sub");
    this.stop("comp");
  },
};

// Safe bridge for preview environments
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod =
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod || function () {};

/* =========================
   2) Bootstrap
   ========================= */

document.addEventListener("DOMContentLoaded", () => {
  initTheme(); // set data-theme from localStorage (default = dark)
  initializeDashboard(); // builds shell (includes toggle markup)
  // createAnimatedBackground(); // animations OFF by default
});

/* =========================
   3) Layout & Templates
   ========================= */
function initializeDashboard() {
  document.body.innerHTML = getShellHTML(); // inject shell
  primeLogo();
  setupNavigation(); // wire nav
  setupThemeToggle(); // wire THEME TOGGLE (now that it exists)
  showWelcome(); // initial content
}

function getShellHTML() {
  return `
    <div class="dashboard-container">
      <aside class="sidebar">
        <div class="logo">
  <img id="brand-logo" class="logo-img" alt="SubsTracker logo" hidden>
  <div id="brand-fallback" class="logo-icon" aria-hidden="true"> </div>
  <span class="brand">
    <span class="brand-left">SubsTracker</span>
  </span>
</div>


        <div class="sidebar-actions">
          <button id="theme-toggle" class="theme-toggle" type="button" aria-pressed="false" title="Switch theme">
            <span class="toggle-icon" aria-hidden="true">🌙</span>
            <span class="toggle-text">Dark</span>
          </button>
        </div>

        <nav class="nav-menu">
          <a href="#" class="nav-link active">Dashboard</a>
          <a href="#" class="nav-link">Subscription</a>
          <a href="#" class="nav-link">Compliance</a>
          <a href="#" class="nav-link">Notification</a>
          <a href="#" class="nav-link">Company Information</a>
          <a href="#" class="nav-link">Setup & Configuration</a>
        </nav>
      </aside>
      <main class="main-content"></main>
    </div>
  `;
}

function showWelcome() {
  const main = document.querySelector(".main-content");
  if (!main) return;
  main.innerHTML = `
    <div class="welcome-message">
      <h2>Welcome to SubsTracker</h2>
      <p>Select an option from the sidebar to navigate to different sections.</p>
    </div>
  `;
}

function getMainDashboardHTML() {
  return `
    <div class="company-container">
      <h1 class="company-title">Dashboard</h1>
      <p class="company-subtitle">At-a-glance analytics for Subscriptions and Compliance</p>

      <div class="tab-header">
        <button class="tab-button-company active" data-dashtab="subscription"><span class="tab-icon">📦</span> Subscription</button>
        <button class="tab-button-company" data-dashtab="compliance"><span class="tab-icon">✅</span> Compliance</button>
      </div>

      <div class="tab-content-company" id="dash-filters">
        <div class="form-row" style="margin-bottom:16px">
          <div class="form-group">
            <label for="dash-range">Time Range</label>
            <select id="dash-range">
              <option value="3m">Last 3 months</option>
              <option value="6m">Last 6 months</option>
              <option value="12m">Last 12 months</option>
              <option value="ytd" selected>Year-to-date</option>
            </select>
          </div>
          <div class="form-group">
            <label for="dash-category">Category</label>
            <select id="dash-category">
              <option value="">All Categories</option>
            </select>
          </div>
        </div>
      </div>

      <div id="dash-subscription">
       <div class="stats-container" style="margin-top:20px;">

          <div class="stat-box purple"><div class="stat-label">Monthly Spend</div><div id="sub-kpi-monthly" class="stat-value">—</div></div>
          <div class="stat-box purple"><div class="stat-label">Yearly Spend</div><div id="sub-kpi-yearly" class="stat-value">—</div></div>
          <div class="stat-box green"><div class="stat-label">Active Subscriptions</div><div id="sub-kpi-active" class="stat-value">0</div></div>
          <div class="stat-box yellow"><div class="stat-label">Upcoming Renewals</div><div id="sub-kpi-renewals" class="stat-value">0</div></div>
        </div>

        <div class="subscription-grid" style="margin-top:10px">
          <button class="subscription-card" data-action="open-sub-trend">
            <div class="icon-container">📈</div>
            <div class="card-title">Spending Trends</div>
            <div class="card-description">Monthly spend over the selected time range</div>
          </button>
          <div class="subscription-card">
            <div class="icon-container">🧩</div>
            <div class="card-title">Category Breakdown</div>
            <div class="card-description">Split by subscription category</div>
          </div>
        </div>
      </div>

      <div id="dash-compliance" style="display:none">
        <div class="stats-container" style="margin-top:16px">
          <div class="stat-box purple"><div class="stat-label">Yearly Spend</div><div id="stat-yearly" class="stat-value">—</div></div>
          <div class="stat-box green"><div class="stat-label">Active</div><div id="stat-active" class="stat-value">0</div></div>
          <div class="stat-box yellow"><div class="stat-label">Pending</div><div id="stat-pending" class="stat-value">0</div></div>
        </div>

        <div class="subscription-grid" style="margin-top:10px">
          <button class="subscription-card full-span" data-action="open-comp-trend">
            <div class="icon-container">📈</div>
            <div>
              <div class="card-title">Spending Trends</div>
              <div class="card-description">Monthly spend over the selected time range</div>
            </div>
          </button>
        </div>
      </div>
    </div>
  `;
}

function getInitialSetupHTML(setupData) {
  return `
    <div class="company-container">
      <h1 class="company-title">Setup & Configuration</h1>
      <p class="company-subtitle">Configure number series, payment methods, and reminders.</p>

      <div class="tab-header">
        <button class="tab-button-company active" data-initialtab="number-series"><span class="tab-icon">🔢</span> Number Series</button>
        <button class="tab-button-company" data-initialtab="payment-methods"><span class="tab-icon">💳</span> Payment Methods</button>
        <button class="tab-button-company" data-initialtab="reminder-policy"><span class="tab-icon">🔔</span> Reminder Policy</button>
      </div>

      <div class="tab-content-company active" id="number-series-tab">
        <h3 class="section-title">Number Series</h3>
        <p class="section-subtitle">Configure number series for subscriptions and compliance.</p>
        <form id="number-series-form">
          <div class="form-row">
            <div class="form-group">
              <label for="subscription-nos">Subscription Nos.</label>
              <input type="text" id="subscription-nos" value="${escapeHtml(
                setupData?.setup?.subscriptionNos || ""
              )}" disabled>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="compliance-nos">Compliance Nos.</label>
              <input type="text" id="compliance-nos" value="${escapeHtml(
                setupData?.setup?.complianceNos || ""
              )}" disabled>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="employee-ext-nos">Employee Nos. (managed via “Assign Manually”)</label>
              <input type="text" id="employee-ext-nos" value="${escapeHtml(
                setupData?.setup?.employeeExtNos || ""
              )}" disabled>
            </div>
          </div>
          <div class="form-row">
            <button type="button" class="btn" data-action="auto-create-series">Auto Create Number Series</button>
            <button type="button" class="btn" data-action="open-initial-manual">Assign Manually</button>
          </div>
        </form>
      </div>

      <div class="tab-content-company" id="payment-methods-tab">
        <h3 class="section-title">Payment Methods</h3>
        <p class="section-subtitle">Create and manage supported payment methods.</p>
        <div class="form-row">
          <button type="button" class="btn" data-action="open-pm-modal">Add Methods</button>
          <button type="button" class="btn" data-action="open-pm-page">Open Payment Methods Page</button>
        </div>
        <div id="payment-methods-list" class="payment-list"></div>

        <div id="pm-modal" class="modal-overlay">
          <div class="modal">
            <div class="modal-header">
              <div class="modal-title">Create new method</div>
              <button class="modal-close" data-action="close-pm-modal">×</button>
            </div>
            <div class="modal-body">
              <div class="form-group">
                <label for="pm-title">Title (*)</label>
                <input type="text" id="pm-title" placeholder="Title">
              </div>
              <div class="form-group">
                <label for="pm-type">Type (*)</label>
                <select id="pm-type">
                  <option value="">Select type</option>
                  <option value="Credit Card">Credit Card</option>
                  <option value="Debit Card">Debit Card</option>
                  <option value="Bank Transfer">Bank Transfer</option>
                  <option value="Cash">Cash</option>
                  <option value="Digital Wallet">Digital Wallet</option>
                </select>
              </div>
              <div class="form-group">
                <label for="pm-desc">Description</label>
                <input type="text" id="pm-desc" placeholder="Description">
              </div>
              <div class="form-group">
                <label>Card Image</label>
                <div class="icon-grid" id="pm-icon-grid"></div>
              </div>
              <div class="modal-row">
                <div class="form-group">
                  <label for="pm-managedby">Managed by</label>
                  <input type="text" id="pm-managedby" placeholder="Manager name">
                </div>
                <div class="form-group">
                  <label for="pm-expires">Expires at</label>
                  <input type="date" id="pm-expires">
                </div>
              </div>
            </div>
            <div class="modal-actions">
              <button class="btn" data-action="close-pm-modal">Cancel</button>
              <button class="btn" data-action="create-pm">Create</button>
            </div>
          </div>
        </div>
      </div>

      <div class="tab-content-company" id="reminder-policy-tab">
        <p>Reminder Policy configuration coming soon.</p>
      </div>
    </div>
  `;
}

function getCompanyInfoHTML(companyData) {
  const logo = companyData?.general?.logo
    ? `data:image/png;base64,${companyData.general.logo}`
    : "";
  return `
    <div class="company-container">
      <h1 class="company-title">Company Details</h1>
      <p class="company-subtitle">Manage company information, departments, employees, and system settings.</p>

      <div class="tab-header">
        <button class="tab-button-company active" data-companytab="company"><span class="tab-icon">📁</span> Company Information</button>
        <button class="tab-button-company" data-companytab="department"><span class="tab-icon">📋</span> Department List</button>
        <button class="tab-button-company" data-companytab="employee"><span class="tab-icon">👥</span> Employee</button>
        <button class="tab-button-company" data-companytab="subscription"><span class="tab-icon">❄️</span> Subscription Category</button>
        <button class="tab-button-company" data-companytab="user"><span class="tab-icon">👤</span> User Management</button>
      </div>

      <div class="tab-content-company active" id="company-tab">
        <h3 class="section-title">Company Information</h3>
        <p class="section-subtitle">Update your company details and branding</p>
        <form id="company-form">
          <div class="form-row">
            <div class="form-group">
              <label for="company-name">Company Name</label>
              <input type="text" id="company-name" value="${escapeHtml(
                companyData?.general?.name || ""
              )}" placeholder="Enter company name">
            </div>
            <div class="form-group logo-group">
              <label>Company Logo</label>
              <div class="logo-upload">
                <input type="file" id="logo-upload" accept="image/png, image/jpeg" style="display:none;">
                <label for="logo-upload" class="upload-label"><span class="upload-icon">↑</span>Upload Logo</label>
                <p>PNG, JPG up to 5MB</p>
                <img id="logo-preview" src="${logo}" style="${
    logo ? "" : "display:none;"
  }">
              </div>
            </div>
          </div>
          <div class="form-group">
            <label for="address">Address</label>
            <input type="text" id="address" value="${escapeHtml(
              companyData?.address?.address || ""
            )}" placeholder="Enter company address">
          </div>
          <div class="form-group">
            <label for="country">Country</label>
            <input type="text" id="country" value="${escapeHtml(
              companyData?.address?.countryRegionCode || ""
            )}" placeholder="Enter country">
          </div>
          <div class="form-group">
            <label for="financial-year">Financial Year End</label>
            <input type="date" id="financial-year">
          </div>
          <button type="button" class="btn save-btn" data-action="save-company">Save Company Information</button>
        </form>
      </div>

      <div class="tab-content-company" id="department-tab">
        <div class="form-row" style="margin-bottom:12px;">
          <button type="button" class="btn" data-action="add-department">Add Department</button>
        </div>
        <div id="department-list" class="payment-list"></div>
      </div>

      <div class="tab-content-company" id="employee-tab">
        <div class="form-row" style="margin-bottom:12px;">
          <button type="button" class="btn" data-action="add-employee">Add Employee</button>
        </div>
        <div id="employee-list" class="payment-list"></div>
      </div>

      <div class="tab-content-company" id="subscription-tab">
        <div class="form-row" style="margin-bottom:12px;">
          <button type="button" class="btn" data-action="add-subscription-category">Add Subscription Categories</button>
        </div>
        <div id="subscription-category-list" class="payment-list"></div>
      </div>

      <div class="tab-content-company" id="user-tab"><p>User Management content coming soon.</p></div>
    </div>
  `;
}

/* =========================
   4) Navigation
   ========================= */
function setupNavigation() {
  document.querySelectorAll(".nav-link").forEach((a) => {
    a.addEventListener("click", (e) => {
      e.preventDefault();
      const label = a.textContent.trim();
      setActiveNavigation(label);
      switch (label) {
        case "Dashboard":
          showMainDashboard();
          break;
        case "Setup & Configuration":
          Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
            "OnNavigationClick",
            ["Setup & Configuration"]
          );
          break;
        case "Subscription":
          showSubscriptionButtons();
          break;
        case "Compliance":
          showComplianceButtons();
          break;
        case "Notification":
          showNotificationTabs();
          break;
        case "Company Information":
          Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
            "OnNavigationClick",
            ["Company Information"]
          );
          break;
      }
    });
  });
}

function setActiveNavigation(pageName) {
  document.querySelectorAll(".nav-link").forEach((link) => {
    link.classList.toggle("active", link.textContent.trim() === pageName);
  });
  // Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
  //   pageName,
  // ]);
}

function showMainDashboard() {
  const main = document.querySelector(".main-content");
  if (!main) return;
  main.innerHTML = getMainDashboardHTML();

  document.querySelectorAll("[data-dashtab]").forEach((btn) => {
    btn.addEventListener("click", () =>
      switchMainDashTab(btn.getAttribute("data-dashtab"))
    );
  });

  document
    .getElementById("dash-range")
    ?.addEventListener("change", applyDashboardFilters);
  document
    .getElementById("dash-category")
    ?.addEventListener("change", applyDashboardFilters);

  document
    .querySelector("[data-action='open-sub-trend']")
    ?.addEventListener("click", () => {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Open Subscription Chart",
      ]);
    });
  document
    .querySelector("[data-action='open-comp-trend']")
    ?.addEventListener("click", () => {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Open Compliance Chart",
      ]);
    });

  loadSubscriptionCategoriesForFilter();
  switchMainDashTab("subscription");
  animateContainer(main.querySelector(".company-container"));
}

function switchMainDashTab(tab) {
  const isSub = tab === "subscription";
  const sub = document.getElementById("dash-subscription");
  const comp = document.getElementById("dash-compliance");
  const filters = document.getElementById("dash-filters");

  if (sub) sub.style.display = isSub ? "" : "none";
  if (comp) comp.style.display = isSub ? "none" : "";
  if (filters) filters.style.display = isSub ? "" : "none";

  document
    .querySelectorAll(".tab-button-company")
    .forEach((b) => b.classList.remove("active"));
  document
    .querySelector(`[data-dashtab="${isSub ? "subscription" : "compliance"}"]`)
    ?.classList.add("active");

  if (isSub) {
    Poller.stop("comp");
    Poller.start("sub", requestSubscriptionStats);
  } else {
    Poller.stop("sub");
    Poller.start("comp", requestComplianceStats);
  }
}

/* =========================
   5) Filters
   ========================= */
function applyDashboardFilters() {
  const isCompVisible =
    document.getElementById("dash-compliance")?.style.display !== "none";
  if (isCompVisible) requestComplianceStats();
  else requestSubscriptionStats();
}

function loadSubscriptionCategoriesForFilter() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "getSubscriptionCategories",
    []
  );
}

/* =========================
   6) KPIs & Rendering
   ========================= */
function renderSubscriptionStatistics(stats) {
  const s = stats || {};
  const cur = s.lcy || "";

  // --- Main dashboard KPIs ---
  const kActive = document.getElementById("sub-kpi-active");
  const kRenew = document.getElementById("sub-kpi-renewals");
  const kMon = document.getElementById("sub-kpi-monthly");
  const kYr = document.getElementById("sub-kpi-yearly");

  if (kActive) kActive.textContent = safeInt(s.active);
  if (kRenew) kRenew.textContent = safeInt(s.renewals);
  if (kMon) kMon.textContent = formatCurrency(s.monthly, cur);
  if (kYr) kYr.textContent = formatCurrency(s.yearly, cur);

  // --- Subscription page KPIs ---
  const tTotal = document.getElementById("sub-total");
  const tActive = document.getElementById("sub-active");
  const tInactive = document.getElementById("sub-inactive");

  if (tTotal) tTotal.textContent = safeInt(s.total);
  if (tActive) tActive.textContent = safeInt(s.active);
  if (tInactive) tInactive.textContent = safeInt(s.inactive);
}

/* =========================
   7) Polling Manager
   ========================= */
document.addEventListener("visibilitychange", () => {
  const isHidden = document.hidden;
  const isSub =
    document.getElementById("dash-subscription")?.style.display !== "none";
  const isComp =
    document.getElementById("dash-compliance")?.style.display !== "none";

  if (isHidden) {
    if (isSub) Poller.stop("sub");
    if (isComp) Poller.stop("comp");
  } else {
    if (isSub) Poller.start("sub", requestSubscriptionStats);
    if (isComp) Poller.start("comp", requestComplianceStats);
  }
});

window.addEventListener("beforeunload", () => {
  Poller.stopAll();
});

/* =========================
   8) Data Bridges (BC <-> JS)
   ========================= */
function requestSubscriptionStats() {
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getSubscriptionStats", []);
}

function requestComplianceStats() {
  const { from, to } = getSelectedDashboardRange();
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getComplianceStats", [
    from,
    to,
  ]);
}

// tiny 4cm x 1cm tile
function miniTile(label, emoji) {
  return `
    <button data-label="${escapeAttr(label)}"
            style="
              width:6.5cm;height:1.3cm;
              display:inline-flex;align-items:center;justify-content:center;gap:8px;
              border:1px solid var(--border);border-radius:10px;
              background:var(--panel);color:var(--text-1);font-weight:700;font-size:0.45cm">
      <span aria-hidden="true">${emoji}</span>
      <span>${escapeHtml(label)}</span>
    </button>
  `;
}

// --- REPLACE the whole function with this version ---
function showSubscriptionButtons() {
  const main = document.querySelector(".main-content");
  if (!main) return;

  main.innerHTML = `
    <div id="subscription-stats-container">
      <div class="stats-container" style="margin-bottom:12px">
        <div class="stat-box purple"><div class="stat-label">Total Subscriptions</div><div id="sub-total" class="stat-value">0</div></div>
        <div class="stat-box green"><div class="stat-label">Active</div><div id="sub-active" class="stat-value">0</div></div>
        <div class="stat-box yellow"><div class="stat-label">Inactive</div><div id="sub-inactive" class="stat-value">0</div></div>
      </div>
    </div>

    <!-- 5 compact tiles in one row (4cm x 1cm) -->
    <div id="sub-quick-actions"
         "display:flex;gap:10px;align-items:center;flex-wrap:nowrap;overflow:auto;margin:8px 0 12px 0;">
      ${miniTile("Add Subscription", "✨")}
      ${miniTile("Manage Subscriptions", "⚙️")}
      ${miniTile("Active Subscriptions", "✅")}
      ${miniTile("Inactive Subscriptions", "⛔")}
      ${miniTile("Renewals This Month", "📅")}
    </div>

    <!-- Search & Filter -->
    <div id="sub-filter-bar"
         style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin:6px 0 12px 0;">
      <input id="sub-search" type="search" placeholder="Search subscriptions by name"
             style="flex:1 1 320px;min-width:260px;padding:10px 12px;border-radius:8px;border:1px solid var(--border);background:var(--panel);color:var(--text)">
      <select id="sub-filter-category"
              style="flex:0 0 240px;padding:10px 12px;border-radius:8px;border:1px solid var(--border);background:var(--panel);color:var(--text)">
        <option value="">All Categories</option>
      </select>
      <button id="sub-refresh" class="btn" type="button">Search</button>
    </div>

    <!-- List -->
    <div id="sub-list-container" style="overflow:auto;border-radius:12px;border:1px solid var(--border);">
      <table id="sub-table" style="width:100%;border-collapse:collapse;">
        <thead>
          <tr style="background:var(--panel-soft);color:var(--text-1);text-align:left;">
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;">No.</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);">Name</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);">Category</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;">Status</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;">Start Date</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;">End Date</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;text-align:right;">Amount</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  `;

  // wire quick actions -> same AL targets you already had
  document
    .getElementById("sub-quick-actions")
    ?.addEventListener("click", (e) => {
      const btn = e.target.closest("[data-label]");
      if (!btn) return;
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        btn.getAttribute("data-label"),
      ]);
    });

  // load KPIs
  Poller.start("sub", requestSubscriptionStats);

  // populate categories for the filter + fetch list once ready
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
    "getSubscriptionCategories",
    []
  );
  wireSubFilters(); // hooks search / dropdown
  runSubFilterNow(); // initial fetch
}

// Replace existing showComplianceButtons with this full version
function showComplianceButtons() {
  const main = document.querySelector(".main-content");
  if (!main) return;

  // One row KPI (already rendered via renderComplianceStatistics)
  main.innerHTML = `
    <div id="compliance-stats-container">
      <div class="stats-container" style="margin-bottom:10px">
       
        <div class="stat-box green">
          <div class="stat-label">Annual Active </div>
          <div id="stat-active" class="stat-value">0</div>
        </div>
        <div class="stat-box yellow">
          <div class="stat-label">Pending</div>
          <div id="stat-pending" class="stat-value">0</div>
        </div>
      </div>
    </div>

    <!-- Compact action tiles (one row, 4cm x 3cm) -->
    <div id="comp-tiles" style="display:flex;gap:10px;align-items:center;flex-wrap:nowrap;overflow:auto;margin:8px 0 12px 0;">
      ${cmTile("Setup New Compliance Item", "✨")}
      ${cmTile("Submit a Compliance", "🗂️")}
      ${cmTile("View Submitted Compliance", "📬")}
      ${cmTile("Pending Compliance Submissions", "⏳")}
      ${cmTile("This Month's Submissions", "📆")}
    </div>

    <!-- Search -->
    <div id="comp-filter-bar" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin:6px 0 12px 0;">
      <input id="comp-search" type="search" placeholder="Search by Compliance Name or Compliance ID"
             style="flex:1 1 420px;min-width:280px;padding:10px 12px;border-radius:8px;border:1px solid var(--border);background:var(--panel);color:var(--text)">
      <button id="comp-search-btn" class="btn" type="button">Search</button>
    </div>

    <!-- Table -->
    <div id="comp-list-container" style="overflow:auto;border-radius:12px;border:1px solid var(--border);">
      <table id="comp-table" style="width:100%;border-collapse:collapse;">
        <thead>
          <tr style="background:var(--panel-soft);color:var(--text-1);text-align:left;">
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;">Compliance ID</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);">Compliance Name</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;">Status</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;">Filing Due Date</th>
            <th style="padding:10px 12px;border-bottom:1px solid var(--border);white-space:nowrap;text-align:right;">Payable Amount</th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  `;

  // Action tiles -> AL navigation
  document.getElementById("comp-tiles")?.addEventListener("click", (e) => {
    const btn = e.target.closest("[data-label]");
    if (!btn) return;
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
      btn.getAttribute("data-label"),
    ]);
  });

  // Poll KPIs like before
  Poller.stop("sub");
  Poller.start("comp", requestComplianceStats);

  // Search wiring
  wireCompSearch();
  runCompSearchNow(); // initial load
}

// fixed-size tile (4cm x 3cm)
function cmTile(label, emoji) {
  return `
    <button data-label="${escapeAttr(label)}"
            style="
              width:6.5cm;height:1.5cm;
              display:inline-flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;
              border:1px solid var(--border);border-radius:10px;
              background:var(--panel);color:var(--text-1);font-weight:700;font-size:0.6cm">
      <span aria-hidden="true" style="font-size:18px;line-height:1">${emoji}</span>
      <span style="font-size:12px;text-align:center">${escapeHtml(label)}</span>
    </button>
  `;
}
function wireCompSearch() {
  const search = document.getElementById("comp-search");
  const btn = document.getElementById("comp-search-btn");
  const run = debounce(runCompSearchNow, 300);
  search?.addEventListener("input", run);
  btn?.addEventListener("click", runCompSearchNow);
}

function runCompSearchNow() {
  const q = (document.getElementById("comp-search")?.value || "").trim();
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getCompliances", [
    { search: q },
  ]);
}
function renderCompliances(data) {
  const rows = Array.isArray(data) ? data : data?.value || [];
  const tbody = document.querySelector("#comp-table tbody");
  if (!tbody) return;

  const html = rows
    .map((r) => {
      const id = safeStr(r.no || r.id || r.complianceId || "");
      const name = safeStr(r.name || r.complianceName || "");
      const status = safeStr(r.status || "");
      const due = safeStr(r.dueDate || "");
      const amt = r.amount !== undefined ? r.amount : r.payableAmount || 0;

      return `
      <tr data-no="${escapeAttr(id)}" data-sysid="${escapeAttr(r.sysId || "")}"
          style="cursor:pointer;">
        <td style="padding:8px 12px;border-top:1px solid var(--border);white-space:nowrap;">${escapeHtml(
          id
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);">${escapeHtml(
          name
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);white-space:nowrap;">${escapeHtml(
          status
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);white-space:nowrap;">${escapeHtml(
          due
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);text-align:right;">${escapeHtml(
          String(amt ?? "")
        )}</td>
      </tr>
    `;
    })
    .join("");

  tbody.innerHTML =
    html ||
    `<tr><td colspan="5" style="padding:12px;">No compliances found.</td></tr>`;

  tbody.onclick = (e) => {
    const tr = e.target.closest("tr[data-no],tr[data-sysid]");
    if (!tr) return;
    const no = tr.getAttribute("data-no") || "";
    const sysId = tr.getAttribute("data-sysid") || "";
    if (no) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "OpenCompliance:" + no,
      ]);
    } else if (sysId) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "OpenComplianceSys:" + sysId,
      ]);
    }
  };
}

// export for AL
window.renderCompliances = renderCompliances;

// Replace existing renderComplianceStatistics with this tolerant version
function renderComplianceStatistics(stats) {
  const s = stats || {};
  const cur = s.lcy || "";

  // Update if present; don't bail if a card is missing.
  const yearlyEl =
    document.getElementById("stat-yearly") ||
    document.getElementById("stat-total");
  const activeEl = document.getElementById("stat-active");
  const pendingEl = document.getElementById("stat-pending");

  if (yearlyEl) {
    yearlyEl.textContent = normalizeDash(
      formatCurrency(s.yearly ?? s.total, cur)
    );
  }
  if (activeEl) activeEl.textContent = safeInt(s.active);
  if (pendingEl) pendingEl.textContent = safeInt(s.pending);
}
window.renderComplianceStatistics = renderComplianceStatistics;

function showNotificationTabs() {
  const main = document.querySelector(".main-content");
  if (!main) return;
  main.innerHTML = `
    <div class="notification-container">
      <div class="tab-header">
        <button class="tab-button active" data-notiftab="subscription">Subscription</button>
        <button class="tab-button" data-notiftab="compliance">Compliance</button>
      </div>
      <div class="tab-content active" id="subscription-tab"><div class="tab-loading" id="subscription-loading">Loading Subscription Notifications...</div></div>
      <div class="tab-content" id="compliance-tab"><div class="tab-loading" id="compliance-loading">Loading Compliance Notifications...</div></div>
    </div>
  `;
  document
    .querySelectorAll("[data-notiftab]")
    .forEach((b) =>
      b.addEventListener("click", () =>
        switchNotifTab(b.getAttribute("data-notiftab"))
      )
    );
  loadTabContent("subscription", 70132, "Subscription Notification");
}

function switchNotifTab(tabName) {
  document
    .querySelectorAll(".tab-button")
    .forEach((b) =>
      b.classList.toggle("active", b.textContent.toLowerCase() === tabName)
    );
  document
    .querySelectorAll(".tab-content")
    .forEach((c) => c.classList.remove("active"));
  document.getElementById(`${tabName}-tab`)?.classList.add("active");
  if (tabName === "subscription")
    loadTabContent("subscription", 70132, "Subscription Notification");
  else loadTabContent("compliance", 70131, "Notification");
}

function loadTabContent(tabName, pageId, pageTitle) {
  const tabContent = document.getElementById(`${tabName}-tab`);
  const loading = document.getElementById(`${tabName}-loading`);
  if (!tabContent || !loading) return;
  if (tabContent.querySelector(".page-embed")) return;

  loading.innerHTML = `
    <div style="text-align:center; padding:20px;">
      <h3 style="color:white; margin-bottom:20px; font-size:24px;">${escapeHtml(
        pageTitle
      )}</h3>
      <div style="background: rgba(255,255,255,.1); backdrop-filter: blur(10px); padding:30px; border-radius:16px; border:1px solid rgba(255,255,255,.1);">
        <p style="color: rgba(255,255,255,.8); margin-bottom:16px;">Business Central Page Integration</p>
        <p style="color: rgba(255,255,255,.6); font-size:16px;">Page ID: ${pageId} - "${escapeHtml(
    pageTitle
  )}"</p>
        <button class="btn" data-action="open-bc" data-bcname="${escapeHtml(
          tabName.charAt(0).toUpperCase() + tabName.slice(1)
        )} Notifications">Open in Business Central</button>
      </div>
    </div>
  `;
  loading
    .querySelector("[data-action='open-bc']")
    ?.addEventListener("click", (e) => {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        e.currentTarget.getAttribute("data-bcname"),
      ]);
    });
}

/* =========================
   9) List Rendering
   ========================= */
function renderPaymentMethods(methods) {
  const arr = Array.isArray(methods) ? methods : methods?.value || [];
  const list = document.getElementById("payment-methods-list");
  if (!list) return;

  // Render tiles with both id (Entry No.) and sysId (GUID)
  list.innerHTML =
    arr.length === 0
      ? `<div style="opacity:.8;">No payment methods found.</div>`
      : arr
          .map((m) => {
            const id = m.id; // number (may be 0/null)
            const sysId = m.sysId || ""; // GUID string
            return `
              <button class="payment-card" data-action="edit-pm"
                      data-id="${
                        id !== undefined && id !== null ? String(id) : ""
                      }"
                      data-sysid="${escapeAttr(sysId)}">
                <div class="icon-pill" data-icon="${escapeHtml(
                  m.icon || ""
                )}"></div>
                <div class="title">${escapeHtml(m.title || "")}</div>
                <div class="meta">${escapeHtml(m.description || "")}</div>
              </button>
            `;
          })
          .join("");

  // Prevent duplicate listeners across re-renders
  if (list._clickHandler) {
    list.removeEventListener("click", list._clickHandler);
  }
  list._clickHandler = (e) => {
    const btn = e.target.closest("[data-action='edit-pm']");
    if (!btn) return;

    const idAttr = btn.getAttribute("data-id");
    const sysId = btn.getAttribute("data-sysid") || "";

    // Prefer numeric Entry No. when valid (>0), otherwise fall back to SystemId
    const idNum = Number(idAttr);
    if (Number.isFinite(idNum) && idNum > 0) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "EditPaymentMethod:" + String(idNum),
      ]);
    } else if (sysId) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "EditPaymentMethodSys:" + sysId,
      ]);
    } else {
      // As a last resort, do nothing (or console.warn)
      // console.warn("Payment method tile missing both id and sysId");
    }
  };
  list.addEventListener("click", list._clickHandler);

  // Optional: keep animation
  animateCards();
}

function renderDepartments(departments) {
  const arr = Array.isArray(departments)
    ? departments
    : departments?.value || [];
  const list = document.getElementById("department-list");
  if (!list) return;

  list.innerHTML =
    arr.length === 0
      ? `<div style="opacity:.8;">No departments found.</div>`
      : arr
          .map(
            (d) => `
        <button class="payment-card" data-action="edit-dept" data-code="${escapeAttr(
          d.code || ""
        )}">
          <div class="title">${escapeHtml(d.name || d.code || "")}</div>
          <div class="meta">${escapeHtml(d.code || "")}</div>
        </button>
      `
          )
          .join("");

  // De-dupe the click handler to prevent multiple opens
  if (list._clickHandler) {
    list.removeEventListener("click", list._clickHandler);
  }
  list._clickHandler = (e) => {
    const btn = e.target.closest("[data-action='edit-dept']");
    if (!btn) return;
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
      "EditDepartment:" + (btn.getAttribute("data-code") || ""),
    ]);
  };
  list.addEventListener("click", list._clickHandler);

  animateCards();
}

function renderSubscriptionCategories(categories) {
  const arr = Array.isArray(categories) ? categories : categories?.value || [];
  const list = document.getElementById("subscription-category-list");
  const ddDash = document.getElementById("dash-category"); // dashboard filter
  const ddSub = document.getElementById("sub-filter-category"); // Subscription page filter

  /* ---- Cards list (optional panel) ---- */
  if (list) {
    list.innerHTML =
      arr.length === 0
        ? `<div style="opacity:.8;">No subscription categories found.</div>`
        : arr
            .map(
              (c) => `
            <button class="payment-card" data-action="edit-cat" data-code="${escapeAttr(
              c.code || ""
            )}">
              <div class="title">${escapeHtml(c.name || c.code || "")}</div>
              <div class="meta">${escapeHtml(c.code || "")}</div>
            </button>
          `
            )
            .join("");

    // De-dupe click handler
    if (list._clickHandler)
      list.removeEventListener("click", list._clickHandler);
    list._clickHandler = (e) => {
      const btn = e.target.closest("[data-action='edit-cat']");
      if (!btn) return;
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "EditSubscriptionCategory:" + (btn.getAttribute("data-code") || ""),
      ]);
    };
    list.addEventListener("click", list._clickHandler);

    animateCards();
  }

  /* ---- Fill the two dropdowns (and preserve current selection) ---- */
  if (ddDash) {
    const prev = ddDash.value;
    ddDash.innerHTML =
      `<option value="">All Categories</option>` +
      arr
        .map(
          (c) =>
            `<option value="${escapeAttr(c.code || "")}">${escapeHtml(
              c.name || c.code || ""
            )}</option>`
        )
        .join("");
    if ([...ddDash.options].some((o) => o.value === prev)) ddDash.value = prev;
  }

  if (ddSub) {
    const prev2 = ddSub.value;
    ddSub.innerHTML =
      `<option value="">All Categories</option>` +
      arr
        .map(
          (c) =>
            `<option value="${escapeAttr(c.code || "")}">${escapeHtml(
              c.name || c.code || ""
            )}</option>`
        )
        .join("");
    if ([...ddSub.options].some((o) => o.value === prev2)) ddSub.value = prev2;
  }
}

// function renderEmployees(employees) {
//   const arr = Array.isArray(employees) ? employees : employees?.value || [];
//   const list = document.getElementById("employee-list");
//   if (!list) return;
//   list.innerHTML =
//     arr.length === 0
//       ? `<div style="opacity:.8;">No employees found.</div>`
//       : arr
//           .map(
//             (e) => `
//         <button class="payment-card" data-action="edit-emp" data-no="${escapeHtml(
//           e.no || ""
//         )}">
//           <div class="title">${escapeHtml(e.name || e.no || "")}</div>
//           <div class="meta">${escapeHtml(e.no || "")}</div>
//         </button>
//       `
//           )
//           .join("");

//   list.addEventListener("click", (e) => {
//     const btn = e.target.closest("[data-action='edit-emp']");
//     if (!btn) return;
//     Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
//       "EditEmployee:" + btn.getAttribute("data-no"),
//     ]);
//   });
// }
function renderEmployees(employees) {
  const arr = Array.isArray(employees) ? employees : employees?.value || [];
  const list = document.getElementById("employee-list");
  if (!list) return;

  list.innerHTML =
    arr.length === 0
      ? `<div style="opacity:.8;">No employees found.</div>`
      : arr
          .map(
            (e) => `
        <button class="payment-card" data-action="edit-emp" data-no="${escapeHtml(
          e.no || ""
        )}">
          <div class="title">${escapeHtml(e.name || e.no || "")}</div>
          <div class="meta">${escapeHtml(e.no || "")}</div>
        </button>
      `
          )
          .join("");

  // Remove prior handler (if any), then attach a fresh one to avoid duplicates
  if (list._clickHandler) {
    list.removeEventListener("click", list._clickHandler);
  }
  list._clickHandler = (e) => {
    const btn = e.target.closest("[data-action='edit-emp']");
    if (!btn) return;
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
      "EditEmployee:" + btn.getAttribute("data-no"),
    ]);
  };
  list.addEventListener("click", list._clickHandler);

  animateCards();
}

/* =========================
   10) Utilities
   ========================= */
function createSubscriptionCard(title, description, icon) {
  return `
    <button class="subscription-card" data-label="${escapeAttr(title)}">
      <div class="icon-container">${icon}</div>
      <div class="card-title">${escapeHtml(title)}</div>
      <div class="card-description">${escapeHtml(description)}</div>
    </button>
  `;
}

function animateCards() {
  // setTimeout(() => {
  //   document
  //     .querySelectorAll(".subscription-card, .payment-card")
  //     .forEach((el, i) => {
  //       el.style.opacity = "0";
  //       el.style.transform = "translateY(30px)";
  //       el.style.transition = "opacity 0.5s ease, transform 0.5s ease";
  //       setTimeout(() => {
  //         el.style.opacity = "1";
  //         el.style.transform = "translateY(0)";
  //       }, i * 100);
  //     });
  // }, 50);
}

function animateContainer(container) {
  // if (!container) return;
  // container.style.opacity = "0";
  // container.style.transform = "translateY(20px)";
  // container.style.transition = "opacity 0.5s ease, transform 0.5s ease";
  // setTimeout(() => {
  //   container.style.opacity = "1";
  //   container.style.transform = "translateY(0)";
  // }, 50);
}

function createAnimatedBackground() {
  // const body = document.body;
  // ["blob-1", "blob-2", "blob-3"].forEach((cls) => {
  //   const div = document.createElement("div");
  //   div.className = "bg-blob " + cls;
  //   body.appendChild(div);
  // });
}

function setupLogoUploadHandler() {
  const input = document.getElementById("logo-upload");
  const preview = document.getElementById("logo-preview");
  input?.addEventListener("change", (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => {
      const dataUrl = String(ev.target?.result || "");
      preview.src = dataUrl;
      preview.style.display = "block";
      logoBase64 = dataUrl.split(",")[1] || "";
    };
    reader.readAsDataURL(file);
  });
}

function buildIconGrid() {
  const grid = document.getElementById("pm-icon-grid");
  if (!grid) return;
  grid.innerHTML = PM_ICONS.map(
    (i) => `
      <div class="icon-pill ${
        i.key === pmSelectedIcon ? "active" : ""
      }" data-icon="${i.key}" title="${i.key}">${i.label}</div>
    `
  ).join("");
  grid.querySelectorAll(".icon-pill").forEach((el) => {
    el.addEventListener("click", () => {
      pmSelectedIcon = el.getAttribute("data-icon") || "visa";
      grid
        .querySelectorAll(".icon-pill")
        .forEach((x) => x.classList.remove("active"));
      el.classList.add("active");
    });
  });
}

function safeInt(x) {
  const n = Number(x);
  return Number.isFinite(n) ? Math.max(0, Math.trunc(n)) : 0;
}

function normalizeDash(s) {
  return s && s !== "0" ? s : "—";
}

function formatCurrency(x, cur) {
  const n = Number(x || 0);
  try {
    return new Intl.NumberFormat(undefined, {
      style: "currency",
      currency: cur || "USD",
      maximumFractionDigits: 2,
    }).format(n);
  } catch {
    return `${n.toFixed(2)}${cur ? " " + cur : ""}`;
  }
}

function localYYYYMMDD(d) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

function getSelectedDashboardRange() {
  const sel = (
    document.getElementById("dash-range")?.value || "ytd"
  ).toLowerCase();
  const today = new Date();
  let from = new Date(today);
  if (sel === "3m") from.setMonth(from.getMonth() - 3);
  else if (sel === "6m") from.setMonth(from.getMonth() - 6);
  else if (sel === "12m" || sel === "1y") from.setMonth(from.getMonth() - 12);
  else if (sel === "ytd" || sel === "thisyear")
    from = new Date(today.getFullYear(), 0, 1);
  else from.setMonth(from.getMonth() - 6);
  return { from: localYYYYMMDD(from), to: localYYYYMMDD(today) };
}

function escapeHtml(s) {
  return String(s || "").replace(
    /[&<>"']/g,
    (m) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[
        m
      ])
  );
}
function escapeAttr(s) {
  return String(s || "").replace(
    /["'`<>&]/g,
    (m) =>
      ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
        "`": "&#96;",
      }[m])
  );
}

/* =========================
   Exports for AL (procedures)
   ========================= */
function showMainDashboard() {
  const main = document.querySelector(".main-content");
  if (!main) return;
  main.innerHTML = getMainDashboardHTML();
  document.querySelectorAll("[data-dashtab]").forEach((btn) => {
    btn.addEventListener("click", () =>
      switchMainDashTab(btn.getAttribute("data-dashtab"))
    );
  });
  document
    .getElementById("dash-range")
    ?.addEventListener("change", applyDashboardFilters);
  document
    .getElementById("dash-category")
    ?.addEventListener("change", applyDashboardFilters);
  document
    .querySelector("[data-action='open-sub-trend']")
    ?.addEventListener("click", () => {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Open Subscription Chart",
      ]);
    });
  document
    .querySelector("[data-action='open-comp-trend']")
    ?.addEventListener("click", () => {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Open Compliance Chart",
      ]);
    });
  loadSubscriptionCategoriesForFilter();
  switchMainDashTab("subscription");
  animateContainer(main.querySelector(".company-container"));
}

function displayInitialSetup(setupData) {
  const main = document.querySelector(".main-content");
  if (!main) return;

  // Render view
  main.innerHTML = getInitialSetupHTML(setupData);

  // Tab switching logic
  document.querySelectorAll("[data-initialtab]").forEach((b) => {
    b.addEventListener("click", () => {
      document
        .querySelectorAll(".tab-button-company")
        .forEach((x) => x.classList.remove("active"));
      b.classList.add("active");

      document
        .querySelectorAll(".tab-content-company")
        .forEach((c) => c.classList.remove("active"));
      document
        .getElementById(`${b.getAttribute("data-initialtab")}-tab`)
        ?.classList.add("active");

      if (b.getAttribute("data-initialtab") === "payment-methods") {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
          "getPaymentMethods",
          []
        );
      }
    });
  });

  // Remove any previous handler we attached on earlier renders
  if (main._initSetupClickHandler) {
    main.removeEventListener("click", main._initSetupClickHandler);
  }

  // Delegated click handler scoped to this view container
  main._initSetupClickHandler = (e) => {
    const btn = e.target.closest("[data-action]");
    if (!btn) return;

    const a = btn.getAttribute("data-action");

    if (a === "auto-create-series") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Auto Create All Number Series",
      ]);
    } else if (a === "open-initial-manual") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Assign Manually",
      ]);
    } else if (a === "open-pm-modal") {
      pmSelectedIcon = "visa";
      buildIconGrid();
      const modal = document.getElementById("pm-modal");
      if (modal) modal.style.display = "flex";
    } else if (a === "close-pm-modal") {
      const modal = document.getElementById("pm-modal");
      if (modal) modal.style.display = "none";
    } else if (a === "create-pm") {
      const title = document.getElementById("pm-title")?.value.trim() || "";
      const type = document.getElementById("pm-type")?.value.trim() || "";
      if (!title || !type) {
        alert("Please provide both Title and Type.");
        return;
      }
      const payload = {
        title,
        type,
        description: document.getElementById("pm-desc")?.value.trim() || "",
        icon: pmSelectedIcon,
        managedBy: document.getElementById("pm-managedby")?.value.trim() || "",
        expiresAt: document.getElementById("pm-expires")?.value || "",
      };

      // Fire-and-forget: AL persists and then calls SendPaymentMethods() -> renderPaymentMethods()
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("savePaymentMethod", [
        payload,
      ]);

      // Close modal immediately; the list will refresh via AL callback
      const modal = document.getElementById("pm-modal");
      if (modal) modal.style.display = "none";
    } else if (a === "open-pm-page") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Manage Payment Methods",
      ]);
    } else if (a === "save-company") {
      const companyData = {
        general: {
          name: document.getElementById("company-name")?.value || "",
          logoBase64: logoBase64,
        },
        address: {
          address: document.getElementById("address")?.value || "",
          countryRegionCode: document.getElementById("country")?.value || "",
        },
      };
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
        "updateCompanyInformation",
        [companyData]
      );
    } else if (a === "add-department") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Add Department",
      ]);
    } else if (a === "add-employee") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "AddEmployee",
      ]);
    } else if (a === "add-subscription-category") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Add Subscription Categories",
      ]);
    }
  };

  main.addEventListener("click", main._initSetupClickHandler);

  // File upload handler + entrance animation
  setupLogoUploadHandler();
  animateContainer(main.querySelector(".company-container"));
}

function displayCompanyInformation(companyData) {
  const main = document.querySelector(".main-content");
  if (!main) return;
  main.innerHTML = getCompanyInfoHTML(companyData);

  document.querySelectorAll("[data-companytab]").forEach((b) => {
    b.addEventListener("click", () => {
      document
        .querySelectorAll(".tab-button-company")
        .forEach((x) => x.classList.remove("active"));
      b.classList.add("active");
      document
        .querySelectorAll(".tab-content-company")
        .forEach((c) => c.classList.remove("active"));
      document
        .getElementById(`${b.getAttribute("data-companytab")}-tab`)
        ?.classList.add("active");

      const t = b.getAttribute("data-companytab");
      if (t === "department")
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getDepartments", []);
      else if (t === "employee")
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getEmployees", []);
      else if (t === "subscription")
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
          "getSubscriptionCategories",
          []
        );
    });
  });

  // Scope the delegated click handler to the current view container (no { once: true })
  main.addEventListener("click", (e) => {
    const btn = e.target.closest("[data-action]");
    if (!btn) return;
    const a = btn.getAttribute("data-action");

    if (a === "save-company") {
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
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
        "updateCompanyInformation",
        [companyData]
      );
    } else if (a === "add-department") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Add Department",
      ]);
    } else if (a === "add-employee") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "AddEmployee",
      ]);
    } else if (a === "add-subscription-category") {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "Add Subscription Categories",
      ]);
    }
  });

  setupLogoUploadHandler();
  animateContainer(main.querySelector(".company-container"));
}

/* Expose AL-callable procedures */
window.showMainDashboard = showMainDashboard;
window.displayInitialSetup = displayInitialSetup;
window.displayCompanyInformation = displayCompanyInformation;
window.renderSubscriptionStatistics = renderSubscriptionStatistics;
window.renderComplianceStatistics = renderComplianceStatistics;
window.renderPaymentMethods = renderPaymentMethods;
window.renderDepartments = renderDepartments;
window.renderEmployees = renderEmployees;
window.renderSubscriptionCategories = renderSubscriptionCategories;

/*THEME SWITCH*/

// ===== THEME ENGINE (Light / Dark) =====
const THEME_KEY = "subs_theme";

// Optional: quick visual fallback so you can SEE the swap even if CSS
// light variables aren't added yet. Remove once your CSS has
// [data-theme="light"] overrides.
const LIGHT_BG =
  "linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f8fafc 100%)";
const DARK_BG =
  "linear-gradient(135deg, #1a1c3d 0%, #2d1b69 50%, #0f0c29 100%)";

function applyTheme(name) {
  const theme = name === "light" ? "light" : "dark";
  document.documentElement.setAttribute("data-theme", theme);
  try {
    localStorage.setItem(THEME_KEY, theme);
  } catch {}

  // Fallback background so you immediately see the change.
  // (Your CSS can override this; inline style is only a safety net.)
  document.body.style.background = theme === "light" ? LIGHT_BG : DARK_BG;
}

function initTheme() {
  let theme = "dark";
  try {
    theme = localStorage.getItem(THEME_KEY) || theme;
  } catch {}
  document.documentElement.setAttribute("data-theme", theme);
  // Same fallback as above for first paint:
  document.body.style.background = theme === "light" ? LIGHT_BG : DARK_BG;
}

function setupThemeToggle() {
  const btn = document.getElementById("theme-toggle");
  if (!btn) return;

  const icon = btn.querySelector(".toggle-icon");
  const text = btn.querySelector(".toggle-text");

  function refreshLabel() {
    const cur = document.documentElement.getAttribute("data-theme") || "dark";
    const isLight = cur === "light";
    btn.setAttribute("aria-pressed", String(isLight));
    if (icon) icon.textContent = isLight ? "☀️" : "🌙";
    if (text) text.textContent = isLight ? "Light" : "Dark";
    btn.title = `Switch to ${isLight ? "Dark" : "Light"} theme`;
  }

  btn.addEventListener("click", () => {
    const cur = document.documentElement.getAttribute("data-theme") || "dark";
    applyTheme(cur === "light" ? "dark" : "light");
    refreshLabel();
  });

  btn.addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      btn.click();
    }
  });

  refreshLabel();
}
// Try to load logo.png that was listed in controladdin Images.
// If it fails, show the gradient "S" square as a fallback.
function primeLogo() {
  const img = document.getElementById("brand-logo");
  const fb = document.getElementById("brand-fallback");
  if (!img || !fb) return;

  // Show fallback square until image loads
  img.hidden = true;
  fb.hidden = false;

  img.onload = () => {
    img.hidden = false;
    fb.hidden = true;
  };
  img.onerror = () => {
    img.hidden = true;
    fb.hidden = false;
  };

  // logo.png must be deployed next to dashboard.js (…/Dashboard/Resources/)
  img.src = ASSET_BASE + "logo.png?v=" + Date.now(); // cache-bust
}

// ---- Search & filter wiring for the subscription list ----
function wireSubFilters() {
  const search = document.getElementById("sub-search");
  const cat = document.getElementById("sub-filter-category");
  const btn = document.getElementById("sub-refresh");
  const run = debounce(runSubFilterNow, 300);

  search?.addEventListener("input", run);
  cat?.addEventListener("change", runSubFilterNow);
  btn?.addEventListener("click", runSubFilterNow);
}

function runSubFilterNow() {
  const q = (document.getElementById("sub-search")?.value || "").trim();
  const cat = document.getElementById("sub-filter-category")?.value || "";
  // Ask AL for the list (it should call back renderSubscriptions below)
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("getSubscriptions", [
    { search: q, category: cat },
  ]);
}

// Simple debounce to avoid chatty calls while typing
function debounce(fn, ms) {
  let t = null;
  return (...args) => {
    clearTimeout(t);
    t = setTimeout(() => fn(...args), ms);
  };
}

function renderSubscriptions(data) {
  const rows = Array.isArray(data) ? data : data?.value || [];
  const tbody = document.querySelector("#sub-table tbody");
  if (!tbody) return;

  const html = rows
    .map((r) => {
      const no = safeStr(r.no || r.No || r.code || "");
      const name = safeStr(r.name || r.description || r.displayName || "");
      const cat = safeStr(
        r.category || r.categoryCode || r.subscriptionCategory || ""
      );
      const stat = safeStr(r.status || r.state || "");
      const sd = safeStr(r.startDate || r.start_date || r.start || "");
      const ed = safeStr(r.endDate || r.end_date || r.end || "");
      const amt =
        r.amount !== undefined
          ? r.amount
          : r.price || r.monthlyAmount || r.total || 0;

      return `
      <tr data-no="${escapeAttr(no)}" data-sysid="${escapeAttr(
        r.sysId || r.SystemId || ""
      )}"
          style="cursor:pointer;">
        <td style="padding:8px 12px;border-top:1px solid var(--border);white-space:nowrap;">${escapeHtml(
          no
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);">${escapeHtml(
          name
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);">${escapeHtml(
          cat
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);white-space:nowrap;">${escapeHtml(
          stat
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);white-space:nowrap;">${escapeHtml(
          sd
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);white-space:nowrap;">${escapeHtml(
          ed
        )}</td>
        <td style="padding:8px 12px;border-top:1px solid var(--border);text-align:right;">${escapeHtml(
          String(amt ?? "")
        )}</td>
      </tr>
    `;
    })
    .join("");

  tbody.innerHTML =
    html ||
    `<tr><td colspan="7" style="padding:12px;">No subscriptions found.</td></tr>`;

  // row click -> open page 50110
  tbody.onclick = (e) => {
    const tr = e.target.closest("tr[data-no],tr[data-sysid]");
    if (!tr) return;
    const no = tr.getAttribute("data-no") || "";
    const sysId = tr.getAttribute("data-sysid") || "";
    if (no) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "OpenSubscription:" + no,
      ]);
    } else if (sysId) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnNavigationClick", [
        "OpenSubscriptionSys:" + sysId,
      ]);
    }
  };
}

function safeStr(v) {
  return v === null || v === undefined ? "" : String(v);
}

// export for AL
window.renderSubscriptions = renderSubscriptions;
