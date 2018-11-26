unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, KGrids, KGraphics,  Forms, Controls,
  Graphics, Dialogs, ActnList, ComCtrls, Menus, ExtCtrls, StdCtrls, Buttons,
  Spin, Grids, Clipbrd, data_module, frm_About, frm_filter, csvreader,
  csvengine, strutils, eventlog, Types,frm_defineheader;

type

  { TfrmMain }

  TfrmMain = class(TForm)


    actExit: TAction;
    actClose: TAction;
    actExport: TAction;
    actAbout: TAction;
    actHelp: TAction;
    actCopy: TAction;
    actFilterEnable: TAction;
    actCodeConvert: TAction;
    actDefineHeader: TAction;
    actLoadHeader: TAction;
    actSetFilter: TAction;
    actOpen: TAction;
    ActionList1: TActionList;
    chkSplitFile: TCheckBox;
    combSplitUnit: TComboBox;
    ImageList1: TImageList;
    Grid: TKGrid;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    dlgOpen: TOpenDialog;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    dlgSave: TSaveDialog;
    sbtnFirst: TSpeedButton;
    sbtnPre: TSpeedButton;
    sbtnNext: TSpeedButton;
    sbtnLast: TSpeedButton;
    spEdit: TSpinEdit;
    spSplitSize: TSpinEdit;
    stBar: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure actAboutExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCodeConvertExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actDefineHeaderExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure actFilterEnableExecute(Sender: TObject);
    procedure actLoadHeaderExecute(Sender: TObject);
    procedure actSetFilterExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure chkSplitFileChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect;
      State: TKGridDrawState);
    procedure GridMouseClickCell(Sender: TObject; ACol, ARow: Integer);
    procedure GridMouseEnterCell(Sender: TObject; ACol, ARow: Integer);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure spEditEditingDone(Sender: TObject);
    procedure sbtnFirstClick(Sender: TObject);
    procedure sbtnPreClick(Sender: TObject);
    procedure sbtnNextClick(Sender: TObject);
    procedure sbtnLastClick(Sender: TObject);
  private
    FE:TCSVEngine;
    FLoaedData:boolean;
    FPageCount :integer;
    FCurrentPage:integer;
    FCurrentCol:integer;
  public
    procedure RefreshGrid;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.spEditEditingDone(Sender: TObject);
begin
  if FLoaedData then
  begin
    if spedit.Value <=FE.BufferCount then
    begin
      FE.MoveToBuffer(spEdit.Value-1);
      FE.BuildDataIndex();
      FcurrentPage :=spEdit.Value;
      RefreshGrid;
    end;
  end;
end;

procedure TfrmMain.sbtnFirstClick(Sender: TObject);
begin
  spedit.Value:= 1;
  spedit.EditingDone;
end;

procedure TfrmMain.sbtnPreClick(Sender: TObject);
begin
  if spedit.Value >spedit.MinValue then
  begin
    spedit.Value:= spedit.Value-1;
    spedit.EditingDone;
  end;
end;

procedure TfrmMain.sbtnNextClick(Sender: TObject);
begin
  if spedit.Value <spedit.MaxValue then
  begin
    spedit.Value :=spedit.Value +1;
    spedit.EditingDone;
  end;
end;

procedure TfrmMain.sbtnLastClick(Sender: TObject);
begin
  spedit.Value:= spedit.MaxValue;
  spedit.EditingDone;
end;

procedure TfrmMain.RefreshGrid;
begin
  grid.focuscell(1, 1);
  FE.BuildMatrixIndex();
  //grid.RowCount :=FE.BufferRowCount+1;
  Grid.RowCount:=FE.IndexRowCount+1;
  grid.Refresh;
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
var
  ForeCastCount:integer;
  FileName:string;
  ExtName :string;
begin
  //
  if dlgopen.Execute then
  begin
    FileName :=dlgopen.FileName;

    ExtName :=LowerCase( ExtractFileExt(FileName));
    if ExtName='.csv' then
    begin
      FE.DelimiterChar:= ',';
    end else
    if ExtName='.txt' then
    begin
      FE.DelimiterChar:= #9;
    end;
    actFilterEnable.Checked :=false;

    FE.OpenCSVFile(dlgopen.FileName,actLoadHeader.Checked);
    grid.FixedRows:=1;
    grid.FixedCols:=1;
    grid.ColCount:= FE.ColCount+1;
    FPageCount :=FE.BufferCount;
    ForeCastCount :=FE.ForeCastBufferRowCount;
    spedit.MaxValue :=FE.BufferCount;
    spedit.MinValue:= 1;
    spedit.Value:= 1;
    fcurrentPage :=spedit.Value-1;
    FE.MoveToBuffer(FcurrentPage);
    FE.BuildDataIndex();

    Grid.RowCount:= FE.BufferRowCount+1;

    grid.FocusCell(1,1);
    stbar.Panels[0].Text:='1 records  '+ 'page '+inttostr(spedit.Value)+' of  '+inttostr(FE.BufferCount);
    FLoaedData :=true;
  end;
end;

procedure TfrmMain.chkSplitFileChange(Sender: TObject);
begin
  if chkSplitFile.Checked then
  begin
    spSplitSize.Enabled :=true;
    combSplitUnit.Enabled:= true;
  end else
  begin
    spSplitSize.Enabled:=false;
    combSplitUnit.Enabled:=false;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FLoaedData :=false;
  FE :=TCSvEngine.Create(nil);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FE);
