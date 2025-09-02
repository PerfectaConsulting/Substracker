codeunit 70147 "SubscriptionReminderGenerator"
{
    Subtype = Normal;

    trigger OnRun()
    begin
        GenerateReminders();
    end;

    procedure GenerateReminders()
    var
        SubRec: Record "Subscription";
        RemRec: Record "Subscription Reminder";
        CurrentDt: DateTime;
        TodayDate: Date;
        DaysBeforeDue: Integer;
        HalfwayDays: Integer;
        ReminderStartDate: Date;
        DueTodayNames: List of [Text];
        ItemName: Text;
        MsgTxt: Text;
    begin
        // Resolve current date (same pattern as your Compliance code)
        CurrentDt := CurrentDateTime();
        if CurrentDt = 0DT then
            Error('System datetime is not available');

        TodayDate := DT2Date(CurrentDt);
        if TodayDate = 0D then
            Error('Invalid system date detected');

        // Process only Active subscriptions
        SubRec.Reset();
        if SubRec.FindSet() then
            repeat
                if SubRec.Status <> SubRec.Status::Active then
                    continue;

                if (SubRec."End Date" = 0D) or (SubRec."Reminder Days" <= 0) then
                    continue;

                DaysBeforeDue := SubRec."Reminder Days";
                ReminderStartDate := SubRec."End Date" - DaysBeforeDue;

                // Outside reminder window
                if (TodayDate > SubRec."End Date") or (TodayDate < ReminderStartDate) then
                    continue;

                // De-dup for this day + subscription + configuration
                RemRec.Reset();
                RemRec.SetRange("Reminder Date", TodayDate);
                RemRec.SetRange("Subscription ID", SubRec."Subscription ID");
                RemRec.SetRange("Subscription Due Date", SubRec."End Date");
                RemRec.SetRange("Reminder Lead Time", DaysBeforeDue);

                if not RemRec.FindFirst() then begin
                    // NOTE: Ensure these enum members match your "Reminder Policy" enum
                    case SubRec."Reminder Policy" of
                        SubRec."Reminder Policy"::"One Time":
                            begin
                                if TodayDate = (SubRec."End Date" - DaysBeforeDue) then
                                    InsertReminder(SubRec, DaysBeforeDue, CurrentDt);
                            end;
                        SubRec."Reminder Policy"::"Two Time":
                            begin
                                if TodayDate = (SubRec."End Date" - DaysBeforeDue) then
                                    InsertReminder(SubRec, DaysBeforeDue, CurrentDt)
                                else begin
                                    HalfwayDays := DaysBeforeDue div 2;
                                    if TodayDate = (SubRec."End Date" - HalfwayDays) then
                                        InsertReminder(SubRec, DaysBeforeDue, CurrentDt);
                                end;
                            end;
                        SubRec."Reminder Policy"::"Until Renewal":
                            begin
                                if (TodayDate >= (SubRec."End Date" - DaysBeforeDue)) and (TodayDate <= SubRec."End Date") then
                                    InsertReminder(SubRec, DaysBeforeDue, CurrentDt);
                            end;
                    end;
                end;

                if TodayDate = SubRec."End Date" then
                    DueTodayNames.Add(SubRec."Service Name");

            until SubRec.Next() = 0;

        // Aggregated due-today popup (optional)
        if DueTodayNames.Count > 0 then begin
            MsgTxt := 'The following subscriptions are due today:\n';
            foreach ItemName in DueTodayNames do
                MsgTxt += '• ' + ItemName + '\n';
            Message(MsgTxt);
        end;
    end;

    local procedure InsertReminder(SubRec: Record "Subscription"; LeadTime: Integer; CurrentDt: DateTime)
    var
        RemRec: Record "Subscription Reminder";
        UserRec: Record User;
        UserSetup: Record "User Setup";
        EmailCU: Codeunit Email;
        EmailMsg: Codeunit "Email Message";
        TodayDate: Date;
        DaysLeft: Integer;
        Recipient: Text[2048];
        Subject: Text[250];
        Body: Text[2048];
        EmailSentSuccessfully: Boolean;
    begin
        if (SubRec."End Date" = 0D) or (CurrentDt = 0DT) then
            Error('Invalid parameters for reminder creation');

        TodayDate := DT2Date(CurrentDt);
        if TodayDate = 0D then
            Error('Cannot convert current datetime to date');

        DaysLeft := SubRec."End Date" - TodayDate;

        RemRec.Init();
        RemRec."Subscription ID" := SubRec."Subscription ID";
        RemRec."Subscription Name" := SubRec."Service Name";
        RemRec."Reminder Date" := TodayDate;
        RemRec."Subscription Due Date" := SubRec."End Date";
        RemRec."Reminder Lead Time" := LeadTime;
        RemRec.Message := StrSubstNo('Subscription "%1" due in %2 days', SubRec."Service Name", DaysLeft);
        RemRec."Is Today" := (DaysLeft = 0);
        RemRec."Email Sent" := false;

        RemRec.Insert(true); // Insert with triggers

        // --- Email to current user (fixed: no "User ID" field usage) ---
        EmailSentSuccessfully := false;

        // Preferred: get by security ID (primary key of User table)
        if UserRec.Get(UserSecurityId()) then
            Recipient := UserRec."Contact Email";

        // Fallback: User Setup (by user name)
        if Recipient = '' then
            if UserSetup.Get(UserId()) then
                Recipient := UserSetup."E-Mail";

        if Recipient <> '' then begin
            Subject := StrSubstNo('Subscription Reminder: %1', SubRec."Service Name");
            Body := RemRec.Message;

            EmailMsg.Create(Recipient, Subject, Body, false); // false = plain text
            // If your version throws on failure instead of returning Boolean, wrap in try..end;
            if EmailCU.Send(EmailMsg) then
                EmailSentSuccessfully := true;
        end;

        RemRec."Email Sent" := EmailSentSuccessfully;
        RemRec.Modify(true);
    end;
}
