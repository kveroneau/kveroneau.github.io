unit PuterDB;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, jsontable;

{$R initdb.json}

var
  BlogDB: TJSONTable;
  TypesDB: TJSONTable;

procedure InitTypesDB;
function TypesDropDown: string;

implementation

procedure InitTypesDB;
begin
  TypesDB:=TJSONTable.Create(Nil);
  TypesDB.Datafile:='types';
  TypesDB.Active:=True;
end;

function TypesDropDown: string;
begin
  TypesDB.DataSet.First;
  Result:='<b>Content-Type:</b><select id="ftype">';
  repeat
    Result:=Result+'<option value="'+IntToStr(TypesDB.Ints['Id'])+'">'+TypesDB.Strings['Name']+'</option>';
    TypesDB.DataSet.Next;
  until TypesDB.DataSet.EOF;
  Result:=Result+'</select>';
end;


end.

