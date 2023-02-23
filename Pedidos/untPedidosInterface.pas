unit untPedidosInterface;

interface

uses
  untPedidosItens;

type
  IPedidos = interface
    ['{7ECBA52E-6BDF-4CB3-A543-FC9909196C4D}']

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
  end;

implementation

end.
