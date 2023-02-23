unit untPedidosControllerInterface;

interface

uses
  untPedidosInterface;

type
  IPedidosController = interface
    ['{973233C7-BA44-4299-8779-D2BE1D2964B6}']

    function Inserir(oPedido: IPedidos): Boolean;
    function Alterar(oPedido: IPedidos): Boolean;
    function Excluir(aIdPedGeral: Integer): Boolean;
    function Carregar(aIdPedGeral: Integer): IPedidos;
  end;

implementation

end.
