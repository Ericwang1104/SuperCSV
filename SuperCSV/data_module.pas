unit data_module;
{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF}
interface

uses
  Classes, SysUtils, FileUtil,CSVReader;

type

  { TDM }

  TDM = class(TDataModule)

    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

  private

  public

  end;

var
  DM: TDM;

implementation

{$R *.lfm}

{ TDM }

procedure TDM.DataModuleCreate(Sender: TObject);
begin

end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin

end;

end.

