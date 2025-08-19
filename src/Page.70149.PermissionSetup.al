permissionset 50100 "SUBSTRACKER ALL"
{
    Caption = 'SubsTracker Full Access';
    Assignable = true;

    Permissions = 
        tabledata "Compliance Reminder" = RIMD,
        tabledata "ST Payment Method" = RIMD,
        tabledata "Compliance Overview" = RIMD,
        tabledata "Compliance Overview Archive" = RIMD,
        tabledata "Initial Setup" = RIMD,
        tabledata "Subscription" = RIMD,
        tabledata "Employee Ext" = RIMD,
        tabledata "Subscription Ledger Entry" = RIMD,
        tabledata "Notification" = RIMD,
        tabledata "End User" = RIMD,
        tabledata "Employee Ext Setup" = RIMD,
        tabledata "Department Master" = RIMD,
        tabledata "Department" = RIMD,
        tabledata "Subscription Category" = RIMD,
        tabledata "Subscription Setup" = RIMD,
        tabledata "Custom Payment Method" = RIMD;
}
