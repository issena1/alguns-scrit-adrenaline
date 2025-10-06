// ARQUIVO: CarregarVertices.dpr ou CarregarVertices.lpr
unit LoadPoints;

uses
  SysUtils,     // Para TStringList, FileExists, Format
  Classes,      // Para TStringList
  RayCast; // unit que contém TPoint2D, TPolygon, IsPointInPolygon
interface
function LoadPolygonFromFile(const FileName: String; var Poly: TPolygon): Booelan;

implementation

// Procedimento para carregar vértices de um arquivo e popular um TPolygon
function LoadPolygonFromFile(const FileName: string; var Poly: TPolygon): Boolean;

var
  SL: TStringList;
  Line: string;
  StartPos, EndPos, CommaPos: Integer;
  XStr, YStr: string;
  i: Integer;
  CurrentVertex: TPoint2D;
begin
  Result := False; // Assume falha por padrão
  Poly.Count := 0;   // Inicia com 0 vértices

  SL := TStringList.Create;
  try
    if not FileExists(FileName) then
    begin
      Writeln('Erro: Arquivo "' + FileName + '" não encontrado.');
      Exit; // Sai da função
    end;

    SL.LoadFromFile(FileName);

    // Redimensiona o array de vértices para o número de linhas lidas
    SetLength(Poly.Vertices, SL.Count);

    Intersections := 0; // Reinicia para cada polígono carregado

    for i := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[i]); // Pega a linha e remove espaços em branco extras
      
      // Lida com o formato (x, y)
      if (Length(Line) > 0) and (Line[1] = '(') and (Line[Length(Line)] = ')') then
      begin
        // Remove os parênteses
        Line := Copy(Line, 2, Length(Line) - 2); 
      end;

      // Encontra a vírgula para separar X e Y
      CommaPos := Pos(',', Line);
      if CommaPos > 0 then
      begin
        XStr := Trim(Copy(Line, 1, CommaPos - 1));
        YStr := Trim(Copy(Line, CommaPos + 1, Length(Line) - CommaPos));

        // Tenta converter para Double
        try
          CurrentVertex.X := StrToFloat(XStr);
          CurrentVertex.Y := StrToFloat(YStr);
          Poly.Vertices[Poly.Count] := CurrentVertex; // Adiciona o vértice
          Inc(Poly.Count); // Incrementa a contagem de vértices válidos
        except
          on E: Exception do
            Print(Format('Aviso: Linha inválida no arquivo "%s" (linha %d): "%s" - %s', [FileName, i + 1, SL[i], E.Message]));
        end;
      end
      else
      begin
        Print(Format('Aviso: Formato de linha inválido no arquivo "%s" (linha %d): "%s" (vírgula não encontrada)', [FileName, i + 1, SL[i]]));
      end;
    end;
    Result := Poly.Count > 0; // Retorna True se pelo menos um vértice foi carregado
  finally
    SL.Free; // Garante que a TStringList seja liberada
  end;
end;

begin
  var MeuPoligono: TPolygon;
  var TestPoint: TPoint2D;
  const PolygonFileName = 'meus_vertices.txt';

  Print('Tentando carregar polígono do arquivo: ' + PolygonFileName);
  if LoadPolygonFromFile(PolygonFileName, MeuPoligono) then
  begin
    Print(Format('Polígono carregado com sucesso! %d vértices:', [MeuPoligono.Count]));
    for var i := 0 to MeuPoligono.Count - 1 do
    begin
      Writeln(Format('  Vértice %d: (%f, %f)', [i, MeuPoligono.Vertices[i].X, MeuPoligono.Vertices[i].Y]));
    end;

    Writeln('');
    Writeln('Testando um ponto...');
    TestPoint.X := User.X;
    TestPoint.Y := User.Y;

    if IsPointInPolygon(TestPoint, MeuPoligono) then
      Writeln(Format('Ponto (%.0f, %.0f) está DENTRO do polígono.', [TestPoint.X, TestPoint.Y]))
    else
      Writeln(Format('Ponto (%.0f, %.0f) está FORA do polígono.', [TestPoint.X, TestPoint.Y]));

    Writeln('');

    TestPoint.X := 50.0;
    TestPoint.Y := 50.0;
    if IsPointInPolygon(TestPoint, MeuPoligono) then
      Writeln(Format('Ponto (%.0f, %.0f) está DENTRO do polígono.', [TestPoint.X, TestPoint.Y]))
    else
      Writeln(Format('Ponto (%.0f, %.0f) está FORA do polígono.', [TestPoint.X, TestPoint.Y]));

  end
  else
  begin
    Writeln('Falha ao carregar o polígono.');
  end;

  Writeln('Pressione Enter para sair...');
  Readln;
end.
