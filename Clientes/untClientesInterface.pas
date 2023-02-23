unit untClientesInterface;

interface

type
  IClientes = interface
    ['{6821CF9A-B698-4F3D-B9B7-6A52C76DEBB3}']

    procedure Clear();

    procedure SetIdCliente(const aValue: Integer);
    procedure SetNome(const aValue: String);
    procedure SetCidade(const aValue: String);
    procedure SetUF(const aValue: String);

    function GetIdCliente:Integer;
    function GetNome:String;
    function GetCidade:String;
    function GetUF:String;
  end;

implementation

end.
