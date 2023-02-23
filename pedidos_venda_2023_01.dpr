program pedidos_venda_2023_01;

uses
  Vcl.Forms,
  untMain in 'untMain.pas' {fMain},
  untConnection in 'untConnection.pas',
  untClientesController in 'Clientes\untClientesController.pas',
  untClientesInterface in 'Clientes\untClientesInterface.pas',
  untClientes in 'Clientes\untClientes.pas',
  untClientesControllerInterface in 'Clientes\untClientesControllerInterface.pas',
  untPedidos in 'Pedidos\untPedidos.pas',
  untPedidosController in 'Pedidos\untPedidosController.pas',
  untPedidosControllerInterface in 'Pedidos\untPedidosControllerInterface.pas',
  untPedidosInterface in 'Pedidos\untPedidosInterface.pas',
  untPedidosItens in 'PedidosItens\untPedidosItens.pas',
  untPedidosItensController in 'PedidosItens\untPedidosItensController.pas',
  untPedidosItensControllerInterface in 'PedidosItens\untPedidosItensControllerInterface.pas',
  untPedidosItensInterface in 'PedidosItens\untPedidosItensInterface.pas',
  untProdutos in 'Produtos\untProdutos.pas',
  untProdutosController in 'Produtos\untProdutosController.pas',
  untProdutosControllerInterface in 'Produtos\untProdutosControllerInterface.pas',
  untProdutosInterface in 'Produtos\untProdutosInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
