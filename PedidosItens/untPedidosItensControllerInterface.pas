unit untPedidosItensControllerInterface;

interface

uses
  untPedidosItensInterface;

type
  IPedidosItensController = interface
    ['{EB170924-7B9A-487E-9870-EC421156E1A0}']

    function Inserir(oPedidoItem: IPedidosItens): Boolean;
    function Alterar(oPedidoItem: IPedidosItens): Boolean;
    function Excluir(aIdPedItem: Integer): Boolean;
    function ExcluirPed(aIdPedGeral: Integer): Boolean;
    function Carregar(aIdPedItem: Integer): IPedidosItens;
  end;

implementation

end.
