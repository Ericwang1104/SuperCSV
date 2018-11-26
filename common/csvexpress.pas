unit csvexpress;
{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF}
interface

uses
  Classes, SysUtils, expressutils, csvreader;
type
   { TCsvColumnVar }
  TCsvVarBuilder=class;
  TCsvColumnVar=class(TExpressNode)

  private
    FCSvVarBuilder:TCsvVarBuilder;
    FColItem:TColumnItem;
    FstrValue:string;
    function IsInteger(const str: string): Boolean;
  public
    procedure Process();override;
    function AsBoolean():Boolean;override;
    function AsInteger():int64;override;
    property ColItem:TColumnItem read FColItem write FColitem;
  end;
  { TCsvVarBuilder }

  TCsvVarBuilder=class(TOperatorBuilder)
    FCsv:TCsvReader;
  public
    function BuildVariable(VarName:string): TExpressNode;override;
    property CSV :TCsvReader read FCsv write FCsv;

  end;



implementation

{ TCsvColumnVar }

function TCsvColumnVar.IsInteger(const str: string): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(str) do
  begin
    if not  (str[I] in ['0'..'9']) then
    begin
      result :=False;
      exit;
    end;
  end;
  result :=true;
end;

procedure TCsvColumnVar.Process;
begin
  //
  if Assigned(FcolItem.PCsvColData^.PS) then
  begin
    case FColitem.ColType of
      cUnknow,cString:
      begin
        FstrValue:=FcolItem.ValueAsString;
        FValue :=FStrValue;

      end;
      cByte: FValue :=FColItem.ValueAsByte() ;
      cSmallint: FValue :=FColitem.ValueAsSmallInt();
      cInteger : FValue :=FColitem.ValueAsInteger();
      cInt64 : FValue :=FColItem.ValueAsInt64();
      cFloat : FValue :=FColItem.ValueAsFloat();
      cDate : FValue :=FColitem.ValueAsDate();
      cDatetime : FValue :=FColItem.ValueAsDateTime();
    else
     FstrValue:=FcolItem.ValueAsString;
    end;
  FStrValue :=FColitem.PCsvColData^.AsRawString;

  end else
  begin

    FStrValue :='';

  end;
   FValue :=FStrValue;
end;

function TCsvColumnVar.AsBoolean: Boolean;
begin
  if IsInteger(FStrValue) then
  begin
    if strToint(FstrValue) >0 then
    begin
      result :=true
    end else
    begin
      result :=false;
    end;
  end else
  begin
    result :=false;
  end;
end;

function TCsvColumnVar.AsInteger: int64;
begin
  if IsInteger(FStrValue) then
  begin
    result :=StrToInt(FStrValue);
  end else
  begin
    FillChar(result,Sizeof(result),$FF);
  end;

end;

{ TCsvVarBuilder }

function TCsvVarBuilder.BuildVariable(VarName: string): TExpressNode;
var
  CsvVar:TCsvColumnVar;
  ColItem:TColumnItem;
begin
  if Fcsv.Columns.ColumnExists(VarName) then
  begin
  CsvVar := TCsvColumnVar.Create(FExpNodes);
  csvVar.OperatorType:= oVar;
  CsvVar.ColItem :=FCsv.Columns.ColumnByName(VarName);
  result :=CsvVar;

  end else
  begin
    ExpressError('Var name "%s" is not exists',[VarName]);
  end;

end;

end.

