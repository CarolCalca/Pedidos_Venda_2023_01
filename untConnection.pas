unit untConnection;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.MySQL,
  FireDAC.DApt,
  FireDAC.Stan.Param,

  Vcl.Dialogs,
  Vcl.Forms,
  System.UITypes,

  untClientesController,
  untClientes,
  untClientesInterface,
  untProdutosController,
  untProdutos;

type
  TConnection = class
    private
      class var oConnection : TFDConnection;
      class var oDriverLink : TFDPhysMySQLDriverLink;
      class procedure Config(pCriar: Boolean);
      class procedure Connect(pCriar: Boolean);
      class procedure InsereCliente();
      class procedure InsereProduto();
      class procedure TransacaoAutomatica(aAtivar: Boolean);
    public
      class function getConnection(pCriar: Boolean = False):TFDConnection;
      class function createDB():Boolean;
      class function NewQuery(aSQL:String):TFDQuery;
      class procedure StartTransaction(); static;
      class procedure Rollback(); static;
      class procedure Commit(); static;
  end;

const
  cstDB_Driver: String = 'MySQL';
  cstDB_User: String = 'root';
  cstDB_Pass: String = 'root';
  cstDB_Name: String = 'dbPedidos';
  cstDB_Server: String = '127.0.0.1';
  cstDB_Port: String = '3306';


implementation

{ TConnection }

