// Scripts/ComplianceCalendar.js
class ComplianceCalendar {
  constructor() {
    this.currentDate = new Date();
    this.currentView = "monthly";
    this.events = [];
    this.monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    this.dayNames = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
    ];
  }

  initialize() {
    this.createCalendarStructure();
    this.render();
  }

  createCalendarStructure() {
    const container = document.getElementById("controlAddIn");
    if (!container) return;

    container.innerHTML = `
            <div class="compliance-calendar">
                <div class="calendar-header">
                    <div class="calendar-navigation">
                        <button class="nav-btn" id="prevBtn">‹</button>
                        <div class="calendar-title" id="calendarTitle"></div>
                        <button class="nav-btn" id="nextBtn">›</button>
                    </div>
                    <div class="view-controls">
                        <button class="view-btn active" data-view="monthly">Monthly</button>
                        <button class="view-btn" data-view="yearly">Yearly</button>
                    </div>
                </div>
                <div class="calendar-content" id="calendarContent"></div>
                <div class="calendar-legend">
                    <div class="legend-item">
                        <span class="legend-color has-events"></span>
                        <span>Filing Due Date</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color today"></span>
                        <span>Today</span>
                    </div>
                </div>
            </div>
        `;

    this.bindEvents();
  }

  bindEvents() {
    // Navigation buttons
    document.getElementById("prevBtn").addEventListener("click", () => {
      if (this.currentView === "monthly") {
        this.currentDate.setMonth(this.currentDate.getMonth() - 1);
      } else {
        this.currentDate.setFullYear(this.currentDate.getFullYear() - 1);
      }
      this.render();
      this.notifyViewChanged();
    });

    document.getElementById("nextBtn").addEventListener("click", () => {
      if (this.currentView === "monthly") {
        this.currentDate.setMonth(this.currentDate.getMonth() + 1);
      } else {
        this.currentDate.setFullYear(this.currentDate.getFullYear() + 1);
      }
      this.render();
      this.notifyViewChanged();
    });

    // View buttons
    document.querySelectorAll(".view-btn").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        document
          .querySelectorAll(".view-btn")
          .forEach((b) => b.classList.remove("active"));
        e.target.classList.add("active");
        this.currentView = e.target.dataset.view;
        this.render();
        this.notifyViewChanged();
      });
    });
  }

  render() {
    if (this.currentView === "monthly") {
      this.renderMonthlyView();
    } else {
      this.renderYearlyView();
    }
  }

  renderMonthlyView() {
    const titleElement = document.getElementById("calendarTitle");
    const contentElement = document.getElementById("calendarContent");

    if (!titleElement || !contentElement) return;

    titleElement.textContent = `${
      this.monthNames[this.currentDate.getMonth()]
    } ${this.currentDate.getFullYear()}`;

    const firstDay = new Date(
      this.currentDate.getFullYear(),
      this.currentDate.getMonth(),
      1
    );
    const lastDay = new Date(
      this.currentDate.getFullYear(),
      this.currentDate.getMonth() + 1,
      0
    );
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    let html = `
            <div class="monthly-calendar">
                <div class="calendar-grid">
                    <div class="day-headers">
                        ${this.dayNames
                          .map((day) => `<div class="day-header">${day}</div>`)
                          .join("")}
                    </div>
                    <div class="days-grid">
        `;

    for (let i = 0; i < 42; i++) {
      const currentDay = new Date(startDate);
      currentDay.setDate(startDate.getDate() + i);

      const isCurrentMonth =
        currentDay.getMonth() === this.currentDate.getMonth();
      const isToday = this.isToday(currentDay);
      const hasEvents = this.hasEventsOnDate(currentDay);
      const events = this.getEventsForDate(currentDay);

      let classes = ["calendar-day"];
      if (!isCurrentMonth) classes.push("other-month");
      if (isToday) classes.push("today");
      if (hasEvents) classes.push("has-events");

      html += `
                <div class="${classes.join(" ")}" data-date="${this.formatDate(
        currentDay
      )}">
                    <div class="day-number">${currentDay.getDate()}</div>
                    ${
                      events.length > 0
                        ? `<div class="event-count">${events.length}</div>`
                        : ""
                    }
                </div>
            `;
    }

    html += `
                    </div>
                </div>
            </div>
        `;

    contentElement.innerHTML = html;
    this.bindDayEvents();
  }

  renderYearlyView() {
    const titleElement = document.getElementById("calendarTitle");
    const contentElement = document.getElementById("calendarContent");

    if (!titleElement || !contentElement) return;

    titleElement.textContent = this.currentDate.getFullYear().toString();

    let html = '<div class="yearly-calendar">';

    for (let month = 0; month < 12; month++) {
      const monthDate = new Date(this.currentDate.getFullYear(), month, 1);
      html += this.renderMiniMonth(monthDate, month);
    }

    html += "</div>";
    contentElement.innerHTML = html;
    this.bindDayEvents();
  }

  renderMiniMonth(monthDate, monthIndex) {
    const firstDay = new Date(monthDate.getFullYear(), monthIndex, 1);
    const lastDay = new Date(monthDate.getFullYear(), monthIndex + 1, 0);
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    let html = `
            <div class="mini-month">
                <div class="mini-month-header">${
                  this.monthNames[monthIndex]
                }</div>
                <div class="mini-month-days">
                    ${this.dayNames
                      .map(
                        (day) =>
                          `<div class="mini-day-header">${day.substring(
                            0,
                            1
                          )}</div>`
                      )
                      .join("")}
        `;

    for (let i = 0; i < 42; i++) {
      const currentDay = new Date(startDate);
      currentDay.setDate(startDate.getDate() + i);

      const isCurrentMonth = currentDay.getMonth() === monthIndex;
      const isToday = this.isToday(currentDay);
      const hasEvents = this.hasEventsOnDate(currentDay);

      if (
        isCurrentMonth ||
        i < 7 ||
        (i >= 35 && currentDay.getMonth() === monthIndex)
      ) {
        let classes = ["mini-day"];
        if (!isCurrentMonth) classes.push("other-month");
        if (isToday) classes.push("today");
        if (hasEvents) classes.push("has-events");

        html += `<div class="${classes.join(" ")}" data-date="${this.formatDate(
          currentDay
        )}">${currentDay.getDate()}</div>`;
      } else {
        html += '<div class="mini-day empty"></div>';
      }
    }

    html += "</div></div>";
    return html;
  }

  bindDayEvents() {
    document.querySelectorAll("[data-date]").forEach((dayElement) => {
      dayElement.addEventListener("click", (e) => {
        const date = e.currentTarget.dataset.date;
        if (this.hasEventsOnDate(new Date(date))) {
          this.notifyDateClicked(date);
        }
      });
    });
  }

  updateData(jsonData) {
    try {
      const data = JSON.parse(jsonData);
      this.events = data.events || [];

      if (data.year && data.month) {
        this.currentDate = new Date(data.year, data.month - 1, 1);
      }

      if (data.view) {
        this.currentView = data.view;
        document.querySelectorAll(".view-btn").forEach((btn) => {
          btn.classList.toggle("active", btn.dataset.view === data.view);
        });
      }

      this.render();
    } catch (e) {
      console.error("Error updating calendar data:", e);
    }
  }

  navigateToDate(year, month) {
    this.currentDate = new Date(year, month - 1, 1);
    this.render();
  }

  setView(viewType) {
    this.currentView = viewType;
    document.querySelectorAll(".view-btn").forEach((btn) => {
      btn.classList.toggle("active", btn.dataset.view === viewType);
    });
    this.render();
  }

  hasEventsOnDate(date) {
    const dateStr = this.formatDate(date);
    return this.events.some((event) => event.date === dateStr);
  }

  getEventsForDate(date) {
    const dateStr = this.formatDate(date);
    return this.events.filter((event) => event.date === dateStr);
  }

  isToday(date) {
    const today = new Date();
    return date.toDateString() === today.toDateString();
  }

  formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }

  notifyDateClicked(date) {
    if (
      typeof Microsoft !== "undefined" &&
      Microsoft.Dynamics &&
      Microsoft.Dynamics.NAV
    ) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("DateClicked", [date]);
    }
  }

  notifyViewChanged() {
    if (
      typeof Microsoft !== "undefined" &&
      Microsoft.Dynamics &&
      Microsoft.Dynamics.NAV
    ) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ViewChanged", [
        this.currentView,
        this.currentDate.getFullYear(),
        this.currentDate.getMonth() + 1,
      ]);
    }
  }

  notifyControlReady() {
    if (
      typeof Microsoft !== "undefined" &&
      Microsoft.Dynamics &&
      Microsoft.Dynamics.NAV
    ) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlAddInReady", []);
    }
  }
}

// Global functions for Business Central integration
let calendarInstance;

function InitializeCalendar(data) {
  if (calendarInstance) {
    calendarInstance.updateData(data);
  }
}

function UpdateCalendarData(data) {
  if (calendarInstance) {
    calendarInstance.updateData(data);
  }
}

function NavigateToDate(year, month) {
  if (calendarInstance) {
    calendarInstance.navigateToDate(year, month);
  }
}

function SetView(viewType) {
  if (calendarInstance) {
    calendarInstance.setView(viewType);
  }
}

// Initialize the calendar when the DOM is ready
document.addEventListener("DOMContentLoaded", function () {
  calendarInstance = new ComplianceCalendar();
  calendarInstance.initialize();

  // Notify Business Central that the control is ready
  setTimeout(() => {
    calendarInstance.notifyControlReady();
  }, 100);
});

// Ensure the control is properly initialized even if DOMContentLoaded has already fired
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initializeCalendar);
} else {
  initializeCalendar();
}

function initializeCalendar() {
  if (!calendarInstance) {
    calendarInstance = new ComplianceCalendar();
    calendarInstance.initialize();
    setTimeout(() => {
      calendarInstance.notifyControlReady();
    }, 100);
  }
}
