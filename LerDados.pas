unit LerDados;
interface

uses Classes,
     SysUtils,
     RayCast;

type

  Txyz = record
    X: integer;
    Y: integer;
    Z: integer;
  end;

  TxyzList = record
    pos: array of Txyz;
    count: integer;
  end;

function getDados(Arq_name: string):array of string;
function trataDados(Arq_name: string): TPolygon;
function getDadosCaminho(Arq_name: string): TxyzList;

implementation


function getDados(Arq_name: string):array of string;

var Sl: TStringList;
var i, n: integer;
var vetor: array of string;
var Line: string;

begin
  Sl := TstringList.Create;

  try
    if not FileExists(Arq_name) then
    begin
      Print('Erro: ' + Arq_name + ' Não Encontrado');
      Exit;
    end;

    Sl.LoadFromFile(Arq_name);
    setLength(vetor, Sl.count);

    n := 0;

    for i := 0 to Sl.count -1 do
    begin
        if Pos('x="', Sl[i]) <> 0 then
        begin
          vetor[n] := Trim(Sl[i]);
          n := n + 1;
        end;
    end;

    setLength(vetor, n +1 );
    Result := vetor;
  finally
    Sl.free;
  end;
end;

function getDadosCaminho(Arq_name: string): TxyzList;

var SL: TStringList;
var i, n, ini, fim: integer;
var U: TxyzList;

begin
     Sl := TStringList.Create;
     Result.count := 0;
     try
        if not FileExists (Arq_name) then
           Begin
                Print('ERRO: ' +Arq_name + ' Arquivo não Encontrado');
                Engine.Say('Erro Arquivo nao Encontrado',2 , User.name);
                Exit;
           end;

         Sl.LoadFromFile(Arq_name);
         setLength(U.pos, sl.count);

         n := 0;
         for i := 0 to Sl.count -1 do
         begin
              if Pos(');', Sl[i]) <> 0 then
              begin
                   ini := Pos('(', Sl[i]) + 1;
                   fim := pos(',', Sl[i]);

                   U.pos[n].X := strtoint(Copy(Sl[i], ini, fim - ini));
                   Sl[i] := Copy(Sl[i], fim + 1, Length(Sl[i]) - 1);

                   fim := Pos(',', Sl[i]);
                   U.pos[n].y := StrToInt(Trim(Copy(Sl[i], 1, fim - 1)));

                   Sl[i] := Trim(Copy(Sl[i], fim + 1, Length(Sl[i]) - 1));

                   fim := Pos(')', Sl[i]);
                   U.pos[n].z := StrToInt(Copy(Sl[i], 1, fim - 1));

                   n := n + 1;
              end;
         end;


         setLength(U.pos, n); U.count := n;
         Result := U;
      finally
             Sl.free;
      end;

end;


function trataDados(Arq_name: string): TPolygon;

var i, PxInicio, PxFim, PyI, PyF: integer;
var P: TPolygon;
var vetor: array of string;

begin
  vetor := getDados(Arq_name);
  setLength(P.vertices, Length(vetor));
  for i := 0 to Length(vetor) - 1 do
  begin

  PxInicio := Pos('x="', vetor[i]) + 3;
  PxFim := Pos('" ', vetor[i]);
  PyI := Pos('y="', vetor[i]) + 3;
  PyF := Pos('"/', vetor[i]);

  P.vertices[i].X := strToFloat(Copy(vetor[i], PxInicio, PxFim - PxInicio));
  P.vertices[i].Y := strToFloat(Copy(vetor[i], PyI, PyF - PyI));

  end;

  Result := P;
end;

procedure Move(Arq_name: string);

var i: integer;
var P: TxyzList;

begin
     P := getDadosCaminho(Arq_name);
     if P.count = 0 then begin
        Print('Cordenadas Vazias');
        Exit;
     end;
     Engine.Say('Movendo!',2,user.name);
     for i := 0 to P.count - 1 do
     begin
          Engine.MoveTo(P.pos[i].X, P.pos[i].y, P.pos[i].z);
     end;
end;


end.
