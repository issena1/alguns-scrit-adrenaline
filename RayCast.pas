// ARQUIVO: RayCast.pas
//
// Esta unit implementa o algoritmo "Ray Casting" para
// verificar se um ponto 2D est� localizado dentro de um pol�gono 2D.
// Ou verifica��o de �rea.

unit RayCast; 

interface // Se��o de Interface

// --- Defini��es de Tipos ---
// Estes tipos s�o exportados para que outras units possam criar e manipular pontos e pol�gonos.

type
  // TPoint2D: Representa um ponto no plano 2D.
  // Uso do Double para maior precis�o.
  TPoint2D = record
    X: Double; // Coordenada horizontal do ponto
    Y: Double; // Coordenada vertical do ponto
  end;

  // TPolygon: Representa um pol�gono 2D.
  // Um pol�gono � definido por uma sequ�ncia de v�rtices.
  TPolygon = record
    Vertices: array of TPoint2D; // Array din�mico de pontos que formam os v�rtices do pol�gono.
                                 // Os v�rtices devem ser listados em ordem (hor�ria ou anti-hor�ria).
    Count: Integer;              // N�mero de v�rtices v�lidos no array 'Vertices'.
                                 // 'SetLength' aloca espa�o, mas 'Count' indica quantos s�o usados.
  end;

// --- Declara��o da Fun��o ---
// IsPointInPolygon: A fun��o principal que verifica a inclus�o de um ponto em um pol�gono.
//
// Par�metros:
//   P: O ponto 2D (TPoint2D) a ser testado. Declarado como 'const' para efici�ncia,
//      indicando que a fun��o n�o modificar� o ponto.
//   Poly: O pol�gono (TPolygon) contra o qual o ponto ser� testado. Tamb�m 'const'.
//
// Retorna:
//   Boolean: True se o ponto 'P' estiver dentro do pol�gono 'Poly', False caso contr�rio.
function IsPointInPolygon(const P: TPoint2D; const Poly: TPolygon): Boolean;

implementation // Se��o de Implementa��o

// --- Implementa��o da Fun��o IsPointInPolygon ---
// Este procedimento usa o algoritmo "Ray Casting".
// O algoritmo tra�a um raio horizontal do ponto de teste para a direita e
// conta quantas vezes ele cruza as arestas do pol�gono.
// - Se o n�mero de cruzamentos for �mpar, o ponto est� dentro.
// - Se o n�mero de cruzamentos for par, o ponto est� fora.
function IsPointInPolygon(const P: TPoint2D; const Poly: TPolygon): Boolean;
var
  i, j: Integer;         // Vari�veis de itera��o para percorrer os v�rtices do pol�gono
  Intersections: Integer; // Contador de interse��es do raio com as arestas do pol�gono
begin
  Intersections := 0; // Inicializa o contador de interse��es.

  // Loop principal: Percorre todas as arestas do pol�gono.
  // Para cada aresta, consideramos dois v�rtices consecutivos: Poly.Vertices[i] e Poly.Vertices[j].
  for i := 0 to Poly.Count - 1 do
  begin
    // 'j' representa o v�rtice anterior a 'i' na sequ�ncia.
    // O operador 'mod Poly.Count' garante que, quando 'i' for 0, 'j' seja o �ltimo v�rtice,
    // fechando assim o pol�gono para a verifica��o da �ltima aresta.
    j := (i + Poly.Count - 1) mod Poly.Count;

    // Condi��o 1: Verifica se a aresta atual (Poly.Vertices[i] a Poly.Vertices[j]) cruza
    // a linha horizontal imagin�ria que passa pelo ponto P.
    // Uma aresta cruza se um de seus v�rtices est� acima de P.Y e o outro abaixo (ou vice-versa).
    if ((Poly.Vertices[i].Y > P.Y) <> (Poly.Vertices[j].Y > P.Y)) then
    begin
      // Condi��o 2: Se a aresta cruza a linha horizontal de P.Y,
      // calculamos o ponto de interse��o X na aresta com essa linha horizontal.
      // Em seguida, verificamos se o X da interse��o est� � direita do X do ponto P.
      // Se estiver � direita (P.X < X_intersecao), significa que o raio horizontal
      // que parte de P para a direita cruzou esta aresta.
      //
      // A f�rmula para X_intersecao �:
      // X_intersecao = (Poly.Vertices[j].X - Poly.Vertices[i].X) * (P.Y - Poly.Vertices[i].Y) / (Poly.Vertices[j].Y - Poly.Vertices[i].Y) + Poly.Vertices[i].X
      // Esta � a equa��o de uma linha reta, resolvida para X no Y do ponto P.
      // A divis�o por (Poly.Vertices[j].Y - Poly.Vertices[i].Y) � segura porque a Condi��o 1
      // j� garante que Poly.Vertices[i].Y n�o � igual a Poly.Vertices[j].Y (ou seja, a aresta n�o � horizontal).
      if (P.X < (Poly.Vertices[j].X - Poly.Vertices[i].X) * (P.Y - Poly.Vertices[i].Y) /
                 (Poly.Vertices[j].Y - Poly.Vertices[i].Y) + Poly.Vertices[i].X) then
      begin
        Inc(Intersections); // Incrementa o contador de interse��es.
      end;
    end;
  end;

  // Resultado Final:
  // Se o n�mero total de interse��es for �mpar, o ponto est� dentro do pol�gono.
  // Se for par, o ponto est� fora.
  // Isso se baseia no princ�pio de que cada vez que o raio cruza uma aresta,
  // ele "entra" ou "sai" do pol�gono.
  Result := (Intersections mod 2) = 1;
end;

end. // Fim da Unit 'RayCast'.
