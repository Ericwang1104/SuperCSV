unit Common;

interface

uses
  {$IFDEF FPC}
    Classes,SysUtils, fgl,DB;
  {$ELSE}
  SysUtils, DB, System.Classes, System.Generics.Collections;
  {$ENDIF}

Type
  THashItem = record
    Key: string;
    Addr: Pointer;
  end;
  {$IFDEF FPC}
    TGenList= specialize TFPGLIST<THashItem>;
  {$ENDIF}
  TLogEvent = procedure(logText: string) of object;
  TProgressEvent = procedure(Caption: string; MaxValue, Pos: double) of object;


  TStringStack = class(TStringList)
  strict private
  private
  public
    procedure DeletePop;
    function PeekItem: string;
    function Pop: string;
    procedure Push(str: string);
  end;

  TItemLevel = class(TObject)
  private
    FLevel: Integer;
    FNodeName: string;
  public
    property Level: Integer read FLevel write FLevel;
    property NodeName: string read FNodeName write FNodeName;

  end;


  { TObjectHash - used internally by TMemIniFile to optimize searches. }

  TObjectHash = class
  private
    {$IFDEF FPC}
       Buckets: array of  TGenList;
    {$ELSE}
       Buckets: array of    TList<THashItem>;
    {$ENDIF}
  protected
    function Find(const Key: string; var AItem: THashItem): Integer;
    function HashOf(const Key: string): Cardinal; virtual;
  public
    constructor Create(Size: Cardinal = 256);
    destructor Destroy; override;
    procedure Add(const Key: string; const Addr: Pointer);
    procedure Clear;
    procedure Remove(const Key: string);
    function Modify(const Key: string; const Addr: Pointer): Boolean;
    function ValueOf(const Key: string): TObject;
    function ValueOfP(const Key: string): Pointer;
  end;

function ExtractAnsiValue(Value: ansistring; var StartPos: Integer): ansistring;

function ExtractWideValue(Value: string; var StartPos: Integer): string;

function InterSectionValue(Value1, Value2: string;
  var ISChanged: Boolean): string;

procedure ExtracCode(Code: string; var CodeParnet, CodeChild: string);

procedure SplitQVar(CodeName: string; out Parent, Child: string); inline;

function IsNumber(chr: char): Boolean;

procedure GetLimitValue(Val: string; var Min_Select, Max_Select: Integer);

function SplitNext(FullCode: string; ParentPath: string = ''): string;

function GetDataType(DataType: string): TFieldType;

function StrIsNumber(Val: string): Boolean;

function GetParent(const Path: string): string;

function GetFileNameForward(FileName: string): string;

function GetItem(Value: string; var Pos: Integer): string;



procedure RestoryFile(PointFileName, WaveFileName: string);

function ValueInSet(Val, ValSet: string): Boolean;

function ExtractValue(Value: string; var StartPos: Integer;
  SpChar: char = ','): string;

function ReplaceCodeItem(str: string): string;
// 返回类似Excel 的字符编号列头
function GetCharNo(const ColNo: Integer): string;

function CheckVersion(const OldVersion: string; NewVersion: string): Boolean;

function GetIntVersion(const strVer: string): Int64;

function GetSubVersion(const strVer: string; var EPos: Integer): string;

function FileVersion(FileName: string): string;

implementation

uses Windows, StrUtils;





function InterSectionValue(Value1, Value2: string;
  var ISChanged: Boolean): string;
var
  Item: string;
  intPos: Integer;
begin
  ISChanged := false;
  Result := '';
  intPos := 1;
  Item := ExtractWideValue(Value1, intPos);
  if Value2[1] <> ';' then
    Value2 := ';' + Value2;
  while Item <> '' do
  begin
    if Pos(';' + Item + ';', Value2) > 0 then
    begin
      Result := Result + Item + ';'
    end
    else
    begin
      ISChanged := True;
    end;
    Item := ExtractWideValue(Value1, intPos)
  end;

end;

procedure ExtracCode(Code: string; var CodeParnet, CodeChild: string);
var
  I: Integer;
