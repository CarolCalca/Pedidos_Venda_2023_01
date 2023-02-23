unit untMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  Datasnap.DBClient,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.ExtCtrls,
  System.UITypes,
  FireDAC.Comp.Client,
  Datasnap.Provider,

  untClientes,
  untClientesInterface,
  untClientesController,
  untProdutos,
  untProdutosController,
  untProdutosInterface,
  untPedidos,
  untPedidosInterface,
  untPedidosController,
  untPedidosControllerInterface,
  untPedidosItens,
  untPedidosItensInterface,
  untPedidosItensController,
  untPedidosItensControllerInterface,

  untConnection;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    btnCarregar: TButton;
    btnCancelar: TButton;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    btnAdicionar: TButton;
    dbgProdutos: TDBGrid;
    edtIdCliente: TEdit;
    edtIdProduto: TEdit;
    edtQtd: TEdit;
    edtValor: TEdit;
    edtNomeCliente: TEdit;
    edtDescProduto: TEdit;
    Panel4: TPanel;
    Label6: TLabel;
    lblTotal: TLabel;
    btnGravar: TButton;
    cdsProdutos: TClientDataSet;
    cdsProdutosidpeditem: TIntegerField;
    cdsProdutosidpedgeral: TIntegerField;
    cdsProdutosidproduto: TIntegerField;
    cdsProdutosdescricao: TStringField;
    cdsProdutosquantidade: TIntegerField;
    cdsProdutosvlrunitario: TFloatField;
    cdsProdutosvlrtotal: TFloatField;
    dsProdutos: TDataSource;
    cdsProdDel: TClientDataSet;
    cdsProdDelidpeditem: TIntegerField;
    procedure FormCreate(Sender: TObject);
    procedure edtIdClienteChange(Sender: TObject);
    procedure edtIdClienteExit(Sender: TObject);
    procedure edtIdProdutoChange(Sender: TObject);
    procedure edtIdProdutoExit(Sender: TObject);
    procedure edtValorExit(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure dbgProdutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    const cVlrMask: String = '#,###,###,##0.00';

    procedure LimpaTela;
    function CalcVlrTotal: Double;
    function RetornaCliente(aIdCliente: String): String;
    function RetornaProduto(aIdProduto: String): String;


    function ValidaAdicionarItem(): Boolean;
    procedure AdicionarItem;
    procedure CancelarPedido;
    procedure CarregarPedido;
    function ValidaGravarPedido(): Boolean;
    procedure GravarPedido;

  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.btnAdicionarClick(Sender: TObject);
begin
  if ValidaAdicionarItem then
    AdicionarItem;
end;

function TfMain.ValidaAdicionarItem: Boolean;
begin
  Result := False;

  if (edtIdProduto.Text = EmptyStr) then
  begin
    MessageDlg('Por favor, preencha o produto.', mtWarning, [mbOk], 0, mbOk);
    edtIdProduto.SetFocus;
  end
  else if (StrToIntDef(edtQtd.Text, 0) = 0) then
  begin
    MessageDlg('Por favor, preencha a quantidade.', mtWarning, [mbOk], 0, mbOk);
    edtQtd.SetFocus;
  end
  else if (StrToFloatDef(edtValor.Text, 0) = 0) then
  begin
    MessageDlg('Por favor, preencha o valor unitário.', mtWarning, [mbOk], 0, mbOk);
    edtValor.SetFocus;
  end
  else
    Result := True;

end;

procedure TfMain.AdicionarItem;
begin
  cdsProdutos.DisableControls;

    try
      try
        if not (cdsProdutos.State in [dsEdit]) then
        begin
          cdsProdutos.Append;
          cdsProdutos.FieldByName('idpeditem').AsInteger := 0;
          cdsProdutos.FieldByName('idpedgeral').AsInteger := 0;
          cdsProdutos.FieldByName('idproduto').AsInteger := StrToInt(edtIdProduto.Text);
          cdsProdutos.FieldByName('descricao').AsString := edtDescProduto.Text;
        end;

        cdsProdutos.FieldByName('quantidade').AsInteger := StrToInt(edtQtd.Text);
        cdsProdutos.FieldByName('vlrunitario').AsFloat := StrToFloat(edtValor.Text);
        cdsProdutos.FieldByName('vlrtotal').AsFloat := (StrToFloat(edtValor.Text) * StrToInt(edtQtd.Text));
        cdsProdutos.Post;

        CalcVlrTotal;

        edtIdProduto.SetFocus;

      except on E:Exception do
        begin
          MessageDlg('Erro ao incluir/alterar o produto!' + #13 + #13 + E.Message, mtError, [mbOk], 0, mbOk);
          edtIdProduto.SetFocus;
        end;
      end;
    finally
      cdsProdutos.EnableControls;
    end;

end;

procedure TfMain.btnCancelarClick(Sender: TObject);
begin
  CancelarPedido;
end;

procedure TfMain.CancelarPedido;
var
  vIdPedGeral: Integer;
begin

  try
    vIdPedGeral := StrToInt(InputBox('Cancelar pedido', 'Digite o número do pedido que deseja cancelar:', '0'));

    if (vIdPedGeral > 0) then
      if TPedidoController.New.Excluir(vIdPedGeral) then
        MessageDlg('Pedido cancelado com sucesso!', mtInformation, [mbOk], 0, mbOk);

  except on E:Exception do
    MessageDlg('Número de pedido inválido!', mtError, [mbOk], 0, mbOk);
  end;
end;

procedure TfMain.btnCarregarClick(Sender: TObject);
begin
  CarregarPedido;
end;

procedure TfMain.CarregarPedido;
var
  I, vIdPedGeral: Integer;
  oPedido: IPedidos;
begin
  LimpaTela;

  try
    vIdPedGeral := StrToInt(InputBox('Carregar pedido', 'Digite o número do pedido que deseja carregar:', '0'));

    if (vIdPedGeral > 0) then
    begin
      oPedido := TPedidoController.New.Carregar(vIdPedGeral);

      if (oPedido.GetIdPedGeral > 0) then
      begin
        edtIdCliente.Text := IntToStr(oPedido.GetIdCliente);
        edtIdClienteExit(edtIdCliente);

        for I := 0 to pred(oPedido.GetPedidoItem.Count) do
        begin
          cdsProdutos.Append;
          cdsProdutos.FieldByName('IdPedItem').AsInteger := oPedido.GetPedidoItem[I].GetIdPedItem;
          cdsProdutos.FieldByName('IdPedGeral').AsInteger := oPedido.GetPedidoItem[I].GetIdPedGeral;
          cdsProdutos.FieldByName('IdProduto').AsInteger := oPedido.GetPedidoItem[I].GetIdProduto;
          cdsProdutos.FieldByName('Descricao').AsString := RetornaProduto(IntToStr(oPedido.GetPedidoItem[I].GetIdProduto));
          cdsProdutos.FieldByName('Quantidade').AsInteger := oPedido.GetPedidoItem[I].GetQuantidade;
          cdsProdutos.FieldByName('VlrUnitario').AsFloat := oPedido.GetPedidoItem[I].GetVlrUnitario;
          cdsProdutos.FieldByName('VlrTotal').AsFloat := oPedido.GetPedidoItem[I].GetVlrTotal;
          cdsProdutos.Post;
        end;

        CalcVlrTotal;
      end
      else
        MessageDlg('Pedido não encontrado!', mtInformation, [mbOk], 0, mbOk);
    end;

  except on E:Exception do
    MessageDlg('Número de pedido inválido!', mtError, [mbOk], 0, mbOk);
  end;
end;

procedure TfMain.btnGravarClick(Sender: TObject);
begin
  if ValidaGravarPedido then
    GravarPedido;
end;

function TfMain.ValidaGravarPedido: Boolean;
begin
  Result := False;

  if (edtIdCliente.Text = EmptyStr) then
  begin
    MessageDlg('Por favor, preencha o cliente.', mtWarning, [mbOk], 0, mbOk);
    edtIdCliente.SetFocus;
  end
  else if (cdsProdutos.IsEmpty) then
  begin
    MessageDlg('Por favor, adicione produtos ao pedido.', mtWarning, [mbOk], 0, mbOk);
    edtIdProduto.SetFocus;
  end
  else
    Result := True;

end;

procedure TfMain.GravarPedido;
var
  oPedidosItens: IPedidosItens;
  oPedidoItemController: IPedidosItensController;
  oPedido: IPedidos;
  vIdPedGeral: Integer;
begin

  oPedidoItemController := TPedidoItemController.New;

  cdsProdutos.DisableControls;
  cdsProdDel.DisableControls;

  TConnection.StartTransaction;

  try
    try
      cdsProdDel.First;
      while not cdsProdDel.Eof do
      begin
        oPedidoItemController.Excluir(cdsProdDel.FieldByName('IdPedItem').AsInteger);
        cdsProdDel.Next;
      end;

      cdsProdutos.First;
      vIdPedGeral := cdsProdutos.FieldByName('idpedgeral').AsInteger;

      while not cdsProdutos.Eof do
      begin
        oPedidosItens := TPedidosItens.New;

        oPedidosItens.SetIdPedItem(cdsProdutos.FieldByName('IdPedItem').AsInteger);
        oPedidosItens.SetIdPedGeral(vIdPedGeral);
        oPedidosItens.SetIdProduto(cdsProdutos.FieldByName('IdProduto').AsInteger);
        oPedidosItens.SetQuantidade(cdsProdutos.FieldByName('Quantidade').AsInteger);
        oPedidosItens.SetVlrUnitario(cdsProdutos.FieldByName('VlrUnitario').AsFloat);
        oPedidosItens.SetVlrTotal(cdsProdutos.FieldByName('VlrTotal').AsFloat);

        oPedido.GetPedidoItem.Add(oPedidosItens);

        cdsProdutos.Next;
      end;

      oPedido.SetIdPedGeral(vIdPedGeral);
      oPedido.SetData(Now());
      oPedido.SetIdCliente(StrToInt(edtIdCliente.Text));
      oPedido.SetVlrTotal(CalcVlrTotal);

      if (vIdPedGeral > 0) then
        TPedidoController.New.Alterar(oPedido)
      else
        TPedidoController.New.Inserir(oPedido);

      TConnection.Commit;

      LimpaTela;
    except on E:Exception do
      begin
        TConnection.Rollback;
        MessageDlg('Erro ao gravar o pedido!', mtError, [mbOk], 0, mbOk);
      end;
    end;
  finally
    cdsProdutos.EnableControls;
    cdsProdDel.EnableControls;
  end;
end;

function TfMain.CalcVlrTotal: Double;
begin
  Result := 0;

  cdsProdutos.DisableControls;

  try
    cdsProdutos.First;
    while not cdsProdutos.Eof do
    begin
      Result := Result + cdsProdutos.FieldByName('vlrtotal').AsFloat;

      cdsProdutos.Next;
    end;

    lblTotal.Caption := 'R$ ' + FormatFloat(cVlrMask, Result);
  finally
    cdsProdutos.EnableControls;
  end;
end;

procedure TfMain.dbgProdutosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_up then
    dbgProdutos.Datasource.Dataset.Prior;

  if Key = vk_down then
    dbgProdutos.Datasource.Dataset.Next;

  if (cdsProdutos.FieldByName('idproduto').AsInteger > 0) then
  begin
    if Key = vk_delete then
    begin
      if MessageDlg('Deseja excluir o item do pedido?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        // adiciona em outro dataset, para excluir apenas ao gravar, na transação
        if (cdsProdutos.FieldByName('idpeditem').AsInteger > 0) then
        begin
          cdsProdDel.Append;
          cdsProdDel.FieldByName('idpeditem').AsInteger := cdsProdutos.FieldByName('idpeditem').AsInteger;
          cdsProdDel.Post;
        end;

        cdsProdutos.Delete;
      end;
    end;

    if Key = vk_return then
    begin
      dbgProdutos.Options := dbgProdutos.Options + [dgEditing];
      cdsProdutos.Edit;
    end;
  end;
end;

procedure TfMain.edtIdClienteChange(Sender: TObject);
begin
  btnCarregar.Enabled := (edtIdCliente.Text = EmptyStr);
  btnCancelar.Enabled := (edtIdCliente.Text = EmptyStr);

  edtNomeCliente.Text := EmptyStr;
end;

procedure TfMain.edtIdClienteExit(Sender: TObject);
begin
  edtNomeCliente.Text := RetornaCliente(edtIdCliente.Text);

  if (edtNomeCliente.Text = EmptyStr) then
    edtIdCliente.Text := EmptyStr;
end;

procedure TfMain.edtIdProdutoChange(Sender: TObject);
begin
  edtDescProduto.Text := EmptyStr;
  edtQtd.Text := '0';
  edtValor.Text := '0,00';
end;

procedure TfMain.edtIdProdutoExit(Sender: TObject);
begin
  edtDescProduto.Text := RetornaProduto(edtIdProduto.Text);
  edtValor.Text := FormatFloat(cVlrMask, TProdutoController.New.RetornaValorProduto(StrToIntDef(edtIdProduto.Text, 0)));

  if (edtDescProduto.Text = EmptyStr) then
    edtIdProduto.Text := EmptyStr;
end;

procedure TfMain.edtValorExit(Sender: TObject);
var
  vValor: String;
begin
  vValor := EmptyStr;

  if edtValor.Text <> EmptyStr then
  begin
    vValor := StringReplace(edtValor.Text, '.', EmptyStr, [rfReplaceAll]);
    vValor := StringReplace(edtValor.Text, ',', EmptyStr, [rfReplaceAll]);

    if (Length(vValor) = 1) then
      vValor := '0,0' + vValor
    else if (Length(vValor) = 2) then
      vValor := '0,' + vValor
    else
      vValor := Copy(vValor, 1, Length(vValor)-2) + ',' + Copy(vValor, Length(vValor)-1, 2);

    vValor := FormatFloat(cVlrMask, StrToFloat(vValor));
  end
  else
    vValor := '0,00';

  edtValor.Text := vValor;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  TConnection.createDB();

  cdsProdutos.CreateDataSet;
  cdsProdDel.CreateDataSet;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  edtIdCliente.SetFocus;
end;

procedure TfMain.LimpaTela;
begin
  edtIdCliente.Text := EmptyStr;
  edtIdClienteExit(nil);
  edtIdProduto.Text := EmptyStr;
  edtIdProdutoExit(nil);
  edtQtd.Text := '0';
  edtValor.Text := '0,00';
  cdsProdutos.EmptyDataSet;
  cdsProdDel.EmptyDataSet;
end;

function TfMain.RetornaCliente(aIdCliente: String): String;
var
  oCliente: IClientes;
begin
  Result := EmptyStr;

  if (aIdCliente = EmptyStr) then
    aIdCliente := '0';

  if (aIdCliente <> '0') then
  begin
    oCliente := TClienteController.New.Carregar(StrToInt(aIdCliente));

    if (oCliente.GetIdCliente() > 0) then
      Result := oCliente.GetNome;
  end;
end;

function TfMain.RetornaProduto(aIdProduto: String): String;
var
  oProduto: IProdutos;
begin
  Result := EmptyStr;

  if (aIdProduto = EmptyStr) then
    aIdProduto := '0';

  if (aIdProduto > '0') then
  begin
    oProduto := TProdutoController.New.Carregar(StrToInt(aIdProduto));

    if (oProduto.GetIdProduto() > 0) then
      Result := oProduto.GetDescricao;
  end;
end;

end.
