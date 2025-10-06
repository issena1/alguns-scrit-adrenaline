// ARQUIVO: RayCast.pas
//
// Esta unit implementa o algoritmo "Ray Casting" para
// verificar se um ponto 2D está localizado dentro de um polígono 2D.
// Ou verificação de área.

unit RayCast; 

interface // Seção de Interface

// --- Definições de Tipos ---
// Estes tipos são exportados para que outras units possam criar e manipular pontos e polígonos.

type
  // TPoint2D: Representa um ponto no plano 2D.
  // Uso do Double para maior precisão.
  TPoint2D = record
    X: Double; // Coordenada horizontal do ponto
    Y: Double; // Coordenada vertical do ponto
  end;

  // TPolygon: Representa um polígono 2D.
  // Um polígono é definido por uma sequência de vértices.
  TPolygon = record
    Vertices: array of TPoint2D; // Array dinâmico de pontos que formam os vértices do polígono.
                                 // Os vértices devem ser listados em ordem (horária ou anti-horária).
    Count: Integer;              // Número de vértices válidos no array 'Vertices'.
                                 // 'SetLength' aloca espaço, mas 'Count' indica quantos são usados.
  end;

// --- Declaração da Função ---
// IsPointInPolygon: A função principal que verifica a inclusão de um ponto em um polígono.
//
// Parâmetros:
//   P: O ponto 2D (TPoint2D) a ser testado. Declarado como 'const' para eficiência,
//      indicando que a função não modificará o ponto.
//   Poly: O polígono (TPolygon) contra o qual o ponto será testado. Também 'const'.
//
// Retorna:
//   Boolean: True se o ponto 'P' estiver dentro do polígono 'Poly', False caso contrário.
function IsPointInPolygon(const P: TPoint2D; const Poly: TPolygon): Boolean;

implementation // Seção de Implementação

// --- Implementação da Função IsPointInPolygon ---
// Este procedimento usa o algoritmo "Ray Casting".
// O algoritmo traça um raio horizontal do ponto de teste para a direita e
// conta quantas vezes ele cruza as arestas do polígono.
// - Se o número de cruzamentos for ímpar, o ponto está dentro.
// - Se o número de cruzamentos for par, o ponto está fora.
function IsPointInPolygon(const P: TPoint2D; const Poly: TPolygon): Boolean;
var
  i, j: Integer;         // Variáveis de iteração para percorrer os vértices do polígono
  Intersections: Integer; // Contador de interseções do raio com as arestas do polígono
begin
  Intersections := 0; // Inicializa o contador de interseções.

  // Loop principal: Percorre todas as arestas do polígono.
  // Para cada aresta, consideramos dois vértices consecutivos: Poly.Vertices[i] e Poly.Vertices[j].
  for i := 0 to Poly.Count - 1 do
  begin
    // 'j' representa o vértice anterior a 'i' na sequência.
    // O operador 'mod Poly.Count' garante que, quando 'i' for 0, 'j' seja o último vértice,
    // fechando assim o polígono para a verificação da última aresta.
    j := (i + Poly.Count - 1) mod Poly.Count;

    // Condição 1: Verifica se a aresta atual (Poly.Vertices[i] a Poly.Vertices[j]) cruza
    // a linha horizontal imaginária que passa pelo ponto P.
    // Uma aresta cruza se um de seus vértices está acima de P.Y e o outro abaixo (ou vice-versa).
    if ((Poly.Vertices[i].Y > P.Y) <> (Poly.Vertices[j].Y > P.Y)) then
    begin
      // Condição 2: Se a aresta cruza a linha horizontal de P.Y,
      // calculamos o ponto de interseção X na aresta com essa linha horizontal.
      // Em seguida, verificamos se o X da interseção está à direita do X do ponto P.
      // Se estiver à direita (P.X < X_intersecao), significa que o raio horizontal
      // que parte de P para a direita cruzou esta aresta.
      //
      // A fórmula para X_intersecao é:
      // X_intersecao = (Poly.Vertices[j].X - Poly.Vertices[i].X) * (P.Y - Poly.Vertices[i].Y) / (Poly.Vertices[j].Y - Poly.Vertices[i].Y) + Poly.Vertices[i].X
      // Esta é a equação de uma linha reta, resolvida para X no Y do ponto P.
      // A divisão por (Poly.Vertices[j].Y - Poly.Vertices[i].Y) é segura porque a Condição 1
      // já garante que Poly.Vertices[i].Y não é igual a Poly.Vertices[j].Y (ou seja, a aresta não é horizontal).
      if (P.X < (Poly.Vertices[j].X - Poly.Vertices[i].X) * (P.Y - Poly.Vertices[i].Y) /
                 (Poly.Vertices[j].Y - Poly.Vertices[i].Y) + Poly.Vertices[i].X) then
      begin
        Inc(Intersections); // Incrementa o contador de interseções.
      end;
    end;
  end;

  // Resultado Final:
  // Se o número total de interseções for ímpar, o ponto está dentro do polígono.
  // Se for par, o ponto está fora.
  // Isso se baseia no princípio de que cada vez que o raio cruza uma aresta,
  // ele "entra" ou "sai" do polígono.
  Result := (Intersections mod 2) = 1;
end;

end. // Fim da Unit 'RayCast'.