begin

  for I := Length(Code) downto 1 do
  begin
    if Code[I] = '.' then
    begin
      CodeParnet := Copy(Code, 1, I - 1);
      CodeChild := Copy(Code, I + 1, Length(Code) - I);
      Exit;
    end;
  end;
  CodeChild := Code;

end;

procedure SplitQVar(CodeName: string; out Parent, Child: string);
var
  I: Integer;
  CodeLen: Integer;
begin
  CodeLen := Length(CodeName);
  for I := 1 to CodeLen - 1 do
  begin
    if CodeName[I] = '.' then
    begin
      Parent := Copy(CodeName, 1, I - 1);
      Child := Copy(CodeName, I + 1, CodeLen - I);
      Exit;
    end;
  end;
  Parent := CodeName;
  Child := '';

end;

function IsNumber(chr: char): Boolean;
begin
  Result := (Ord(chr) >= 48) and (Ord(chr) <= 57);

end;



function SplitNext(FullCode: string; ParentPath: string = ''): string;
var
  Index: Integer;
  I: Integer;
begin
  if Pos(ParentPath, FullCode) > 0 then
  begin
    Index := Length(ParentPath);
  end
  else
  begin
    index := 1;
  end;
  if Index <= 0 then
  begin
    Result := '';
  end
  else
  begin

    for I := Index + 2 to Length(FullCode) do
    begin
      if FullCode[I] = '.' then
      begin
        Result := Copy(FullCode, 1, I - 1);
        Exit;
      end;
    end;
  end;
  Result := FullCode;
end;

function GetDataType(DataType: string): TFieldType;
begin
  if DataType = 'DOUBLE' then
  begin
    Result := ftFloat;
  end
  else if DataType = 'TEXT' then
  begin
    Result := ftString;
  end
  else if DataType = 'DATE' then
  begin
    Result := ftDateTime;
  end
  else if DataType = 'TIME' then
  begin
    Result := ftDateTime;
  end
  else if DataType = 'DATETIME' then
  begin
    Result := ftDateTime;
  end
  else if DataType = 'BOOLEAN' then
  begin
    Result := ftBoolean;
  end
  else if DataType = 'INTEGER' then
  begin
    Result := ftInteger;
  end
  else if DataType = 'ENUM' then
  begin
    Result := ftSmallint;
  end
  else if DataType = 'SMALLINT' then
  begin
    Result := ftSmallint;
  end
  else if DataType = 'LARGEINT' then
  begin
    Result := ftLargeint;
  end
  else if DataType = 'REF' then
  begin
    Result := ftReference;
  end
  else
  begin
    raise Exception.Create('Not Support This Data Type:' + DataType);
  end;

end;

function StrIsNumber(Val: string): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(Val) do
  begin
    if not IsNumber(Val[I]) then
    begin
      Result := false;
      Exit;
    end;
  end;
  Result := True;
end;

function GetParent(const Path: string): string;
var
  I: Integer;
begin
  for I := Length(Path) downto 1 do
  begin
    if Path[I] = '.' then
    begin
      Result := Copy(Path, 1, I - 1);
      Exit;
    end;
  end;
  Result := Path;
end;

function GetFileNameForward(FileName: string): string;
var
  I: Integer;
begin
  for I := Length(FileName) downto 1 do
  begin
    if FileName[I] = '.' then
    begin
      if I > 1 then
      begin
        Result := Copy(FileName, 1, I - 1);
        Exit;

      end
      else
      begin
        Result := FileName;
        Exit;
      end;
    end;
  end;
  Result := FileName;
end;

function GetItem(Value: string; var Pos: Integer): string;
var
  I: Integer;
begin
  for I := Pos to Length(Value) do
  begin
    if Value[I] = ',' then
    begin
      Result := Copy(Value, Pos, I - Pos);
      Pos := I + 1;
      Exit;
    end;
  end;
  Result := Copy(Value, Pos, Length(Value) - Pos + 1);
  Pos := Length(Value) + 1;

end;







