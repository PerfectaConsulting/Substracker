enum 50127 "Subscription Change Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Creation)
    {
        Caption = 'Creation';
    }
    value(2; Update)
    {
        Caption = 'Update';
    }
    value(3; Renewal)
    {
        Caption = 'Renewal';
    }
    value(4; Cancellation)
    {
        Caption = 'Cancellation';
    }
}
