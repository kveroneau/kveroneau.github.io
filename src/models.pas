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

{$R AdminApp/website.json}

{ TWebsiteDB }

constructor TWebsiteDB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Datafile:='website';
  Active:=True;
end;

end.

