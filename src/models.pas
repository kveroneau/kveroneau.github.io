unit models;

{$mode objfpc}

interface

uses
  Classes, SysUtils, browserconsole, jsontable;

type

  { TWebsiteDB }

  TWebsiteDB = class(TJSONTable)
  private

  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$IFDEF EMBEDSITE}
{$R AdminApp/website.json}
{$ENDIF}

{ TWebsiteDB }

constructor TWebsiteDB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Datafile:='website';
  {$IFDEF EMBEDSITE}
  Active:=True;
  {$ENDIF}
end;

end.

