unit TestCase1;
{$IFDEF  FPC}
{$mode objfpc}{$H+}
 {$ENDIF}
interface

uses
{$IFDEF  FPC}
  classes,SysUtils, ObjectHash, fpcunit, GuiTestRunner, testutils,testregistry;
{$ELSE}
		TestFramework, classes, GuiTestRunner, SysUtils, ObjectHash;
{$ENDIF}
type



  { TTestCase1 }

  TTestCase1= class(TTestCase)
  private
    FHash:TObjectHash;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Testhash;
  end;

implementation

procedure TTestCase1.Testhash;
var
  Obj,obj2:TComponent;
begin
  obj :=TComponent.Create(nil);
  try

    FHash.Add(obj.ClassName,obj);
    obj.Name:= 'component1';
    obj2 := FHash.ValueOf(obj.ClassName) as TComponent;
    checkequals(obj.Name,obj2.Name,'obj  name is :'+obj.Name);

    CheckEquals(Fhash.Count,1);
  finally
    FreeAndnil(Obj);
  end;

end;

procedure TTestCase1.SetUp;
begin
  FHash :=TObjectHash.Create(4096);
end;

procedure TTestCase1.TearDown;
begin
  FreeAndNil(FHash);
end;

initialization
  {$IFDEF  FPC}
  RegisterTest(TTestCase1);
  {$ELSE}
  	RegisterTest(TTestCase1.Suite);
  {$ENDIF}
end.

