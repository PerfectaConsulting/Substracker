page 50129 "Custom Payment Method Card"
{
    ApplicationArea = All;
    Caption = 'Custom Payment Method Card';
    PageType = Card;
    SourceTable = "Custom Payment Method";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Information';

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique code for the payment method.';
                    ShowMandatory = true;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the payment method.';
                    ShowMandatory = true;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the payment method.';
                    ShowMandatory = true;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the payment method.';
                    MultiLine = true;
                }

                field("Expires At"; Rec."Expires At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this payment method expires.';
                }
            }

            group(Management)
            {
                Caption = 'Management';

                field("Managed By"; Rec."Managed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee who manages this payment method.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Name';
                    ToolTip = 'Shows the full name of the selected employee.';
                    Style = StandardAccent;
                    Editable = false;
                }
            }

            group(ImageGroup)
            {
                Caption = 'Card Image';

                field("Card Image"; Rec."Card Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Upload an image for this payment method card.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportImage)
            {
                ApplicationArea = All;
                Caption = 'Import Image';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import an image file for the payment method card.';

                trigger OnAction()
                var
                    InStr: InStream;
                    FileName: Text;
                begin
                    if UploadIntoStream('Import Image', '', 'Image Files (*.jpg;*.jpeg;*.png;*.gif;*.bmp)|*.jpg;*.jpeg;*.png;*.gif;*.bmp', FileName, InStr) then begin
                        Rec."Card Image".ImportStream(InStr, FileName);
                        if not Rec.Modify(true) then
                            Rec.Insert(true);
                        CurrPage.Update(false);
                        Message('Image imported successfully.');
                    end;
                end;
            }

            action(ExportImage)
            {
                ApplicationArea = All;
                Caption = 'Export Image';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export the payment method card image.';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                    InStr: InStream;
                    FileName: Text;
                begin
                    if Rec."Card Image".HasValue then begin
                        FileName := 'PaymentMethodImage_' + Rec."Code" + '.jpg';
                        TempBlob.CreateOutStream(OutStr);
                        Rec."Card Image".ExportStream(OutStr);
                        TempBlob.CreateInStream(InStr);
                        DownloadFromStream(InStr, 'Export Image', '', '', FileName);
                        Message('Image exported successfully.');
                    end else
                        Message('No image to export.');
                end;
            }

            action(DeleteImage)
            {
                ApplicationArea = All;
                Caption = 'Delete Image';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete the payment method card image.';

                trigger OnAction()
                begin
                    if Rec."Card Image".HasValue then begin
                        if Confirm('Do you want to delete the image?') then begin
                            Clear(Rec."Card Image");
                            Rec.Modify(true);
                            CurrPage.Update(false);
                            Message('Image deleted successfully.');
                        end;
                    end else
                        Message('No image to delete.');
                end;
            }
        }

        area(Navigation)
        {
            action(ViewEmployee)
            {
                ApplicationArea = All;
                Caption = 'View Employee';
                Image = Employee;
                ToolTip = 'View the details of the managing employee.';
                Enabled = Rec."Managed By" <> '';

                trigger OnAction()
                var
                    EmployeeExt: Record "Employee Ext";
                    EmployeeExtCard: Page "Employee Ext Card";
                begin
                    if Rec."Managed By" <> '' then begin
                        if EmployeeExt.Get(Rec."Managed By") then begin
                            EmployeeExtCard.SetRecord(EmployeeExt);
                            EmployeeExtCard.RunModal();
                        end else
                            Message('Employee %1 not found.', Rec."Managed By");
                    end;
                end;
            }
        }
    }
}
