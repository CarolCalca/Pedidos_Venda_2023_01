unit untProdutosInterface;

interface

type
  IProdutos = interface
    ['{085840F5-6380-47F7-8407-374C7089850C}']

    procedure Clear();

    procedure SetIdProduto(const Value: Integer);
    procedure SetDescricao(const Value: String);
    procedure SetPrecoVenda(const Value: Double);

    function GetIdProduto:Integer;
    function GetDescricao:String;
    function GetPrecoVenda:Double;
  end;

implementation

end.
