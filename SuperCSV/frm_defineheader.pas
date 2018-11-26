unit frm_defineheader;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,csvreader;

type

  { TfrmDefineHeader }

  TfrmDefineHeader = class(TForm)
    Button1: TButton;
    Button2: TButton;
    txtColumnName: TEdit;
    Label1: TLabel;
    lstColumn: TListBox;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstColumnClick(Sender: TObject);
    procedure txtColumnNameChange(Sender: TObject);
  private
    FColumns:TColumns;
    FInSelect:boolean;
    procedure LoadColumn(const Columns:TColumns);

  public
    procedure DefineHeader(Columns:TColumns);

  end;

var
  frmDefineHeader: TfrmDefineHeader;

implementation

{$R *.lfm}

{ TfrmDefineHeader }

procedure TfrmDefineHeader.FormCreate(Sender: TObject);
begin

end;

procedure TfrmDefineHeader.Button2Click(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmDefineHeader.lstColumnClick(Sender: TObject);
var
  Index:integer;
  Item:TColumnItem;
begin
  if lstColumn.ItemIndex>=0 then
  begin
    FInSelect :=true;
    try
    Index :=lstColumn.ItemIndex;
    Item :=lstColumn.Items.Objects[Index] as TColumnItem;
    txtColumnName.Text :=item.ColumnName;
    finally
      FInSelect :=false;
    end;
  end;
end;

procedure TfrmDefineHeader.txtColumnNameChange(Sender: TObject);
var
  Item:TColumnItem;
  Index:integer;
begin
  if (not FInSelect) and (lstColumn.ItemIndex>=0) then
  begin
      Index :=LstColumn.ItemIndex;
      Item :=lstColumn.Items.Objects[Index] as TColumnItem;
      Item.ColumnName:= txtColumnName.Text;
      if item.ReName(txtColumnName.Text) then
      begin
        lstColumn.Items.Strings[Index] :=item.ColumnName;
      end else
      begin
        ShowMessage('Column Exists!');
      end;
  end;
end;

procedure TfrmDefineHeader.LoadColumn(const Columns: TColumns);
var
  item:TColumnItem;
  I:integer;
begin
  lstColumn.Clear;
  for I := 0 to FColumns.Count-1 do
  begin
    Item :=Columns[I];
    lstColumn.AddItem(Item.ColumnName,Item);
  end;

end;

procedure TfrmDefineHeader.DefineHeader(Columns: TColumns);
begin
  FInSelect:=false;
  FColumns :=Columns;
  LoadColumn(Columns);
  self.ShowModal;
end;

end.

