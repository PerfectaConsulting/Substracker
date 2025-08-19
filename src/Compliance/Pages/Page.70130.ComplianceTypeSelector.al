page 70130 "Compliance Type Selector"
{
    PageType = List;
    SourceTable = "Compliance Overview";
    ApplicationArea = All;
    Caption = 'Select Compliance Type';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Compliance Name"; Rec."Compliance Name") { }
                field("Filing Recurring Frequency"; Rec."Filing Recurring Frequency") { }
                field("Governing Authority"; Rec."Governing Authority") { }
            }
        }
    }


}