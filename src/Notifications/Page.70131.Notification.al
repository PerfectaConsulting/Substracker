page 70131 "Notification"
{
    PageType = List;
    SourceTable = "Compliance Reminder";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Notifications';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Compliance Name"; Rec."Compliance Name")
                {
                    ToolTip = 'Specifies the name of the compliance task.';
                }
                field("Reminder Date"; Rec."Reminder Date")
                {
                    ToolTip = 'Specifies when the reminder was generated.';
                }
                field("Compliance Due Date"; Rec."Compliance Due Date")
                {
                    ToolTip = 'Specifies the due date of the compliance task.';
                    StyleExpr = DueDateStyle;
                }
                field("Reminder Lead Time"; Rec."Reminder Lead Time")
                {
                    ToolTip = 'Specifies days before due date when reminders start.';
                }
                field(Message; Rec.Message)
                {
                    ToolTip = 'Specifies the notification message.';
                }
                field("Days Until Due"; Rec."Compliance Due Date" - Today)
                {
                    Caption = 'Days Until Due';
                    ToolTip = 'Specifies remaining days until due date.';
                }
                field("Email Sent"; Rec."Email Sent")
                {
                    ToolTip = 'Indicates if an email was sent for this reminder.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Dismiss")
            {
                ApplicationArea = All;
                Caption = 'Dismiss';
                Image = Cancel;
                ToolTip = 'Dismiss this notification';

                trigger OnAction()
                begin
                    if Rec.FindSet() then
                        Rec.DeleteAll(true);
                    Message('All notifications dismissed.');
                end;
            }
            action("Refresh")
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refresh notifications';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ReminderGen: Codeunit "ReminderGenerator";
    begin
        ReminderGen.GenerateReminders();
    end;

    trigger OnAfterGetRecord()
    begin
        DueDateStyle := SetDueDateStyle();
    end;

    var
        DueDateStyle: Text;

    local procedure SetDueDateStyle(): Text
    begin
        if Rec."Compliance Due Date" = Today then
            exit('Attention')
        else
            exit('');
    end;
}