unit untPedidosItensInterface;

interface

type
  IPedidosItens = interface
    ['{160ABD96-3A1C-4CF6-9D6E-65C6DF4F7D97}']

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
  end;

implementation

end.
