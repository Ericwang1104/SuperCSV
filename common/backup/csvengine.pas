﻿unit csvengine;
{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF}
interface

uses
  Classes, SysUtils, csvreader, expressutils, csvexpress, strutils,objectHash,dbugintf;
type

  { TValueItem }

  TValueItem=class(TCollectionitem)
  private
    FCount: integer;
    FValue: string;
  published
    property Value:string read FValue write FValue;
    property Count:integer read FCount write Fcount;
  end;

  { TValueCollection }

  TValueCollection=class(TCollection)
  private
    FHash:TObjectHash;
  public
    constructor Create(AItemClass: TCollectionItemClass);
    destructor Destroy();
    procedure AddValue(Value:string);
  end;

  { TCSVEngine }

  TCSVEngine=class(TComponent)
  strict private
    FR:TCsvReader;
    FActive:Boolean;
    FFilter:string;
    FFilterActive:boolean;
    FExpr:TExpressParser;
    FBuilder:TCsvVarBuilder;
    FWriteDelimiterChar: PChar;
    FoptNode:TExpressNode;
    function GetActive: Boolean;
    function GetBufferCount: int64;
    function GetBufferRowCount: int64;
    function GetCellData(Row, Col: integer): string;
    function GetColCount: integer;
    function GetColumnName(Index: integer): string;
    function GetDelimiterChar: AnsiChar;
    function GetFilterActive: boolean;
    function GetForeCastBufferRowCount: int64;
    function GetIndexRowCount: integer;
    procedure SetDelimiterChar(const AValue: AnsiChar);
    procedure SetFilter(AValue: string);
    procedure SetFilterActive(AValue: boolean);
    function GetSplitFileName(FileName:string;No:integer):string;
  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy();override;
    procedure OpenCSVFile(FileName:string;LoadHeader:boolean=true;BufferSize:int64= DEFAULT_BUFFER_SIZE);
    procedure ExportCSVFile(FileName:string;SplitFile:boolean=false;SplitSize:int64=0);
    procedure MoveToBuffer(BufferIndex:int64);
    procedure MoveToFirstBuffer();
    procedure BuildDataIndex();
    procedure BuildMatrixIndex();
    procedure GetColumnValueList(ColIndex:integer;lst:TStrings);overload;
    procedure GetColumnValueList(ColName:string;lst:TStrings);overload;
    property DelimiterChar: AnsiChar read GetDelimiterChar write SetDelimiterChar;
    Property Filter :string Read FFilter Write SetFilter;
    property FilterActive:boolean read GetFilterActive write SetFilterActive;
    property BufferRowCount:int64 read GetBufferRowCount;
    property Active :Boolean Read GetActive;
    property BufferCount:int64 read GetBufferCount;
    property ColCount:integer read GetColCount;
    property ForeCastBufferRowCount:int64 read GetForeCastBufferRowCount;
    property ColumnName[Index:integer]:string read GetColumnName;
    property CellData[Row,Col:integer]:string read GetCellData;
    property IndexRowCount:integer read GetIndexRowCount;
    property Reader :TCsvReader read FR ;
  published
    procedure FilterCSV(var blnFilter:boolean);
  end;

implementation

{ TValueCollection }

constructor TValueCollection.Create(AItemClass: TCollectionItemClass);
begin
  inherited;
  FHash :=TObjectHash.Create(65535);
end;

destructor TValueCollection.Destroy;
begin
  FreeAndNil(FHash);
  inherited;
end;

procedure TValueCollection.AddValue(Value: string);
var
  Item:TValueItem;
begin
  if  Assigned(FHash.ValueOf(Value)) then
  begin
    Item :=Fhash.ValueOf(Value) as TValueItem;
    inc(item.FCount);
  end else
  begin
    Item :=TValueItem.Create(Self);
    item.Value:=Value;
    Inc(Item.FCount);
  end;
end;

{ TCSVEngine }

function TCSVEngine.GetDelimiterChar: AnsiChar;
begin
  result :=FR.SplitChar;
end;

function TCSVEngine.GetActive: Boolean;
begin
  result :=FR.Active;
end;

function TCSVEngine.GetBufferCount: int64;
begin
  result :=FR.BufferCount;
end;

function TCSVEngine.GetBufferRowCount: int64;
begin
  result :=FR.BufferRowCount;
end;


function TCSVEngine.GetCellData(Row, Col: integer): string;
var
  PItem:PCsvDataItem;
begin

  if (row<=fr.DataIndex.RowCount) and (Col<= fr.Columns.Count) then
  begin
    result :=fr.GetCellString(Row,Col);
    {PItem :=fr.CellData[Row,Col];
    fr.Columns[Col];
    if Assigned(Pitem) then
    begin
      if Assigned( Pitem^.PS) and Assigned(Pitem^.PE) then
      begin
         result :=Pitem^.AsRawString ;
      end else
      begin
        result :='';
      end;

    end
    else
      result :='';}
  end else
  begin
    result :='';
  end;
end;

function TCSVEngine.GetColCount: integer;
begin
  result :=FR.ColCount;
end;

function TCSVEngine.GetColumnName(Index: integer): string;
begin
  result :=FR.Columns[Index].ColumnName;
end;

function TCSVEngine.GetFilterActive: boolean;
begin
  result :=FFilterActive;
end;

