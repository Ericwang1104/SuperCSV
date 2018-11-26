unit ObjectHash;
{$IFDEF FPC}
{$mode objfpc}{$H+}
 {$ModeSwitch advancedrecords}
 {$ENDIF}
interface

uses
{$IFDEF FPC}
	Classes, SysUtils,fgl ;
{$ELSE}
  Classes, SysUtils,System.Generics.Collections;
{$ENDIF}
type

  { THashItem }

  THashItem = record

    Key: string;
    Addr: Pointer;
    {$IFDEF FPC}
    class operator =(item1,Item2:THashItem):boolean;
    {$ENDIF}

  end;
  {$IFDEF FPC}
    TGenList=specialize TFPGLIST<THashItem>;
  {$ELSE}
    TGenList=TList<THashItem>;
  {$ENDIF}

  { TObjectHash }

  TObjectHash = class
  private
    FCount :Integer;
    Buckets:  array of  TGenList;

  protected
    function Find(const Key: string; var AItem: THashItem): integer;
    function HashOf(const Key: string): cardinal; virtual;
  public
    constructor Create(Size: cardinal = 256);
    destructor Destroy; override;
    function Exits(const Key: string):boolean;
    procedure Add(const Key: string; const Addr: Pointer);
    procedure AddObject(const Key:string;const Obj:TObject);
    procedure Clear;
    procedure Remove(const Key: string);
    function Modify(const Key: string; const Addr: Pointer): boolean;
    function ValueOf(const Key: string): TObject;
    function ValueOfP(const Key: string): Pointer;
    property Count:integer read FCount;
  end;

implementation





{Thashitem}
{$IFDEF  FPC}
class operator THashItem.=(item1, Item2: THashItem): boolean;
begin
  result :=item1.Key=item2.Key;
end;
{$ENDIF}


{TObjctHash}
procedure TObjectHash.Add(const Key: string; const Addr: Pointer);
var
  Hash: integer;
  Item: THashItem;
begin
  Hash := HashOf(Key) mod cardinal(Length(Buckets));
  Item.Key := Key;
  Item.Addr := Addr;
  Buckets[Hash].Add(Item);
  Inc(FCount);
end;

procedure TObjectHash.AddObject(const Key: string; const Obj: TObject);
begin
  add(Key,Obj);
end;

procedure TObjectHash.Clear;
var
  I: integer;
begin

  for I := 0 to Length(Buckets) - 1 do
  begin
    Buckets[I].Clear;
  end;
  FCount :=0;
end;

constructor TObjectHash.Create(Size: cardinal);
var
  I: integer;
begin
  inherited Create;
  SetLength(Buckets, Size);
  for I := 0 to Size - 1 do
  begin
    {$IFDEF FPC}
      Buckets[I] := TGenList.Create;
    {$ELSE}
    Buckets[I] := TList<THashItem>.Create;
    {$ENDIF}
  end;
  FCount :=0;
end;

destructor TObjectHash.Destroy;
var
  I: integer;
begin
  Clear;
  for I := 0 to Length(Buckets) - 1 do
  begin
    Buckets[I].Free;
    Buckets[I] := nil;
  end;
  inherited Destroy;
end;

function TObjectHash.Exits(const Key: string): boolean;
var
  Item:THashItem;
begin
  result:=Find(Key,Item)>=0;
end;

function TObjectHash.Find(const Key: string; var AItem: THashItem): integer;
var
  Hash: integer;
  Pos: integer;
begin
  Result := -1;
  Hash := HashOf(Key) mod cardinal(Length(Buckets));
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

function TObjectHash.HashOf(const Key: string): cardinal;
var
  I: integer;
begin
  Result := 0;
  for I := 0 to Key.Length - 1 do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor Ord(Key.Chars[I]);
end;

function TObjectHash.Modify(const Key: string; const Addr: Pointer): boolean;
var
  Hash: integer;
  Pos: integer;
  Item: THashItem;
begin
  Pos := Find(Key, Item);
  if Pos >= 0 then
  begin
    Result := True;
    Hash := HashOf(Key) mod cardinal(Length(Buckets));
    Item.Addr := Addr;
    Buckets[Hash].Items[Pos] := Item;
  end
  else
    Result := False;
end;

procedure TObjectHash.Remove(const Key: string);
var
  Hash: integer;
  Item: THashItem;
  Pos: integer;
begin

  Pos := Find(Key, Item);
  if Pos >= 0 then
  begin
    Hash := HashOf(Key) mod cardinal(Length(Buckets));
    Buckets[Hash].Delete(Pos);
    dec(FCount);
  end;

end;

function TObjectHash.ValueOf(const Key: string): TObject;
var
  Item: THashItem;
  Pos: integer;
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
  Pos: integer;
begin
  Pos := Find(Key, Item);
  if Pos >= 0 then
    Result := Item.Addr
  else
    Result := nil;
end;

end.
