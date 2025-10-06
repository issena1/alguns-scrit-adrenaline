// ARQUIVO: CarregarVertices.dpr ou CarregarVertices.lpr
unit LoadPoints;

uses
  SysUtils,     // Para TStringList, FileExists, Format
  Classes,      // Para TStringList
  RayCast; // unit que cont�m TPoint2D, TPolygon, IsPointInPolygon
interface
function LoadPolygonFromFile(const FileName: String; var Poly: TPolygon): Booelan;

implementation

// Procedimento para carregar v�rtices de um arquivo e popular um TPolygon
function LoadPolygonFromFile(const FileName: string; var Poly: TPolygon): Boolean;

var
  SL: TStringList;
  Line: string;
  StartPos, EndPos, CommaPos: Integer;
  XStr, YStr: string;
  i: Integer;
  CurrentVertex: TPoint2D;
begin
  Result := False; // Assume falha por padr�o
  Poly.Count := 0;   // Inicia com 0 v�rtices

  SL := TStringList.Create;
  try
    if not FileExists(FileName) then
    begin
      Writeln('Erro: Arquivo "' + FileName + '" n�o encontrado.');
      Exit; // Sai da fun��o
    end;

    SL.LoadFromFile(FileName);

    // Redimensiona o array de v�rtices para o n�mero de linhas lidas
    SetLength(Poly.Vertices, SL.Count);

    Intersections := 0; // Reinicia para cada pol�gono carregado

    for i := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[i]); // Pega a linha e remove espa�os em branco extras
      
      // Lida com o formato (x, y)
      if (Length(Line) > 0) and (Line[1] = '(') and (Line[Length(Line)] = ')') then
      begin
        // Remove os par�nteses
        Line := Copy(Line, 2, Length(Line) - 2); 
      end;

      // Encontra a v�rgula para separar X e Y
      CommaPos := Pos(',', Line);
      if CommaPos > 0 then
      begin
        XStr := Trim(Copy(Line, 1, CommaPos - 1));
        YStr := Trim(Copy(Line, CommaPos + 1, Length(Line) - CommaPos));

        // Tenta converter para Double
        try
          CurrentVertex.X := StrToFloat(XStr);
          CurrentVertex.Y := StrToFloat(YStr);
          Poly.Vertices[Poly.Count] := CurrentVertex; // Adiciona o v�rtice
          Inc(Poly.Count); // Incrementa a contagem de v�rtices v�lidos
        except
          on E: Exception do
            Print(Format('Aviso: Linha inv�lida no arquivo "%s" (linha %d): "%s" - %s', [FileName, i + 1, SL[i], E.Message]));
        end;
      end
      else
      begin
        Print(Format('Aviso: Formato de linha inv�lido no arquivo "%s" (linha %d): "%s" (v�rgula n�o encontrada)', [FileName, i + 1, SL[i]]));
      end;
    end;
    Result := Poly.Count > 0; // Retorna True se pelo menos um v�rtice foi carregado
  finally
    SL.Free; // Garante que a TStringList seja liberada
  end;
end;

begin
  var MeuPoligono: TPolygon;
  var TestPoint: TPoint2D;
  const PolygonFileName = 'meus_vertices.txt';

  Print('Tentando carregar pol�gono do arquivo: ' + PolygonFileName);
  if LoadPolygonFromFile(PolygonFileName, MeuPoligono) then
  begin
    Print(Format('Pol�gono carregado com sucesso! %d v�rtices:', [MeuPoligono.Count]));
    for var i := 0 to MeuPoligono.Count - 1 do
    begin
      Writeln(Format('  V�rtice %d: (%f, %f)', [i, MeuPoligono.Vertices[i].X, MeuPoligono.Vertices[i].Y]));
    end;

    Writeln('');
    Writeln('Testando um ponto...');
    TestPoint.X := User.X;
    TestPoint.Y := User.Y;

    if IsPointInPolygon(TestPoint, MeuPoligono) then
      Writeln(Format('Ponto (%.0f, %.0f) est� DENTRO do pol�gono.', [TestPoint.X, TestPoint.Y]))
    else
      Writeln(Format('Ponto (%.0f, %.0f) est� FORA do pol�gono.', [TestPoint.X, TestPoint.Y]));

    Writeln('');

    TestPoint.X := 50.0;
    TestPoint.Y := 50.0;
    if IsPointInPolygon(TestPoint, MeuPoligono) then
      Writeln(Format('Ponto (%.0f, %.0f) est� DENTRO do pol�gono.', [TestPoint.X, TestPoint.Y]))
    else
      Writeln(Format('Ponto (%.0f, %.0f) est� FORA do pol�gono.', [TestPoint.X, TestPoint.Y]));

  end
  else
  begin
    Writeln('Falha ao carregar o pol�gono.');
  end;

  Writeln('Pressione Enter para sair...');
  Readln;
end.
