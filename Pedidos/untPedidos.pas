unit untPedidos;

interface

uses
  System.SysUtils,

  untPedidosInterface,
  untPedidosItens;

type
  TPedidos = class(TInterfacedObject, IPedidos)
  private
    var
      FIdPedGeral : Integer;
      FData       : TDateTime;
      FIdCliente  : Integer;
      FVlrTotal   : Double;
      oPedidoItem : TPedidosItensList;
  public
    constructor Create();

    destructor Destroy(); override;

    procedure Clear();

    procedure SetIdPedGeral(const Value: Integer);
    procedure SetData(const Value: TDateTime);
    procedure SetIdCliente(const Value: Integer);
    procedure SetVlrTotal(const Value: Double);
    procedure SetPedidoItem(const Value: TPedidosItensList);

    function GetIdPedGeral:Integer;
    function GetData:TDateTime;
    function GetIdCliente:Integer;
    function GetVlrTotal:Double;
    function GetPedidoItem:TPedidosItensList;

    class function New():IPedidos; overload; static;
    class function New(aData: TDateTime; aIdCliente: Integer; aVlrTotal: Double; aPedidoItem: TPedidosItensList):IPedidos; overload; static;
  end;

implementation

{ TPedidos }

procedure TPedidos.Clear;
begin
  FIdPedGeral := 0;
  FData       := 0;
  FIdCliente  := 0;
  FVlrTotal   := 0;

  oPedidoItem.Clear;
end;

constructor TPedidos.Create;
begin
  oPedidoItem := TPedidosItensList.Create();

  Self.Clear;
end;

destructor TPedidos.Destroy;
begin

  FreeAndNil(oPedidoItem);

  inherited;
end;

function TPedidos.GetData: TDateTime;
begin
  Result := fData;
end;

function TPedidos.GetIdCliente: Integer;
begin
  Result := fIdCliente;
end;

function TPedidos.GetIdPedGeral: Integer;
begin
  Result := fIdPedGeral;
end;

function TPedidos.GetPedidoItem: TPedidosItensList;
begin
  Result := oPedidoItem;
end;

function TPedidos.GetVlrTotal: Double;
begin
  Result := fVlrTotal;
end;

procedure TPedidos.SetData(const Value: TDateTime);
begin
  FData := Value;
end;

procedure TPedidos.SetIdCliente(const Value: Integer);
begin
  FIdCliente := Value;
end;

procedure TPedidos.SetIdPedGeral(const Value: Integer);
begin
  FIdPedGeral := Value;
end;

procedure TPedidos.SetPedidoItem(const Value: TPedidosItensList);
begin
  oPedidoItem := Value;
end;

procedure TPedidos.SetVlrTotal(const Value: Double);
begin
  FVlrTotal := Value;
end;

class function TPedidos.New: IPedidos;
begin
  Result := TPedidos.Create;
end;

class function TPedidos.New(aData: TDateTime; aIdCliente: Integer; aVlrTotal: Double; aPedidoItem: TPedidosItensList): IPedidos;
begin
  Result := TPedidos.New;

  Result.SetData(aData);
  Result.SetIdCliente(aIdCliente);
  Result.SetVlrTotal(aVlrTotal);
  Result.SetPedidoItem(aPedidoItem);
end;

end.
