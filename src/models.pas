unit models;

{$mode objfpc}

interface

uses
  Classes, SysUtils, browserconsole, Web, ExtJSDataset, JS, jsontable;

type

  { TCustomerDB }

  TCustomerDB = class(TJSONTable)
  private
    function GetAddress: string;
    function GetId: Integer;
    function GetMemo: string;
    function GetName: string;
    function GetPhone: string;
    procedure SetId(AValue: Integer);
    procedure SetName(AValue: string);
  public
    constructor Create(AOwner: TComponent); override;
    property Id: Integer read GetId write SetId;
    property Name: string read GetName write SetName;
    property Phone: string read GetPhone;
    property Address: string read GetAddress;
    property Memo: string read GetMemo;
  end;

implementation

{$R database.json}

{ TCustomerDB }

function TCustomerDB.GetAddress: string;
begin
  Result:=StringField('Address');
end;

function TCustomerDB.GetId: Integer;
begin
  Result:=IntField('Id');
end;

function TCustomerDB.GetMemo: string;
begin
  Result:=StringField('Memo');
end;

function TCustomerDB.GetName: string;
begin
  Result:=StringField('Name');
end;

function TCustomerDB.GetPhone: string;
begin
  Result:=StringField('Phone');
end;

procedure TCustomerDB.SetId(AValue: Integer);
begin
  DataSet.Fields.FieldByName('Id').Value:=AValue;
end;

procedure TCustomerDB.SetName(AValue: string);
begin
  DataSet.Fields.FieldByName('Name').Value:=AValue;
end;

constructor TCustomerDB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Datafile:='database';
  Active:=True;
end;

end.

