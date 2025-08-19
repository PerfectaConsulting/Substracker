enum 50121 "Subscription Status"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Inactive)
    {
        Caption = 'Inactive';
    }
    value(3; Cancelled)
    {
        Caption = 'Cancelled';
    }
    value(4; Expired)
    {
        Caption = 'Expired';
    }
}
