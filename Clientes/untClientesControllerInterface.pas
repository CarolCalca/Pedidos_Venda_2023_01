unit untClientesControllerInterface;

interface

uses
  untClientesInterface;

type
  IClientesController = interface
    ['{0F761BFF-B937-4F7E-BDA9-71F8D731DBBC}']

    function Inserir(oCliente: IClientes): Boolean;
    function Carregar(aIdCliente: Integer): IClientes;
  end;

implementation

end.
