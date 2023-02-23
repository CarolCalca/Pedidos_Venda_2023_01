unit untProdutosControllerInterface;

interface

uses
  untProdutosInterface;

type
  IProdutosController = interface
    ['{9C81C9C6-CE49-4E4B-9EF7-0A579CFAB32B}']

    function Inserir(oProduto: IProdutos): Boolean;
    function Carregar(aIdProduto: Integer): IProdutos;
    function RetornaValorProduto(aIdProduto: Integer): Double;
  end;

implementation

end.