function TCSVEngine.GetForeCastBufferRowCount: int64;
begin
  result :=fr.ForeCastBufferRowCount;
end;

function TCSVEngine.GetIndexRowCount: integer;
begin
  result :=FR.DataIndex.RowCount;
end;

procedure TCSVEngine.SetDelimiterChar(const AValue: AnsiChar);
begin
  FR.SplitChar:= AValue;
end;

procedure TCSVEngine.SetFilter(AValue: string);
begin
  if FFilter=AValue then Exit;
  FFilter:=AValue;
end;



procedure TCSVEngine.SetFilterActive(AValue: boolean);
begin
  if FFilterActive=Avalue then exit;
  if AValue then
  begin
    if not FR.Active then raise exception.Create('you didn''t open csv file');
    FoptNode :=FExpr.Parser(Ffilter);
    {$IFDEF  FPC}
    FR.OnFilterEvent:=@FilterCSV;
    {$ELSE}
      FR.OnFilterEvent :=FilterCSV;
    {$ENDIF}
    BuildMatrixIndex;
    FFilterActive :=true;

  end else
  begin
    FreeAndNil(FoptNode);
    FR.OnFilterEvent :=nil;
    fr.BuildMatrixIndex;
    FFilterActive :=false;
  end;
end;

function TCSVEngine.GetSplitFileName(FileName: string; No: integer): string;
var
 Path,fName,ExtName:string;
 FullName:string;
begin
   Path :=extractfilePath(FileName);
   fName :=ExtractFileName(FileName);
   ExtName :=ExtractFileExt(FileName);
   fName :=ReplaceStr(FName,ExtName,'');
   result:=Path+fName+'_Part'+Inttostr(No)+ExtName;
end;

constructor TCSVEngine.Create(AOwner: TComponent);
begin
  inherited;
  FR :=TCsvReader.Create();
  FExpr :=TExpressParser.Create(nil);
  FBuilder :=TCsvVarBuilder.Create(nil);
  FBuilder.CSV :=FR;
  FExpr.OperatorBuilder :=FBuilder;
end;

destructor TCSVEngine.Destroy();
begin
  FreeAndnil(FBuilder);
  FreeAndnil(FExpr);
  FreeAndNil(FR);
  inherited;
end;

procedure TCSVEngine.OpenCSVFile(FileName: string; LoadHeader: boolean;
  BufferSize: int64);
begin

  FR.OpenFile(FileName,LoadHeader,BufferSize);
end;

procedure TCSVEngine.FilterCSV(var blnFilter:boolean);
begin
  FoptNode.Process;
  blnFilter:= FoptNode.AsBoolean;

end;

procedure TCSVEngine.ExportCSVFile(FileName: string; SplitFile: boolean;
  SplitSize: int64);
var
  WCSV:TCsvWriter;
  No:integer;
  FullName:string;
begin
  WCSV :=TCsvWriter.Create;
  try
    No :=1;
    if SplitFile then
      FullName :=GetSplitFileName(FileName,No)
    else
      FullName :=FileName;
    WCSV.WriteCSVFile(FullName);
    WCSv.AddTitle(FR.Columns.Title);
    if FFilterActive and Assigned(FoptNode) then
    begin
      //筛选状态

      fr.MoveToFirst;
      while fr.ReadLine do
      begin
        FoptNode.Process();

        if FoptNode.AsBoolean then
        begin
          if SplitFile then
          begin
            if wcsv.Size>SplitSize then
            begin
              Inc(No);
              FullName :=GetSplitFileName(FileName,No);
              wcsv.WriteCSVFile(FullName);
              wcsv.AddTitle(FR.Columns.Title);
            end;
          end;
          {$ifopt D+}
            SendInteger('Row No',No);
          {$Endif}
          wcsv.ConvertData(fr.Columns);
          //wcsv.AppendData(FR.PCurrentRow);


        end;
      end;
    end else
    begin
      //非筛选状态
      Fr.MoveToFirst;

      while fr.ReadLine do
      begin
        if SplitFile then
        begin
         if wcsv.Size>SplitSize then
         begin
           Inc(No);
           FullName :=GetSplitFileName(FileName,No);
           wcsv.WriteCSVFile(FullName);
           wcsv.AddTitle(FR.Columns.Title);
         end;
        end;
        {$ifopt D+}
          SendInteger('Row No',No);
        {$Endif}
         wcsv.ConvertData(fr.Columns);
        //wcsv.AppendData(fr.PCurrentRow);
      end;
    end;
  finally
    FreeAndNil(WCSV);
  end;
end;

procedure TCSVEngine.MoveToBuffer(BufferIndex: int64);
begin
  FR.MoveToBuffer(BufferIndex);
end;

procedure TCSVEngine.MoveToFirstBuffer();
begin
  fr.MoveToFirst;
end;

procedure TCSVEngine.BuildDataIndex();
begin
  fr.BuildDataIndex();
end;

procedure TCSVEngine.BuildMatrixIndex();
begin
  fr.BuildMatrixIndex;
end;

procedure TCSVEngine.GetColumnValueList(ColIndex: integer; lst: TStrings);
begin
  lst.Clear;

end;

procedure TCSVEngine.GetColumnValueList(ColName: string; lst: TStrings);
var
  Col:TColumnItem;
begin
  Col:=FR.Columns.ColumnByName(ColName);
  GetColumnValueList(Col.Index,lst);
end;

end.

