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
                field("Card Image"; Rec."Card Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Upload an image for this payment method card.';
                }
                field("Managed By"; Rec."Managed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee who manages this payment method.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(); // Refresh the FlowField
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EmployeeExt: Record "Employee Ext";
                        EmployeeExtList: Page "Employee Ext List";
                    begin
                        EmployeeExt.SetRange(Status, EmployeeExt.Status::Active);
                        EmployeeExt.SetRange(Blocked, false);
                        EmployeeExtList.SetTableView(EmployeeExt);
                        EmployeeExtList.LookupMode(true);
                        if EmployeeExtList.RunModal() = Action::LookupOK then begin
                            EmployeeExtList.GetRecord(EmployeeExt);
                            Rec."Managed By" := EmployeeExt."No.";
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Name';
                    ToolTip = 'Shows the full name of the selected employee.';
                    Style = StandardAccent;
                }
                field("Expires At"; Rec."Expires At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this payment method expires.';
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
                        CurrPage.Update();
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
                        FileName := 'PaymentMethodImage_' + Rec.Name + '.jpg';
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
                            CurrPage.Update();
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
                            EmployeeExtCard.Run();
                        end else
                            Message('Employee %1 not found.', Rec."Managed By");
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.Update();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Update();
    end;
}
