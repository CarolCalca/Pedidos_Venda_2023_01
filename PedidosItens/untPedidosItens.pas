unit untPedidosItens;

interface

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.FB,
  FireDAC.DApt,
  FireDAC.VCLUI.Wait,

  System.SysUtils,
  System.Generics.Collections,
  Vcl.Dialogs,

  untPedidosItensInterface;

type
  TPedidosItens = class(TInterfacedObject, IPedidosItens)
  private
    FIdPedItem   : Integer;
    FIdPedGeral  : Integer;
    FIdProduto   : Integer;
    FQuantidade  : Integer;
    FVlrUnitario : Double;
    FVlrTotal    : Double;
  public
    constructor Create();

    procedure Clear();

    procedure SetIdPedItem(const Value: Integer);
    procedure SetIdPedGeral(const Value: Integer);
    procedure SetIdProduto(const Value: Integer);
    procedure SetQuantidade(const Value: Integer);
    procedure SetVlrUnitario(const Value: Double);
    procedure SetVlrTotal(const Value: Double);

    function GetIdPedItem:Integer;
    function GetIdPedGeral:Integer;
    function GetIdProduto:Integer;
    function GetQuantidade:Integer;
    function GetVlrUnitario:Double;
    function GetVlrTotal:Double;

    class function New():IPedidosItens; overload; static;
    class function New(aIdPedGeral, aIdProduto, aQuantidade: Integer; aVlrUnitario, aVlrTotal: Double):IPedidosItens; overload; static;
  end;

 type
   TPedidosItensList = class(TList<IPedidosItens>)
  end;

implementation

{ TPedidosItens }

procedure TPedidosItens.Clear;
begin
  FIdPedItem   := 0;
  FIdPedGeral  := 0;
  FIdProduto   := 0;
  FQuantidade  := 0;
  FVlrUnitario := 0;
  FVlrTotal    := 0;
end;

constructor TPedidosItens.Create;
begin
  Self.Clear;
end;

function TPedidosItens.GetIdPedGeral: Integer;
begin
  Result := fIdPedGeral;
end;

function TPedidosItens.GetIdPedItem: Integer;
begin
  Result := fIdPedItem;
end;

function TPedidosItens.GetIdProduto: Integer;
begin
  Result := fIdProduto;
end;

function TPedidosItens.GetQuantidade: Integer;
begin
  Result := fQuantidade;
end;

function TPedidosItens.GetVlrTotal: Double;
begin
  Result := fVlrTotal;
end;

function TPedidosItens.GetVlrUnitario: Double;
begin
  Result := fVlrUnitario;
end;

procedure TPedidosItens.SetIdPedGeral(const Value: Integer);
begin
  FIdPedGeral := Value;
end;

procedure TPedidosItens.SetIdPedItem(const Value: Integer);
begin
  FIdPedItem := Value;
end;

procedure TPedidosItens.SetIdProduto(const Value: Integer);
begin
  FIdProduto := Value;
end;

procedure TPedidosItens.SetQuantidade(const Value: Integer);
begin
  FQuantidade := Value;
end;

procedure TPedidosItens.SetVlrTotal(const Value: Double);
begin
  FVlrTotal := Value;
end;

procedure TPedidosItens.SetVlrUnitario(const Value: Double);
begin
  FVlrUnitario := Value;
end;

class function TPedidosItens.New: IPedidosItens;
begin
  Result := TPedidosItens.Create;
end;

class function TPedidosItens.New(aIdPedGeral, aIdProduto, aQuantidade: Integer; aVlrUnitario, aVlrTotal: Double): IPedidosItens;
begin
  Result := TPedidosItens.New;

  Result.SetIdPedGeral(aIdPedGeral);
  Result.SetIdProduto(aIdProduto);
  Result.SetQuantidade(aQuantidade);
  Result.SetVlrUnitario(aVlrUnitario);
  Result.SetVlrTotal(aVlrTotal);
end;

end.
