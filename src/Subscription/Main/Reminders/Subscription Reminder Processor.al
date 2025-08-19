codeunit 50149 "Subscription Reminder Events"
{
    Subtype = Normal;

    procedure ProcessReminders()
    begin
        RunDailyReminders();
    end;

    procedure RunDailyReminders()
    var
        SubscriptionRec: Record "Subscription";
        TodayDate: Date;
        ProcessedCount: Integer;
    begin
        // Clear previous reminders for today
        ClearTodaysReminders();

        ProcessedCount := 0;
        TodayDate := Today;

        // Get qualifying subscriptions
        SubscriptionRec.Reset();
        SubscriptionRec.SetRange(Status, SubscriptionRec.Status::Active);
        SubscriptionRec.SetFilter("Reminder Days", '>0');
        SubscriptionRec.SetFilter("End Date", '>=%1', TodayDate);
        SubscriptionRec.SetFilter("Reminder Policy", '<>%1', SubscriptionRec."Reminder Policy"::" ");

        if not SubscriptionRec.FindSet() then
            exit;

        // Process each subscription silently
        repeat
            if ShouldSendReminderToday(SubscriptionRec, TodayDate) then begin
                if TryCreateNotificationEntry(SubscriptionRec, TodayDate) then
                    ProcessedCount += 1;
            end;
        until SubscriptionRec.Next() = 0;
    end;

    local procedure ShouldSendReminderToday(SubscriptionRec: Record "Subscription"; TodayDate: Date): Boolean
    var
        ReminderDate: Date;
        FirstReminderDate: Date;
        SecondReminderDate: Date;
        StartReminderDate: Date;
        HalfDays: Integer;
    begin
        // Always send on expiry date
        if TodayDate = SubscriptionRec."End Date" then
            exit(true);

        case SubscriptionRec."Reminder Policy" of
            SubscriptionRec."Reminder Policy"::"One Time":
                begin
                    ReminderDate := SubscriptionRec."End Date" - SubscriptionRec."Reminder Days";
                    exit(TodayDate = ReminderDate);
                end;

            SubscriptionRec."Reminder Policy"::"Two Time":
                begin
                    if SubscriptionRec."Reminder Days" < 2 then begin
                        ReminderDate := SubscriptionRec."End Date" - SubscriptionRec."Reminder Days";
                        exit(TodayDate = ReminderDate);
                    end else begin
                        HalfDays := SubscriptionRec."Reminder Days" div 2;
                        FirstReminderDate := SubscriptionRec."End Date" - SubscriptionRec."Reminder Days";
                        SecondReminderDate := SubscriptionRec."End Date" - HalfDays;
                        exit((TodayDate = FirstReminderDate) or (TodayDate = SecondReminderDate));
                    end;
                end;

            SubscriptionRec."Reminder Policy"::"Until Renewal":
                begin
                    StartReminderDate := SubscriptionRec."End Date" - SubscriptionRec."Reminder Days";
                    exit((TodayDate >= StartReminderDate) and (TodayDate <= SubscriptionRec."End Date"));
                end;
        end;

        exit(false);
    end;

    [TryFunction]
    local procedure TryCreateNotificationEntry(SubscriptionRec: Record "Subscription"; TodayDate: Date)
    begin
        CreateNotificationEntry(SubscriptionRec, TodayDate);
    end;

    local procedure CreateNotificationEntry(SubscriptionRec: Record "Subscription"; TodayDate: Date)
    var
        NotificationRec: Record "Notification";
        MsgText: Text[250];
        DaysUntilExpiry: Integer;
    begin
        // Check for duplicates - only for today
        if NotificationExistsToday(SubscriptionRec."No.", UserId) then
            exit; // Silent exit, no error

        DaysUntilExpiry := SubscriptionRec."End Date" - TodayDate;
        MsgText := BuildNotificationMessage(SubscriptionRec, DaysUntilExpiry);

        // Create notification record silently
        Clear(NotificationRec);
        NotificationRec.Init();
        NotificationRec."Subscription No." := SubscriptionRec."No.";
        NotificationRec."Created Date" := CurrentDateTime;
        NotificationRec."Message" := MsgText;
        NotificationRec."Is Read" := false;
        NotificationRec."User ID" := UserId;
        NotificationRec.Insert(true);
    end;

    local procedure NotificationExistsToday(SubscriptionNo: Code[20]; UserID: Code[50]): Boolean
    var
        NotificationRec: Record "Notification";
    begin
        NotificationRec.SetRange("Subscription No.", SubscriptionNo);
        NotificationRec.SetRange("User ID", UserID);
        NotificationRec.SetFilter("Created Date", '%1..%2',
            CreateDateTime(Today, 0T), CreateDateTime(Today, 235959T));

        exit(not NotificationRec.IsEmpty);
    end;

    local procedure BuildNotificationMessage(SubscriptionRec: Record "Subscription"; DaysUntilExpiry: Integer): Text[250]
    var
        MsgText: Text[250];
        EndDateFormatted: Text;
    begin
        EndDateFormatted := Format(SubscriptionRec."End Date", 0, '<Day,2>/<Month,2>/<Year4>');

        case DaysUntilExpiry of
            0:
                MsgText := StrSubstNo('URGENT: "%1" expires TODAY', SubscriptionRec."Service Name");
            1:
                MsgText := StrSubstNo('"%1" expires TOMORROW (%2)', SubscriptionRec."Service Name", EndDateFormatted);
            2 .. 7:
                MsgText := StrSubstNo('"%1" expires in %2 days (%3)', SubscriptionRec."Service Name", DaysUntilExpiry, EndDateFormatted);
            else
                MsgText := StrSubstNo('"%1" renewal reminder - expires on %2', SubscriptionRec."Service Name", EndDateFormatted);
        end;

        if StrLen(MsgText) > 250 then
            MsgText := CopyStr(MsgText, 1, 247) + '...';

        exit(MsgText);
    end;

    local procedure ClearTodaysReminders()
    var
        NotificationRec: Record "Notification";
    begin
        NotificationRec.SetRange("User ID", UserId);
        NotificationRec.SetFilter("Created Date", '%1..%2',
            CreateDateTime(Today, 0T), CreateDateTime(Today, 235959T));

        if not NotificationRec.IsEmpty then
            NotificationRec.DeleteAll();
    end;

    // Simplified version - runs every time page opens
    procedure CheckAndRunIfNeeded()
    begin
        // Check if any notifications exist for today
        if not HasTodaysNotifications() then
            RunDailyReminders();
    end;

    local procedure HasTodaysNotifications(): Boolean
    var
        NotificationRec: Record "Notification";
    begin
        NotificationRec.SetRange("User ID", UserId);
        NotificationRec.SetFilter("Created Date", '%1..%2',
            CreateDateTime(Today, 0T), CreateDateTime(Today, 235959T));

        exit(not NotificationRec.IsEmpty);
    end;
}
