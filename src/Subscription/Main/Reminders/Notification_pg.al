page 50139 "Notifications"
{
    PageType = List;
    SourceTable = "Notification";
    Caption = 'Notifications';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = true;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                ShowCaption = false;

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'No.';
                    Width = 8;
                    StyleExpr = ReadStyleExpr;
                }

                field("Subscription No."; Rec."Subscription No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Subscription';
                    Width = 15;
                    StyleExpr = ReadStyleExpr;

                    trigger OnDrillDown()
                    var
                        Subscription: Record "Subscription";
                        SubscriptionPage: Page "Add Subscription";
                    begin
                        if Subscription.Get(Rec."Subscription No.") then begin
                            SubscriptionPage.SetRecord(Subscription);
                            SubscriptionPage.Editable(false);
                            SubscriptionPage.Run();
                        end;
                    end;
                }

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Date';
                    Width = 15;
                    StyleExpr = ReadStyleExpr;
                }

                field("Message"; Rec."Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Message';
                    Width = 60;
                    StyleExpr = ReadStyleExpr;
                    MultiLine = false;
                }

                field("Is Read"; Rec."Is Read")
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Width = 10;
                    StyleExpr = ReadStyleExpr;

                    trigger OnValidate()
                    begin
                        Rec.Modify();
                        CurrPage.Update(false);
                    end;
                }

                field(ReadStatusDisplay; GetReadStatusText())
                {
                    ApplicationArea = All;
                    Caption = 'Read Status';
                    Width = 12;
                    Editable = false;
                    StyleExpr = StatusStyleExpr;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup)
            {
                Caption = 'Actions';

                action(MarkAsRead)
                {
                    ApplicationArea = All;
                    Caption = 'Mark as Read';
                    ToolTip = 'Mark the selected notification as read';
                    Image = Approve;
                    Enabled = not Rec."Is Read";

                    trigger OnAction()
                    begin
                        if Rec."Entry No." = 0 then
                            exit;

                        Rec."Is Read" := true;
                        Rec.Modify();
                        CurrPage.Update(false);
                    end;
                }

                action(MarkAsUnread)
                {
                    ApplicationArea = All;
                    Caption = 'Mark as Unread';
                    ToolTip = 'Mark the selected notification as unread';
                    Image = ResetStatus;
                    Enabled = Rec."Is Read";

                    trigger OnAction()
                    begin
                        if Rec."Entry No." = 0 then
                            exit;

                        Rec."Is Read" := false;
                        Rec.Modify();
                        CurrPage.Update(false);
                    end;
                }

                action(MarkAllAsRead)
                {
                    ApplicationArea = All;
                    Caption = 'Mark All as Read';
                    ToolTip = 'Mark all notifications as read for current user';
                    Image = ApprovalSetup;

                    trigger OnAction()
                    var
                        NotificationRec: Record "Notification";
                        Counter: Integer;
                    begin
                        if not Confirm('Mark all your unread notifications as read?') then
                            exit;

                        NotificationRec.SetRange("User ID", UserId);
                        NotificationRec.SetRange("Is Read", false);
                        Counter := NotificationRec.Count();

                        if Counter > 0 then begin
                            NotificationRec.ModifyAll("Is Read", true);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }

            group(ManageGroup)
            {
                Caption = 'Manage';

                action(ClearReadNotifications)
                {
                    ApplicationArea = All;
                    Caption = 'Clear Read Notifications';
                    ToolTip = 'Delete all read notifications for current user';
                    Image = Delete;

                    trigger OnAction()
                    var
                        NotificationRec: Record "Notification";
                        Counter: Integer;
                    begin
                        if Confirm('Delete all read notifications? This cannot be undone.', false) then begin
                            NotificationRec.SetRange("User ID", UserId);
                            NotificationRec.SetRange("Is Read", true);

                            Counter := NotificationRec.Count();
                            if Counter > 0 then begin
                                NotificationRec.DeleteAll(true);
                                CurrPage.Update(false);
                            end;
                        end;
                    end;
                }

                action(RefreshNotifications)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh';
                    ToolTip = 'Refresh the notification list';
                    Image = Refresh;

                    trigger OnAction()
                    var
                        ReminderEvents: Codeunit "Subscription Reminder Events";
                    begin
                        ReminderEvents.CheckAndRunIfNeeded();
                        CurrPage.Update(false);
                    end;
                }
            }

            group(FilterGroup)
            {
                Caption = 'Filter';

                action(ShowUnreadOnly)
                {
                    ApplicationArea = All;
                    Caption = 'Show Unread Only';
                    ToolTip = 'Show only unread notifications';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        Rec.SetRange("Is Read", false);
                        CurrPage.Update(false);
                    end;
                }

                action(ShowAll)
                {
                    ApplicationArea = All;
                    Caption = 'Show All';
                    ToolTip = 'Show all notifications';
                    Image = ClearFilter;

                    trigger OnAction()
                    begin
                        Rec.SetRange("Is Read");
                        CurrPage.Update(false);
                    end;
                }
            }
        }

        area(Promoted)
        {
            group(ProcessPromoted)
            {
                Caption = 'Process';
                actionref(MarkAsRead_Promoted; MarkAsRead) { }
                actionref(MarkAsUnread_Promoted; MarkAsUnread) { }
                actionref(MarkAllAsRead_Promoted; MarkAllAsRead) { }
            }
            group(ManagePromoted)
            {
                Caption = 'Manage';
                actionref(RefreshNotifications_Promoted; RefreshNotifications) { }
                actionref(ClearReadNotifications_Promoted; ClearReadNotifications) { }
            }
        }
    }

    views
    {
        view(UnreadFirst)
        {
            Caption = 'Unread First';
            OrderBy = ascending("Is Read");
        }
        view(NewestFirst)
        {
            Caption = 'Newest First';
            OrderBy = descending("Created Date");
        }
        view(UnreadOnly)
        {
            Caption = 'Unread Only';
            OrderBy = descending("Created Date");
            Filters = where("Is Read" = const(false));
        }
    }

    var
        ReadStyleExpr: Text;
        StatusStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        SetStyleExpressions();
    end;

    trigger OnOpenPage()
    var
        ReminderEvents: Codeunit "Subscription Reminder Events";
    begin
        // Show only notifications for current user
        Rec.SetRange("User ID", UserId);
        Rec.SetCurrentKey("User ID", "Is Read", "Created Date");
        Rec.SetAscending("Created Date", false);

        // Auto-run reminders if not run today (silent)
        ReminderEvents.CheckAndRunIfNeeded();

        // Refresh to show any new notifications
        CurrPage.Update(false);
    end;

    local procedure SetStyleExpressions()
    begin
        if Rec."Is Read" then begin
            ReadStyleExpr := 'Subordinate';
            StatusStyleExpr := 'Favorable';
        end else begin
            ReadStyleExpr := 'Strong';
            StatusStyleExpr := 'Attention';
        end;
    end;

    local procedure GetReadStatusText(): Text
    begin
        if Rec."Is Read" then
            exit('Read')
        else
            exit('New');
    end;
}