function ExtractValue(Value: string; var StartPos: Integer;
  SpChar: char = ','): string;
var
  I: Integer;
  len: Integer;
begin
  len := Length(Value);
  for I := StartPos to len do
  begin
    if (Value[I] = SpChar) then
    begin
      Result := Copy(Value, StartPos, I - StartPos);
      StartPos := I + 1;
      Exit;
    end
    else if I = len then
    begin
      Result := Copy(Value, StartPos, len);
      StartPos := I + 1;
      Exit;
    end;
  end;
  Result := '';

end;





procedure TStringStack.DeletePop;
begin
  Delete(self.Count - 1);
end;

function TStringStack.PeekItem: string;
begin
  Result := self.Strings[self.Count - 1];
end;

function TStringStack.Pop: string;
begin
  Result := PeekItem;
  Delete(self.Count - 1);
end;

procedure TStringStack.Push(str: string);
begin
  self.Add(str);
end;

{ TObjectHash }

procedure TObjectHash.Add(const Key: string; const Addr: Pointer);
var
  Hash: Integer;
  Item: THashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  Item.Key := Key;
  Item.Addr := Addr;
  Buckets[Hash].Add(Item);
end;

procedure TObjectHash.Clear;
var
  I: Integer;
begin
  for I := 0 to Length(Buckets) - 1 do
  begin
    Buckets[I].Clear;
  end;
end;

constructor TObjectHash.Create(Size: Cardinal);
var
  I: Integer;
begin
  inherited Create;
  SetLength(Buckets, Size);
  for I := 0 to Size - 1 do
  begin
    {$IFDEF FPC}
     Buckets[I] :=TGenList.Create;
    {$ELSE}
    Buckets[I] := TList<THashItem>.Create;
    {$ENDIF}
  end;
end;

destructor TObjectHash.Destroy;
var
  I: Integer;
begin
  Clear;
  for I := 0 to Length(Buckets) - 1 do
  begin
    Buckets[I].Free;
    Buckets[I] := nil;
  end;
  inherited Destroy;
end;

function TObjectHash.Find(const Key: string; var AItem: THashItem): Integer;
var
  Hash: Integer;
  Pos: Integer;
begin
  Result := -1;
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  if Buckets[Hash] <> nil then
  begin
    Pos := 0;
    while Pos < Buckets[Hash].Count do
    begin
      if Buckets[Hash][Pos].Key = Key then
      begin
        Result := Pos;
        AItem := Buckets[Hash][Pos];
        Break;
      end;
      Inc(Pos, 1);
    end;
  end;
end;

function TObjectHash.HashOf(const Key: string): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Key.Length - 1 do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2)))
      xor Ord(Key.Chars[I]);
end;

function TObjectHash.Modify(const Key: string; const Addr: Pointer): Boolean;
var
  Hash: Integer;
  Pos: Integer;
  Item: THashItem;
begin
  Pos := Find(Key, Item);
  if Pos >= 0 then
  begin
    Result := True;
    Hash := HashOf(Key) mod Cardinal(Length(Buckets));
    Item.Addr := Addr;
    Buckets[Hash].Items[Pos] := Item;
  end
  else
    Result := false;
end;

procedure TObjectHash.Remove(const Key: string);
var
  Hash: Integer;
  Item: THashItem;
  Pos: Integer;
begin
  Pos := Find(Key, Item);
  if Pos >= 0 then
  begin
    Hash := HashOf(Key) mod Cardinal(Length(Buckets));
    Buckets[Hash].Delete(Pos);
  end;
end;

function TObjectHash.ValueOf(const Key: string): TObject;
var
  Item: THashItem;
  Pos: Integer;
begin
  Pos := Find(Key, Item);
  if Pos >= 0 then
    Result := TObject(Item.Addr)
  else
    Result := nil;
end;

function TObjectHash.ValueOfP(const Key: string): Pointer;
var
  Item: THashItem;
  Pos: Integer;
begin
  Pos := Find(Key, Item);
  if Pos >= 0 then
    Result := Item.Addr
  else
    Result := nil;
end;

end.
