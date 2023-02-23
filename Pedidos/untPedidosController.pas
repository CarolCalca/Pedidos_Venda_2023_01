unit untPedidosController;

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
  System.SysUtils,
  System.UITypes,
  FireDAC.DApt,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param,

  Vcl.Dialogs,

  untPedidos,
  untPedidosInterface,
  untPedidosControllerInterface,
  untPedidosItens,
  untPedidosItensInterface,
  untPedidosItensController,
  untPedidosItensControllerInterface;

type
  TPedidoController = class(TInterfacedObject, IPedidosController)
  private
    class function getId(): Integer;
  public
    function Inserir(oPedido: IPedidos): Boolean;
    function Alterar(oPedido: IPedidos): Boolean;
    function Excluir(aIdPedGeral: Integer): Boolean;
    function Carregar(aIdPedGeral: Integer): IPedidos;

    class function New():TPedidoController; static;
  end;

implementation

uses untConnection;

{ TPedidoController }

class function TPedidoController.getId: Integer;
var
  qAux: TFDQuery;
begin
  Result := 0;

  qAux := TConnection.NewQuery('SELECT MAX(idpedgeral) AS ID_ATUAL FROM pedgeral');

  try
    try
      qAux.Open;

      if not (qAux.IsEmpty) then
        Result := qAux.FieldByName('ID_ATUAL').AsInteger + 1
      else
        Result := 1;

    except on E:Exception do
      MessageDlg('Erro ao pesquisar a chave do pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;
  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoController.Alterar(oPedido: IPedidos): Boolean;
var
  qAux: TFDQuery;
  I: Integer;
begin
  qAux := TConnection.NewQuery('UPDATE pedgeral SET vlrtotal = :vlrtotal '+
                               ' WHERE idpedgeral = :idpedgeral');

  try
    try
      qAux.ParamByName('idpedgeral').AsInteger := oPedido.GetIdpedgeral;
      qAux.ParamByName('vlrtotal').AsFloat := oPedido.GetVlrTotal;
      qAux.ExecSQL;

      for I := 0 to pred(oPedido.GetPedidoItem.Count) do
      begin
        oPedido.GetPedidoItem[I].SetIdPedGeral(oPedido.GetIdpedgeral);

        if (oPedido.GetPedidoItem[I].GetIdPedItem > 0) then
          TPedidoItemController.New.Alterar(oPedido.GetPedidoItem[I])
        else
          TPedidoItemController.New.Inserir(oPedido.GetPedidoItem[I]);
      end;

      Result := True;
    except on E:Exception do
      begin
        Result := False;
        MessageDlg('Erro ao alterar o Pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
      end;
    end;
  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoController.Carregar(aIdPedGeral: Integer): IPedidos;
var
  qAux: TFDQuery;
  oPedidoItem: IPedidosItens;
begin
  Result := TPedidos.New;

  qAux := TConnection.NewQuery('SELECT * FROM pedgeral WHERE idpedgeral = :idpedgeral');

  try
    try
      qAux.ParamByName('idpedgeral').AsInteger := aIdPedGeral;
      qAux.Open;

      if not qAux.IsEmpty then
      begin
        if Assigned(qAux.FindField('idpedgeral')) then
          Result.SetIdPedGeral(qAux.FieldByName('idpedgeral').AsInteger);
        if Assigned(qAux.FindField('data')) then
          Result.SetData(qAux.FieldByName('data').AsDateTime);
        if Assigned(qAux.FindField('idcliente')) then
          Result.SetIdCliente(qAux.FieldByName('idcliente').AsInteger);
        if Assigned(qAux.FindField('vlrtotal')) then
          Result.SetVlrTotal(qAux.FieldByName('vlrtotal').AsFloat);

        qAux.Close;
        qAux.SQL.Clear;
        qAux.SQL.Add('SELECT * FROM peditem WHERE idpedgeral = :idpedgeral');
        qAux.ParamByName('idpedgeral').AsInteger := aIdPedGeral;
        qAux.Open;

        qAux.First;
        while not qAux.Eof do
        begin
          oPedidoItem := TPedidosItens.New;

          oPedidoItem.SetIdPedItem(qAux.FieldByName('IdPedItem').AsInteger);
          oPedidoItem.SetIdPedGeral(qAux.FieldByName('IdPedGeral').AsInteger);
          oPedidoItem.SetIdProduto(qAux.FieldByName('IdProduto').AsInteger);
          oPedidoItem.SetQuantidade(qAux.FieldByName('Quantidade').AsInteger);
          oPedidoItem.SetVlrUnitario(qAux.FieldByName('VlrUnitario').AsFloat);
          oPedidoItem.SetVlrTotal(qAux.FieldByName('VlrTotal').AsFloat);

          Result.GetPedidoItem.Add(oPedidoItem);

          qAux.Next;
        end;
      end;
      except on E:Exception do
        MessageDlg('Erro ao carregar o Pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;
  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoController.Excluir(aIdPedGeral: Integer): Boolean;
var
  qAux: TFDQuery;
begin
  Result := False;

  qAux := TConnection.NewQuery('DELETE FROM pedgeral WHERE idpedgeral = :idpedgeral');

  try
    try
      TPedidoItemController.New.ExcluirPed(aIdPedGeral);

      qAux.ParamByName('idpedgeral').AsInteger := aIdPedGeral;
      qAux.ExecSQL;

      Result := True;
    except on E:Exception do
      MessageDlg('Erro ao excluir o Pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;
  finally
    FreeAndNil(qAux);
  end;
end;

function TPedidoController.Inserir(oPedido: IPedidos): Boolean;
var
  qAux: TFDQuery;
  vId, I: Integer;
begin
  Result := False;

  vId := Self.getId();

  if (vId > 0) then
  begin

    qAux := TConnection.NewQuery('INSERT INTO pedgeral (idpedgeral, data, idcliente, vlrtotal) '+
                                 'VALUES (:idpedgeral, :data, :idcliente, :vlrtotal)');

    try
      try
        qAux.ParamByName('idpedgeral').AsInteger := vId;
        qAux.ParamByName('data').AsDateTime := oPedido.GetData;
        qAux.ParamByName('idcliente').AsInteger := oPedido.GetIdCliente;
        qAux.ParamByName('vlrtotal').AsFloat := oPedido.GetVlrTotal;
        qAux.ExecSQL;

        for I := 0 to pred(oPedido.GetPedidoItem.Count) do
        begin
          oPedido.GetPedidoItem[I].SetIdPedGeral(vId);

          if (oPedido.GetPedidoItem[I].GetIdPedItem > 0) then
            TPedidoItemController.New.Alterar(oPedido.GetPedidoItem[I])
          else
            TPedidoItemController.New.Inserir(oPedido.GetPedidoItem[I]);
        end;

        Result := True;
      except on E:Exception do
        MessageDlg('Erro ao incluir o Pedido!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
      end;
    finally
      FreeAndNil(qAux);
    end;
  end;
end;

class function TPedidoController.New: TPedidoController;
begin
  Result := TPedidoController.Create;
end;

end.
