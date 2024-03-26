unit widgets;

{$mode ObjFPC}

interface

uses
  Web, bulma;

var
  TabSys: TBulmaTabs;
  EditTab, GridTab: TBulmaTab;
  TabBody: TBulmaWidget;

function GetElement(ElementId: string): TJSHTMLElement;
function MakeButton(ElementId, Title: string; onclick: THTMLClickEventHandler): TJSHTMLButtonElement;
function MakeInputField(ElementId, Title, AValue: string): TJSHTMLInputElement;
procedure InitTabs;

implementation

function GetElement(ElementId: string): TJSHTMLElement;
begin
  Result:=TJSHTMLElement(document.getElementById(ElementId));
end;

function MakeButton(ElementId, Title: string; onclick: THTMLClickEventHandler
  ): TJSHTMLButtonElement;
begin
  TabBody.Write('<button id="'+ElementId+'">'+Title+'</button>');
  Result:=TJSHTMLButtonElement(GetElement(ElementId));
  Result.onclick:=onclick;
end;

function MakeInputField(ElementId, Title, AValue: string): TJSHTMLInputElement;
begin
  TabBody.Write('<strong>'+Title+':</strong> ');
  TabBody.Write('<input id="'+ElementId+'" type="text" value="'+AValue+'"/>');
  Result:=TJSHTMLInputElement(GetElement(ElementId));
end;

procedure InitTabs;
begin
  TabSys:=TBulmaTabs.Create(Nil, 'TabSys');
  TabBody:=TBulmaWidget.Create(Nil, 'TabBody');
end;

initialization
  InitTabs;

end.