end;

procedure TfrmMain.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  R: TRect; State: TKGridDrawState);
var
  Col:TColumnItem;
begin
  //
  GRid.CellPainter.Attributes:=[taEndEllipsis];
  if FLoaedData then
  begin
    if ARow=0 then
    begin
      if (ACol>0) and (ACol<=FE.ColCount) and ( FE.ColCount>0)  then
      begin
        grid.CellPainter.Text:=FE.ColumnName[ACol-1];
      end else
      if ACol=0 then
      begin
        Grid.CellPainter.Text:= 'No';
      end;
    end else
    begin
      //load data
      if ACol>0 then
      begin
        grid.CellPainter.Text:= FE.CellData[ARow-1,ACol-1];
      end else
      begin
        Grid.CellPainter.Text:= IntTostr(AROW);
      end;
    end;
  end;
  Grid.CellPainter.DefaultDraw();

end;

procedure TfrmMain.GridMouseClickCell(Sender: TObject; ACol, ARow: Integer);
begin
  FCurrentCol :=ACol;
end;

procedure TfrmMain.GridMouseEnterCell(Sender: TObject; ACol, ARow: Integer);
begin
   FCurrentCol :=ACol;
end;

procedure TfrmMain.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  stbar.Panels[0].Text:=IntTostr(ARow)+' records  '+ 'page '+inttostr(spedit.value)+' of  '+inttostr(FPageCount);
end;

procedure TfrmMain.actCloseExecute(Sender: TObject);
begin
  //
end;

procedure TfrmMain.actCodeConvertExecute(Sender: TObject);
var
  Col:integer;
begin

  Col :=FCurrentCol-1;
  if Col<= self.FE.ColCount then
  begin
    with self.FE.Reader.Columns[Col] do
    begin
      SouceCodePage:=cp_Western_Windows_Latin1;
      DesCodePage:=cp_UTF8;
      EnableCodeConvert :=true;

    end;
  end;
end;

procedure TfrmMain.actCopyExecute(Sender: TObject);
var
  RowS,RoWE,RowTemp:integer;
  str:string;
  I,J:integer;
begin
  RowS :=grid.Selection.Row1-1;
  RowE :=Grid.Selection.Row2-1;
  if Rows>RowE then
  begin
    RowTEmp :=RowS;
    RowS :=RowE;
    RowE :=RowTemp;
  end;
  Text :='';
  for I := RowS to RowE do
  begin
    for J := 0 to FE.ColCount-1 do
    begin
      if J>0 then
    begin
         str :=str +#9+FE.CellData[I,J];
      end
      else
      begin
        str :=str+FE.CellData[I,J];
      end;
    end;
    {$IFDEF WINDOWS}
      str :=str+#13+#10;
    {$ELSE}
       str :=str+#10;
    {$ENDIF}

  end;

  Clipboard.AsText:= str;
end;

procedure TfrmMain.actDefineHeaderExecute(Sender: TObject);
var
  frm:TfrmDefineHeader;
begin
  frm :=TfrmDefineHeader.Create(nil);
  try

    frm.DefineHeader(FE.Reader.Columns);
  finally
    FreeAndNil(frm);
  end;
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  //
  if MessageDlg('are you sure exit this program?', mtConfirmation, [mbYes, mbNo],0) = mrYes then

     Application.Terminate;
end;

procedure TfrmMain.actExportExecute(Sender: TObject);
var
  SplitSize:int64;

begin
  if dlgSave.Execute then
  begin
    SplitSize :=0;
    if chksplitFile.Checked then
    begin
      if combSplitUnit.Text='KB'then
      begin
        SplitSize :=spsplitSize.Value*1024;
      end else
      if combSplitUnit.Text='MB' then
      begin
        splitSize :=spSplitSize.Value *1024*1024;
      end else
      if combSplitUnit.Text='GB' then
      begin
        SplitSize :=spSplitSize.Value *1024*1024*1024;
      end;
      FE.ExportCSVFile(dlgSave.FileName,true,SplitSize);

    end else
    begin
      FE.ExportCSVFile(dlgSave.FileName);
    end;
    ShowMessage('Export completed!');
  end;
end;

procedure TfrmMain.actFilterEnableExecute(Sender: TObject);
begin
  //
  if actFilterEnable.Checked then
  begin
    FE.FilterActive:=true;
    RefreshGrid;
  end else
  begin
    FE.FilterActive:= false;
  end;
end;

procedure TfrmMain.actLoadHeaderExecute(Sender: TObject);
begin
  actLoadHeader.Checked :=not actLoadHeader.Checked;
end;

procedure TfrmMain.actSetFilterExecute(Sender: TObject);
var
  frm:TfrmFilter;
begin
  frm :=TfrmFilter.Create(nil);
  try
    frm.SetFilterCondition(FE);
    if frm.OK then
    begin
      if FE.Filter<>frm.Express then
      begin
        FE.Filter:= frm.Express;
        if FE.FilterActive then
        begin
          FE.FilterActive:=true;
          RefreshGrid;
        end;
      end;
    end;
  finally
    FreeAndNil(frm);
  end;
end;

procedure TfrmMain.actHelpExecute(Sender: TObject);
begin
  //
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  //
  frmAbout.ShowModal;
end;

end.
