unit untClientesController;

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
  FireDAC.DApt,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param,

  System.UITypes,
  Vcl.Dialogs,

  untClientes,
  untClientesInterface,
  untClientesControllerInterface;

type
  TClienteController = class(TInterfacedObject, IClientesController)
  private

  public
    function Inserir(oCliente: IClientes): Boolean;
    function Carregar(aIdCliente: Integer): IClientes;

    class function New():TClienteController; static;
  end;

implementation

uses untConnection;

{ TClienteController }

function TClienteController.Carregar(aIdCliente: Integer): IClientes;
var
  qAux: TFDQuery;
begin
  Result := TClientes.New();

  qAux := TConnection.NewQuery('SELECT * FROM cliente WHERE idcliente = :idcliente');
  
  try
    try
      qAux.ParamByName('idcliente').AsInteger := aIdCliente;
      qAux.Open;

      if not qAux.IsEmpty then
      begin
        if Assigned(qAux.FindField('idcliente')) then
          Result.SetIdCliente(qAux.FieldByName('idcliente').AsInteger);
        if Assigned(qAux.FindField('nome')) then
          Result.SetNome(qAux.FieldByName('nome').AsString);
        if Assigned(qAux.FindField('cidade')) then
          Result.SetCidade(qAux.FieldByName('cidade').AsString);
        if Assigned(qAux.FindField('uf')) then
          Result.SetUF(qAux.FieldByName('uf').AsString);
      end;

    except on E:Exception do
      MessageDlg('Erro ao carregar o Cliente!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
    end;
  finally
    FreeAndNil(qAux);
  end;
end;

function TClienteController.Inserir(oCliente: IClientes): Boolean;
var
  qAux: TFDQuery;
begin

  qAux := TConnection.NewQuery('INSERT INTO cliente (nome, cidade, uf) VALUES (:nome, :cidade, :uf)');

  try
    try
      qAux.ParamByName('nome').AsString := oCliente.GetNome();
      qAux.ParamByName('cidade').AsString := oCliente.GetCidade();
      qAux.ParamByName('uf').AsString := oCliente.GetUF();
      qAux.ExecSQL;

      Result := True;
    except on E:Exception do
      begin
        Result := False;
        MessageDlg('Erro ao inserir o Cliente!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
      end;
    end;
  finally
    FreeAndNil(qAux);
  end;
end;


class function TClienteController.New: TClienteController;
begin
  Result := TClienteController.Create;
end;

end.