class function TConnection.getConnection(pCriar: Boolean = False): TFDConnection;
begin
  Result := nil;

  try
    TConnection.Connect(pCriar);
    Result := oConnection;
  except
    on E:Exception do
    begin
      ShowMessage('Não foi possível conectar ao banco de dados.' + #13 + E.Message);
      Application.Terminate;
    end;
  end;
end;

class function TConnection.NewQuery(aSQL: String): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := TConnection.getConnection();
  Result.SQL.Add(aSQL);
end;

class procedure TConnection.Rollback;
begin
  if TConnection.GetConnection().InTransaction then
    TConnection.GetConnection().Rollback;

  TransacaoAutomatica(True);
end;

class procedure TConnection.StartTransaction;
begin
  TransacaoAutomatica(False);

  TConnection.getConnection().StartTransaction;
end;

class procedure TConnection.TransacaoAutomatica(aAtivar: Boolean);
begin
  TConnection.getConnection().TxOptions.AutoCommit := aAtivar;
  TConnection.getConnection().TxOptions.AutoStart := aAtivar;
  TConnection.getConnection().TxOptions.AutoStop := aAtivar;
end;

class procedure TConnection.Connect(pCriar: Boolean);
begin
  TConnection.Config(pCriar);
  if not oConnection.Connected then
    oConnection.Connected := True;
end;

class procedure TConnection.Commit;
begin
  if TConnection.GetConnection().InTransaction then
    TConnection.GetConnection().Commit;

  TransacaoAutomatica(True);
end;

class procedure TConnection.Config(pCriar: Boolean);
begin
  if not Assigned(oConnection) then
  begin
    if not Assigned(oDriverLink) then
    begin
      oDriverLink := TFDPhysMySQLDriverLink.Create(nil);
      oDriverLink.VendorLib := GetCurrentDir + '\libmysql.dll';
    end;

    oConnection := TFDConnection.Create(nil);
    oConnection.Params.Add('driverID='+cstDB_Driver);
    oConnection.Params.Add('server='+cstDB_Server);
    oConnection.Params.Add('port='+cstDB_Port);

    if not (pCriar) then
      oConnection.Params.Add('database='+cstDB_Name);

    oConnection.Params.Add('user_name='+cstDB_User);
    oConnection.Params.Add('password='+cstDB_Pass);
  end;
end;

class function TConnection.createDB: Boolean;
var
  qryDB: TFDQuery;
begin
  Result := False;

  qryDB := TFDQuery.Create(nil);

  try
    try
      qryDB.Connection := getConnection(True);

      qryDB.Close;
      qryDB.SQL.Clear;
      qryDB.SQL.Add('SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = :SCHEMA_NAME');
      qryDB.ParamByName('SCHEMA_NAME').AsString := cstDB_Name;
      qryDB.Open;

      if not qryDB.IsEmpty then
      begin
        FreeAndNil(oConnection);
        qryDB.Connection := getConnection();
      end
      else
      begin
        qryDB.Close;
        qryDB.SQL.Clear;
        qryDB.SQL.Add('CREATE SCHEMA IF NOT EXISTS `'+cstDB_Name+'`');
        qryDB.ExecSQL;

        FreeAndNil(oConnection);
        qryDB.Connection := getConnection();

        // Clientes
        qryDB.Close;
        qryDB.SQL.Clear;
        qryDB.SQL.Add('CREATE TABLE IF NOT EXISTS `'+cstDB_Name+'`.`cliente` ( ');
        qryDB.SQL.Add('  `idcliente` INT NOT NULL AUTO_INCREMENT,   ');
        qryDB.SQL.Add('  `nome` VARCHAR(150) NOT NULL,              ');
        qryDB.SQL.Add('  `cidade` VARCHAR(150) NULL,                ');
        qryDB.SQL.Add('  `uf` VARCHAR(2) NULL,                      ');
        qryDB.SQL.Add('  PRIMARY KEY (`idcliente`),                 ');
        qryDB.SQL.Add('  INDEX `idx_cidade` (`cidade` ASC) VISIBLE, ');
        qryDB.SQL.Add('  INDEX `idx_uf` (`uf` ASC) VISIBLE)         ');
        qryDB.ExecSQL;

        InsereCliente;

        // Produtos
        qryDB.Close;
        qryDB.SQL.Clear;
        qryDB.SQL.Add('CREATE TABLE IF NOT EXISTS `'+cstDB_Name+'`.`produto` ( ');
        qryDB.SQL.Add('  `idproduto` INT NOT NULL AUTO_INCREMENT,         ');
        qryDB.SQL.Add('  `descricao` VARCHAR(150) NOT NULL,               ');
        qryDB.SQL.Add('  `precovenda` DECIMAL(10,2) NOT NULL,             ');
        qryDB.SQL.Add('  PRIMARY KEY (`idproduto`),                       ');
        qryDB.SQL.Add('  INDEX `idx_descricao` (`descricao` ASC) VISIBLE) ');
        qryDB.ExecSQL;

        InsereProduto;

        // Pedidos Geral
        qryDB.Close;
        qryDB.SQL.Clear;
        qryDB.SQL.Add('CREATE TABLE IF NOT EXISTS `'+cstDB_Name+'`.`pedgeral`( ');
        qryDB.SQL.Add('  `idpedgeral` INT NOT NULL,                            ');
        qryDB.SQL.Add('  `data` DATETIME NOT NULL,                             ');
        qryDB.SQL.Add('  `idcliente` INT NOT NULL,                             ');
        qryDB.SQL.Add('  `vlrtotal` DECIMAL(10,2) NOT NULL,                    ');
        qryDB.SQL.Add('  PRIMARY KEY (`idpedgeral`),                           ');
        qryDB.SQL.Add('  INDEX `idx_data` (`data` ASC) INVISIBLE,              ');
        qryDB.SQL.Add('  INDEX `idx_idcliente` (`idcliente` ASC) VISIBLE,      ');
        qryDB.SQL.Add('  CONSTRAINT `fk_idcliente`                             ');
        qryDB.SQL.Add('  FOREIGN KEY (`idcliente`)                             ');
        qryDB.SQL.Add('  REFERENCES `'+cstDB_Name+'`.`cliente` (`idcliente`)   ');
        qryDB.SQL.Add('  ON DELETE NO ACTION                                   ');
        qryDB.SQL.Add('  ON UPDATE NO ACTION)                                  ');
        qryDB.ExecSQL;

        // Pedidos Itens
        qryDB.Close;
        qryDB.SQL.Clear;
        qryDB.SQL.Add('CREATE TABLE IF NOT EXISTS `'+cstDB_Name+'`.`peditem` ( ');
        qryDB.SQL.Add('  `idpeditem` INT NOT NULL AUTO_INCREMENT,              ');
        qryDB.SQL.Add('  `idpedgeral` INT NOT NULL,                            ');
        qryDB.SQL.Add('  `idproduto` INT NOT NULL,                             ');
        qryDB.SQL.Add('  `quantidade` INT NOT NULL,                            ');
        qryDB.SQL.Add('  `vlrunitario` DECIMAL(10,2) NOT NULL,                 ');
        qryDB.SQL.Add('  `vlrtotal` DECIMAL(10,2) NOT NULL,                    ');
        qryDB.SQL.Add('  PRIMARY KEY (`idpeditem`),                            ');
        qryDB.SQL.Add('  INDEX `idx_idpedgeral` (`idpedgeral` ASC) INVISIBLE,  ');
        qryDB.SQL.Add('  INDEX `idx_idproduto` (`idproduto` ASC) VISIBLE,      ');
        qryDB.SQL.Add('  CONSTRAINT `fk_idproduto`                             ');
        qryDB.SQL.Add('  FOREIGN KEY (`idproduto`)                             ');
        qryDB.SQL.Add('  REFERENCES `'+cstDB_Name+'`.`produto` (`idproduto`)   ');
        qryDB.SQL.Add('  ON DELETE NO ACTION                                   ');
        qryDB.SQL.Add('  ON UPDATE NO ACTION,                                  ');
        qryDB.SQL.Add('  CONSTRAINT `fk_idpedgeral`                             ');
        qryDB.SQL.Add('  FOREIGN KEY (`idpedgeral`)                             ');
        qryDB.SQL.Add('  REFERENCES `'+cstDB_Name+'`.`pedgeral` (`idpedgeral`)   ');
        qryDB.SQL.Add('  ON DELETE NO ACTION                                   ');
        qryDB.SQL.Add('  ON UPDATE NO ACTION)                                  ');
        qryDB.ExecSQL;
      end;

      Result := True;

    except on E:Exception do
      begin
        MessageDlg('Erro ao criar o banco de dados!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
      end;
    end;
  finally
    FreeAndNil(qryDB);
  end;
end;

class procedure TConnection.InsereCliente;
begin

  with TClienteController.New() do
  begin
    Inserir(TClientes.New('Miguel',   'Sao Paulo',      'SP'));
    Inserir(TClientes.New('Helena',   'Rio de Janeiro', 'RJ'));
    Inserir(TClientes.New('Arthur',   'Belo Horizonte', 'MG'));
    Inserir(TClientes.New('Alice',    'Brasilia',       'DF'));
    Inserir(TClientes.New('Benicio',  'Salvador',       'BA'));
    Inserir(TClientes.New('Laura',    'Fortaleza',      'CE'));
    Inserir(TClientes.New('Theo',     'Sao Paulo',      'SP'));
    Inserir(TClientes.New('Manuela',  'Sao Paulo',      'SP'));
    Inserir(TClientes.New('Heitor',   'Sao Paulo',      'SP'));
    Inserir(TClientes.New('Sophia',   'Manaus',         'AM'));
    Inserir(TClientes.New('Davi',     'Rio de Janeiro', 'RJ'));
    Inserir(TClientes.New('Isabella', 'Rio de Janeiro', 'RJ'));
    Inserir(TClientes.New('Bernardo', 'Sao Paulo',      'SP'));
    Inserir(TClientes.New('Luisa',    'Curitiba',       'PR'));
    Inserir(TClientes.New('Noah',     'Recife',         'PE'));
    Inserir(TClientes.New('Cecilia',  'Goiania',        'GO'));
    Inserir(TClientes.New('Gabriel',  'Sao Paulo',      'SP'));
    Inserir(TClientes.New('Maite',    'Belem',          'PA'));
    Inserir(TClientes.New('Samuel',   'Porto Alegre',   'RS'));
    Inserir(TClientes.New('Eloa',     'Guarulhos',      'SP'));
  end;
end;

class procedure TConnection.InsereProduto;
begin

  with TProdutoController.New() do
  begin
    Inserir(TProdutos.New('Arroz', 24.99));
    Inserir(TProdutos.New('Feijao', 9.9));
    Inserir(TProdutos.New('Cafe', 11.9));
    Inserir(TProdutos.New('Macarrao', 3.55));
    Inserir(TProdutos.New('Farinha de trigo', 6.5));
    Inserir(TProdutos.New('Ovo', 0.90));
    Inserir(TProdutos.New('Salgadinho', 9.9));
    Inserir(TProdutos.New('Refrigerante 2l', 7.3));
    Inserir(TProdutos.New('Chocolate', 5.4));
    Inserir(TProdutos.New('Miojo', 1.99));
    Inserir(TProdutos.New('Leite', 4.5));
    Inserir(TProdutos.New('Achocolatado', 7.8));
    Inserir(TProdutos.New('Leite em po', 10.2));
    Inserir(TProdutos.New('Vassoura', 10.7));
    Inserir(TProdutos.New('Limpador multiuso', 12.6));
    Inserir(TProdutos.New('Sacos de lixo 50l', 13.8));
    Inserir(TProdutos.New('Bolacha', 2.7));
    Inserir(TProdutos.New('Iogurte', 5.9));
    Inserir(TProdutos.New('Biscoito', 8.6));
    Inserir(TProdutos.New('Oleo', 11.5));
    Inserir(TProdutos.New('Vinagre', 3.9));
    Inserir(TProdutos.New('Sal', 2.3));
    Inserir(TProdutos.New('Acucar', 3.2));
    Inserir(TProdutos.New('Pao de forma', 7.5));
  end;
end;

end.
