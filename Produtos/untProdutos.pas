unit untProdutos;

interface

uses
  System.SysUtils,

  untProdutosInterface;

type
  TProdutos = class(TInterfacedObject, IProdutos)
  private
    var
      FIdProduto: Integer;
      FDescricao: String;
      FPrecoVenda: Double;
  public
    constructor Create();

    procedure Clear();

    procedure SetIdProduto(const Value: Integer);
    procedure SetDescricao(const Value: String);
    procedure SetPrecoVenda(const Value: Double);

    function GetIdProduto:Integer;
    function GetDescricao:String;
    function GetPrecoVenda:Double;

    class function New():IProdutos; overload; static;
    class function New(aDescricao: String; aPrecoVenda: Double):IProdutos; overload; static;
  end;

implementation

{ TProdutos }

procedure TProdutos.Clear;
begin
  FIdProduto  := 0;
  FDescricao  := EmptyStr;
  FPrecoVenda := 0;
end;

constructor TProdutos.Create;
begin
  Self.Clear;
end;

function TProdutos.GetDescricao: String;
begin
  Result := fDescricao;
end;

function TProdutos.GetIdProduto: Integer;
begin
  Result := fIdProduto;
end;

function TProdutos.GetPrecoVenda: Double;
begin
  Result := fPrecoVenda;
end;

procedure TProdutos.SetDescricao(const Value: String);
begin
  FDescricao := Value;
end;

procedure TProdutos.SetIdProduto(const Value: Integer);
begin
  FIdProduto := Value;
end;

procedure TProdutos.SetPrecoVenda(const Value: Double);
begin
  FPrecoVenda := Value;
end;

class function TProdutos.New: IProdutos;
begin
  Result := TProdutos.Create;
end;

class function TProdutos.New(aDescricao: String; aPrecoVenda: Double): IProdutos;
begin
  Result := TProdutos.New;

  Result.SetDescricao(aDescricao);
  Result.SetPrecoVenda(aPrecoVenda);
end;

end.
