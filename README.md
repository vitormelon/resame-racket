Resolvedor do jogo Same em Racket 

Introdução

O objetivo deste trabalho é a implementação de um resolvedor do jogo Same em Racket.

Descrição

Um jogo Same consiste de um campo retangular inicialmente preenchido com blocos coloridos. O jogador pode selecionar um grupo (clicando em uma posição) para ser removido. Dois blocos estão no mesmo grupo se eles tem a mesma cor e são adjacentes (na vertical ou na horizontal). Após selecionar um grupo, os blocos que estavam acima dos blocos do grupo caem e preenchem os espaços vazios. Quando um coluna fica sem blocos, os blocos a direita são deslocados para a esquerda. Apenas grupos com mais que um bloco podem ser selecionados. A figura a seguir mostrar a seleção e remoção de um grupo.

Exemplo do jogo Same

Uma solução para um jogo Same é uma sequência de posições que quando “clicadas” removem todos os blocos.

O programa deve receber como parâmetro na linha de comando um arquivo com a especificação do jogo e escrever na saída padrão uma resolução para o jogo, ou sem-solucao, se não existe solução para o jogo. Uma resolução consiste em uma sequência de jogadas (posições) e resultados (campo obtido após a jogada). As jogadas e os resultados devem ser separados por uma linha em branco.

Por exemplo, considere um arquivo com o seguinte conteúdo
```text
2 1 3 1
2 2 2 3
2 3 3 1
```
No arquivo de entrada, as linhas e as colunas são enumeradas da seguinte forma
```text
2 | 2 1 3 1
1 | 2 2 2 3
0 | 2 3 3 1
--+--------
  | 0 1 2 3
```
Uma possível resolução para este jogo é
```text
0 0

0 0 1 0
1 3 3 0
3 3 1 0

1 2

0 0 0 0
0 1 0 0
1 1 0 0

1 1

0 0 0 0
0 0 0 0
0 0 0 0
```
Observe que as posições são representadas pelo número da linha seguido pelo número da coluna.

Uma estratégia simples para encontrar uma solução para um jogo Same é:

escolha um grupo qualquer
remova o grupo
se não existir um grupo que possa ser removido, retroceda na jogada anterior e escolha outro grupo
se acabaram as opções de grupos na primeira jogada, então o jogo não tem solução
utilize recursivamente o mesmo processo para resolver o jogo obtido no passo 2

Para executar os testes funcionais, entre no diretório resame-racket e execute um dos comandos

make testar-alguns  # testar os resolvedores com alguns casos de teste
make testar-todos   # testar os resolvedores com todos os casos de teste
