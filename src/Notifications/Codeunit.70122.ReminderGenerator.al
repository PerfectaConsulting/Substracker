codeunit 70122 ReminderGenerator
{
    trigger OnRun()
    begin
        GenerateReminders();
    end;

    procedure GenerateReminders()
    var
        ComplianceRec: Record "Compliance Overview";
        NotificationRec: Record "Compliance Reminder";
        ReminderDate: Date;
        Today: Date;
        CurrentDt: DateTime;
        DaysBeforeDue: Integer;
        HalfwayDays: Integer;
        ReminderStartDate: Date;
        DueTodayList: List of [Text];
        DueTodayText: Text;
    begin
        // Safely get current date with error handling
        CurrentDt := CurrentDateTime();
        if CurrentDt = 0DT then
            Error('System datetime is not available');

        Today := DT2Date(CurrentDt);
        if Today = 0D then
            Error('Invalid system date detected');

        ComplianceRec.Reset();

        if ComplianceRec.FindSet() then
            repeat
                // Skip submitted compliances
                if ComplianceRec.Status = ComplianceRec.Status::Submitted then
                    continue;

                // Validate compliance dates before processing
                if (ComplianceRec."Filing Due Date" = 0D) or
                   (ComplianceRec."Reminder Lead Time (Days)" <= 0) then
                    continue;

                // Get reminder configuration
                DaysBeforeDue := ComplianceRec."Reminder Lead Time (Days)";
                ReminderStartDate := ComplianceRec."Filing Due Date" - DaysBeforeDue;

                // Skip if outside reminder window
                if (Today > ComplianceRec."Filing Due Date") or (Today < ReminderStartDate) then
                    continue;

                // Check for existing reminder with same configuration
                NotificationRec.Reset();
                NotificationRec.SetRange("Reminder Date", Today);
                NotificationRec.SetRange("Compliance ID", ComplianceRec.ID);
                NotificationRec.SetRange("Compliance Due Date", ComplianceRec."Filing Due Date");
                NotificationRec.SetRange("Reminder Lead Time", DaysBeforeDue);

                if not NotificationRec.FindFirst() then
                    case ComplianceRec."Reminder Schedule" of
                        ComplianceRec."Reminder Schedule"::onetime:
                            begin
                                ReminderDate := ComplianceRec."Filing Due Date" - DaysBeforeDue;
                                if Today = ReminderDate then
                                    InsertReminder(ComplianceRec, DaysBeforeDue, CurrentDt);
                            end;
                        ComplianceRec."Reminder Schedule"::TwoReminders:
                            begin
                                ReminderDate := ComplianceRec."Filing Due Date" - DaysBeforeDue;
                                if Today = ReminderDate then
                                    InsertReminder(ComplianceRec, DaysBeforeDue, CurrentDt)
                                else begin
                                    HalfwayDays := DaysBeforeDue div 2;
                                    ReminderDate := ComplianceRec."Filing Due Date" - HalfwayDays;
                                    if Today = ReminderDate then
                                        InsertReminder(ComplianceRec, DaysBeforeDue, CurrentDt);
                                end;
                            end;
                        ComplianceRec."Reminder Schedule"::untildue:
                            begin
                                ReminderDate := ComplianceRec."Filing Due Date" - DaysBeforeDue;
                                if (Today >= ReminderDate) and (Today <= ComplianceRec."Filing Due Date") then
                                    InsertReminder(ComplianceRec, DaysBeforeDue, CurrentDt);
                            end;
                    end;

                // Collect due-today items for aggregated notification
                if Today = ComplianceRec."Filing Due Date" then
                    DueTodayList.Add(ComplianceRec."Compliance Name");

            until ComplianceRec.Next() = 0;

        // Show aggregated due-today notification
        if DueTodayList.Count > 0 then begin
            DueTodayText := 'The following compliances are due today:\n';
            foreach DueTodayText in DueTodayList do
                DueTodayText += '• ' + DueTodayText + '\n';
            Message(DueTodayText);
        end;
    end;

    local procedure InsertReminder(ComplianceRec: Record "Compliance Overview"; LeadTime: Integer; CurrentDt: DateTime)
    var
        NotificationRec: Record "Compliance Reminder";
        UserRec: Record User;
        EmailCodeunit: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Today: Date;
        DaysLeft: Integer;
        Recipient: Text[2048];
        Subject: Text[250];
        Body: Text[2048];
        EmailSentSuccessfully: Boolean;
    begin
        // Validate input parameters
        if (ComplianceRec."Filing Due Date" = 0D) or (CurrentDt = 0DT) then
            Error('Invalid parameters for reminder creation');

        Today := DT2Date(CurrentDt);
        if Today = 0D then
            Error('Cannot convert current datetime to date');

        DaysLeft := ComplianceRec."Filing Due Date" - Today;

        NotificationRec.Init();
        NotificationRec."Compliance ID" := ComplianceRec.ID;
        NotificationRec."Compliance Name" := ComplianceRec."Compliance Name";
        NotificationRec."Reminder Date" := Today;
        NotificationRec."Compliance Due Date" := ComplianceRec."Filing Due Date";
        NotificationRec."Reminder Lead Time" := LeadTime;
        NotificationRec.Message := StrSubstNo('Compliance "%1" due in %2 days',
            ComplianceRec."Compliance Name", DaysLeft);
        NotificationRec."Is Today" := (DaysLeft = 0);
        NotificationRec."Email Sent" := false;

        if NotificationRec.Insert() then;

        // Send email to current user
        EmailSentSuccessfully := false;
        if UserRec.Get(UserSecurityId()) then begin
            Recipient := UserRec."Contact Email";
            if Recipient <> '' then begin
                Subject := StrSubstNo('Compliance Reminder: %1', ComplianceRec."Compliance Name");
                Body := NotificationRec.Message;

                EmailMessage.Create(Recipient, Subject, Body, false); // false for plain text; set true for HTML if needed
                if EmailCodeunit.Send(EmailMessage) then
                    EmailSentSuccessfully := true;
            end;
        end;

        // Update the reminder record with email status
        NotificationRec."Email Sent" := EmailSentSuccessfully;
        NotificationRec.Modify(true);
    end;
}