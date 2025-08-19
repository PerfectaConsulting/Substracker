enum 50130 "Payment Method Type"
{
    Extensible = true;
    Caption = 'Payment Method Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Credit Card")
    {
        Caption = 'Credit Card';
    }
    value(2; "Debit Card")
    {
        Caption = 'Debit Card';
    }
    value(3; "Bank Transfer")
    {
        Caption = 'Bank Transfer';
    }
    value(4; "Cash")
    {
        Caption = 'Cash';
    }
    value(5; "Digital Wallet")
    {
        Caption = 'Digital Wallet';
    }
}
