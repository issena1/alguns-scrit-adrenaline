// ARQUIVO: RoadTo.pas
// Esta unit contém um procedimento para executar um caminho de movimento predefinido.
// um teste para usar a função de carregar scripts do adrrenaline


unit RoadTo;


interface // Seção de Interface

uses sysutils;

// Declaração do procedimento que executa o caminho
procedure Giants;
procedure road(local: string);

implementation // Seção de Implementação: Detalhes internos do procedimento

procedure Giants;

begin

     Engine.MoveTo(169135, 39989, -4029);
     Engine.MoveTo(169896, 42056, -4856);
     Engine.MoveTo(170184, 44697, -4744);
     Engine.MoveTo(171135, 44870, -4482);
     Engine.MoveTo(171860, 46634, -4174);
     Engine.MoveTo(172639, 48372, -4118);
     Engine.MoveTo(173712, 49330, -4122);
     Engine.MoveTo(174378, 50052, -4239);
     Engine.MoveTo(174511, 52845, -4368);
     Engine.MoveTo(174511, 52845, -4360);


end;



procedure road(local: string);

var aux: string;

begin
aux := LowerCase(local);
if (aux = 'giant') or (aux = 'giants')then
   giants;
end;
end.
