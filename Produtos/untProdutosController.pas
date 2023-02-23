unit untProdutosController;

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
  FireDAC.Stan.Param,

  System.SysUtils,
  System.UITypes,
  Vcl.Dialogs,

  untProdutos,
  untProdutosInterface,
  untProdutosControllerInterface;

type
  TProdutoController = class(TInterfacedObject, IProdutosController)
  private

  public
    function Inserir(oProduto: IProdutos): Boolean;
    function Carregar(aIdProduto: Integer): IProdutos;
    function RetornaValorProduto(aIdProduto: Integer): Double;

    class function New():IProdutosController; static;
  end;

implementation

uses untConnection;

{ TProdutoController }

function TProdutoController.Carregar(aIdProduto: Integer): IProdutos;
var
  qAux: TFDQuery;
begin
  Result := TProdutos.New();

  qAux := TConnection.NewQuery('SELECT * FROM produto WHERE idproduto = :idproduto');

  try
    try
      qAux.ParamByName('idproduto').AsInteger := aIdProduto;
      qAux.Open;

      if not qAux.IsEmpty then
      begin
        if Assigned(qAux.FindField('idproduto')) then
          Result.SetIdProduto(qAux.FieldByName('idproduto').AsInteger);
        if Assigned(qAux.FindField('descricao')) then
          Result.SetDescricao(qAux.FieldByName('descricao').AsString);
        if Assigned(qAux.FindField('precovenda')) then
          Result.SetPrecoVenda(qAux.FieldByName('precovenda').AsFloat);
      end;

    except on E:Exception do
      MessageDlg('Erro ao carregar o Produto!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;
  finally
    FreeAndNil(qAux);
  end;
end;

function TProdutoController.Inserir(oProduto: IProdutos): Boolean;
var
  qAux: TFDQuery;
begin

  qAux := TConnection.NewQuery('INSERT INTO produto (descricao, precovenda) VALUES (:descricao, :precovenda)');

  try
    try
      qAux.ParamByName('descricao').AsString := oProduto.GetDescricao();
      qAux.ParamByName('precovenda').AsFloat := oProduto.GetPrecoVenda();
      qAux.ExecSQL;

      Result := True;
    except on E:Exception do
      begin
        Result := False;
        MessageDlg('Erro ao inserir o Produto!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
      end;
    end;
  finally
    FreeAndNil(qAux);
  end;
end;


class function TProdutoController.New: IProdutosController;
begin
  Result := TProdutoController.Create;
end;

function TProdutoController.RetornaValorProduto(aIdProduto: Integer): Double;
begin
  Result := 0;

  if (aIdProduto > 0) then
    Result := Self.Carregar(aIdProduto).GetPrecoVenda();
end;

end.
