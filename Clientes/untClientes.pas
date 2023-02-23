unit untClientes;

interface

uses
  System.SysUtils,

  untClientesInterface;

type
  TClientes = class(TInterfacedObject, IClientes)
  private
    var
      FIdCliente : Integer;
      FNome      : String;
      FCidade    : String;
      FUF        : String;
  public
    constructor Create();

    procedure Clear();

    procedure SetIdCliente(const aValue: Integer);
    procedure SetNome(const aValue: String);
    procedure SetCidade(const aValue: String);
    procedure SetUF(const aValue: String);

    function GetIdCliente:Integer;
    function GetNome:String;
    function GetCidade:String;
    function GetUF:String;

    class function New():IClientes; overload; static;
    class function New(aNome, aCidade, aUF: String):IClientes; overload; static;
  end;

implementation

{ TClientes }

procedure TClientes.Clear;
begin
  Self.FIdCliente := 0;
  Self.FNome      := EmptyStr;
  Self.FCidade    := EmptyStr;
  Self.FUF        := EmptyStr;
end;

constructor TClientes.Create;
begin
  Self.Clear;
end;

function TClientes.GetCidade: String;
begin
  Result := fCidade;
end;

function TClientes.GetIdCliente: Integer;
begin
  Result := fIdCliente;
end;

function TClientes.GetNome: String;
begin
  Result := fNome;
end;

function TClientes.GetUF: String;
begin
  Result := fUF;
end;

procedure TClientes.SetCidade(const aValue: String);
begin
  FCidade := aValue;
end;

procedure TClientes.SetIdCliente(const aValue: Integer);
begin
  FIdCliente := aValue;
end;

procedure TClientes.SetNome(const aValue: String);
begin
  FNome := aValue;
end;

procedure TClientes.SetUF(const aValue: String);
begin
  FUF := aValue;
end;

class function TClientes.New: IClientes;
begin
  Result := TClientes.Create;
end;

class function TClientes.New(aNome, aCidade, aUF: String): IClientes;
begin
  Result := TClientes.New;

  Result.SetNome(aNome);
  Result.SetCidade(aCidade);
  Result.SetUF(aUF);
end;

end.
