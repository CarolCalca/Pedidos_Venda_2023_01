unit untPedidosItensController;

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
  VCL.Dialogs,

  untPedidosItens,
  untPedidosItensInterface,
  untPedidosItensControllerInterface;

type
  TPedidoItemController = class(TInterfacedObject, IPedidosItensController)
  private

  public
    function Inserir(oPedidoItem: IPedidosItens): Boolean;
    function Alterar(oPedidoItem: IPedidosItens): Boolean;
    function Excluir(aIdPedItem: Integer): Boolean;
    function ExcluirPed(aIdPedGeral: Integer): Boolean;
    function Carregar(aIdPedItem: Integer): IPedidosItens;

    class function New():TPedidoItemController; static;
  end;

implementation

uses untConnection;

{ TPedidoItemController }

function TPedidoItemController.Alterar(oPedidoItem: IPedidosItens): Boolean;
var
  qAux: TFDQuery;
begin
  Result := False;

  qAux := TConnection.NewQuery('UPDATE peditem '+
                               '   SET quantidade = :quantidade, vlrunitario = :vlrunitario, vlrtotal = :vlrtotal '+
                               ' WHERE idpeditem = :idpeditem');

  try
    try
      qAux.ParamByName('idpeditem').AsInteger := oPedidoItem.GetIdPedItem;
      qAux.ParamByName('quantidade').AsInteger := oPedidoItem.GetQuantidade;
      qAux.ParamByName('vlrunitario').AsFloat := oPedidoItem.GetVlrUnitario;
      qAux.ParamByName('vlrtotal').AsFloat := oPedidoItem.GetVlrTotal;
      qAux.ExecSQL;

      Result := True;

    except on E:Exception do
      MessageDlg('Erro ao alterar o produto do pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;

  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoItemController.Carregar(aIdPedItem: Integer): IPedidosItens;
var
  qAux: TFDQuery;
begin
  Result := TPedidosItens.New;

  qAux := TConnection.NewQuery('SELECT * FROM peditem WHERE idpeditem = :idpeditem');

  try
    try
      qAux.ParamByName('idpeditem').AsInteger := aIdPedItem;
      qAux.Open;

      if not qAux.IsEmpty then
      begin
        if Assigned(qAux.FindField('idpeditem')) then
          Result.SetIdPedItem(qAux.FieldByName('idpeditem').AsInteger);
        if Assigned(qAux.FindField('idpedgeral')) then
          Result.SetIdPedGeral(qAux.FieldByName('idpedgeral').AsInteger);
        if Assigned(qAux.FindField('idproduto')) then
          Result.SetIdProduto(qAux.FieldByName('idproduto').AsInteger);
        if Assigned(qAux.FindField('quantidade')) then
          Result.SetQuantidade(qAux.FieldByName('quantidade').AsInteger);
        if Assigned(qAux.FindField('vlrunitario')) then
          Result.SetVlrUnitario(qAux.FieldByName('vlrunitario').AsFloat);
        if Assigned(qAux.FindField('vlrtotal')) then
          Result.SetVlrTotal(qAux.FieldByName('vlrtotal').AsFloat);
      end;

    except on E:Exception do
      MessageDlg('Erro ao carregar o produto do pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;

  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoItemController.Excluir(aIdPedItem: Integer): Boolean;
var
  qAux: TFDQuery;
begin
  Result := False;

  qAux := TConnection.NewQuery('DELETE FROM peditem WHERE idpeditem = :idpeditem');

  try
    try
      qAux.ParamByName('idpeditem').AsInteger := aIdPedItem;
      qAux.ExecSQL;

      Result := True;

    except on E:Exception do
      MessageDlg('Erro ao excluir o produto do pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;

  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoItemController.ExcluirPed(aIdPedGeral: Integer): Boolean;
var
  qAux: TFDQuery;
begin
  Result := False;

  qAux := TConnection.NewQuery('DELETE FROM peditem WHERE idpedgeral = :idpedgeral');

  try
    try
      qAux.ParamByName('idpedgeral').AsInteger := aIdPedGeral;
      qAux.ExecSQL;

      Result := True;

    except on E:Exception do
      MessageDlg('Erro ao excluir os produtos do pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;

  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoItemController.Inserir(oPedidoItem: IPedidosItens): Boolean;
var
  qAux: TFDQuery;
begin
  Result := False;

  qAux := TConnection.NewQuery('INSERT INTO peditem (idpedgeral, idproduto, quantidade, vlrunitario, vlrtotal) '+
                               'VALUES (:idpedgeral, :idproduto, :quantidade, :vlrunitario , :vlrtotal) ');

  try
    try
      qAux.ParamByName('idpedgeral').AsInteger := oPedidoItem.GetIdPedGeral;
      qAux.ParamByName('idproduto').AsInteger := oPedidoItem.GetIdProduto;
      qAux.ParamByName('quantidade').AsInteger := oPedidoItem.GetQuantidade;
      qAux.ParamByName('vlrunitario').AsFloat := oPedidoItem.GetVlrUnitario;
      qAux.ParamByName('vlrtotal').AsFloat := oPedidoItem.GetVlrTotal;
      qAux.ExecSQL;

      Result := True;

    except on E:Exception do
      MessageDlg('Erro ao incluir o produto do pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;

  finally
    FreeAndNil(qAux);
  end;
end;

class function TPedidoItemController.New: TPedidoItemController;
begin
  Result := TPedidoItemController.Create;
end;

end.
