#lang racket
(provide position
         position-lin
         position-col
         same-create-group
         same-remove-group
         main)

; Um Jogo same é representado por uma lista de colunas, sem os elementos
; nulos (zeros).
; Por exemplo, o jogo
; 2 | 3 0 0 0
; 1 | 2 2 2 0
; 0 | 2 3 3 1
; --+--------
;   | 0 1 2 3
; é representado como ((2 2 3) (3 2) (3 2) (1)).
;
; O tamanho deste jogo é 3x4 (linhas x colunas).
;
; Uma posição é representada pela estrutura position. Ex:
; > (define p (position 1 3)) ; linha 1 coluna 3
; > (position-lin p)          ; acessa o valor da linha de p
; 1
; > (position-col p)          ; acessa o valor da coluna de p
; 3



;Esta função abre o arquivo selecionado e gera a matriz que é o Same.
;**Importante** a matriz gerada é a trasnposta da martiz original, 
;pois facilita a manipulação dos dados!!
(define (generate-matrix file)
  (define arq (file->lines file))
  (define (gen-mat-it arq num )
    (if (> num 0)
        (append (gen-mat-it (cdr arq) (- num 1)) (list (string-split (car arq))))
        null)
    )
  (matrix-transpose (gen-mat-it arq (length arq)))
)

;---------------------------------


; Esta função recebe como parâmetro um jogo same e retorna uma lista de
; posições que quando clicadas resolvem o jogo. Se o jogo não tem solução, está
; função retornar #f.
; Esta função não é testada no arquivo resame-tests.rkt.
; Esta função é testada pelo testador externo.
(define (same-solve same)
  
  (define (busca-visi lista p)
    (define (bus-visi-it lista p n tam)
      (if (< n tam)
          (cond [(equal? (list-ref lista n) p) #f]
                [#t (bus-visi-it lista p (+ n 1) tam)])
          #t
          )
      )
    (bus-visi-it lista p 0 (length lista))
    )
 
  (define (busca same caminho)
  (define col (length same))
  (define (double-for visitado i j col)
    (if (< i col)
        (let ([lin (length (list-ref same i))])
          (if (< j lin)
              (if (busca-visi visitado (position j i))
                  (let* ([p (position j i)]
                     [group (same-create-group same p)])
                ;(printf "~a ~s\n" j i)
                (if (< (length group) 2)
                    (double-for visitado i (add1 j) col)
                    (let* ([caminho (append caminho (list p))]
                           [result (busca (same-remove-group same group) caminho)])
                      (if (list? result)
                          result
                          (double-for (append visitado group) i (add1 j) col)
                          )
                      )
                    )
                    )
                  (double-for visitado i (add1 j) col)
                  )
              (double-for visitado (add1 i) 0 col)
              )
          )
        #f
        )
    )
      (if (null? same)
        caminho
        (double-for '() 0 0 col)
        )
  )
  
  (busca same '())
)
  
;--------------------------------


; Esta função recebe como parâmetro um jogo same e uma posição p e criar um
; grupo (lista de posições) que contém p.
(define (same-create-group same p)
  
  ;Funçao recebe como parametro um jogo (same) e uma position, e retorna o valor naquela posição
  (define (mat-pos-val same p)
    (list-ref (list-ref same (position-col p)) (position-lin p))
    
    )
  
  ;Função para verificar se a posição ja foi visitada. retorna #f se ja foi visitada e #t se nao.
  (define (busca-visi lista p)
    (define (bus-visi-it lista p n tam)
      (if (< n tam)
          (cond [(equal? (list-ref lista n) p) #f]
                [#t (bus-visi-it lista p (+ n 1) tam)])
          #t
          )
      )
    (bus-visi-it lista p 0 (length lista))
    )
  
  ;funçao principal para gerar o grupo
  (define (group-part same visitado p value)
    (if (and (< (position-col p) (length same)) (> (position-col p) -1) (< (position-lin p) (length (list-ref same (position-col p)))) (> (position-lin p) -1) (busca-visi visitado p))
        (if (equal? (mat-pos-val same p) value)
            (let
                ([visi (append visitado (list p))])
              (append (list p) 
                    (group-part same visi (position (position-lin p) (- (position-col p) 1)) value) ;esquerda
                    (group-part same visi (position (+ (position-lin p) 1) (position-col p)) value) ;cima
                    (group-part same visi (position (position-lin p) (+ (position-col p) 1)) value) ;direita
                    (group-part same visi (position (- (position-lin p) 1) (position-col p)) value) ;baixo
                    ))
            null)
        null
        )
   )
  (group-part same '() p (mat-pos-val same p))
  )

;---------------------------------------



; Esta função recebe como parâmetro um jogo same e um grupo (lista de posições)
; e cria um novo jogo removendo as posições no grupo.
(define (same-remove-group same group)
  
  
  ;funçao para saber se uma posição esta no gruo das que serão removidas
  (define (in-group lista p)
    (define (busca-group-it lista p n tam)
      (if (< n tam)
          (cond [(equal? (list-ref lista n) p) #f]
                [#t (busca-group-it lista p (+ n 1) tam)])
          #t
          )
      )
    (busca-group-it lista p 0 (length lista))
    )
  
  ;gerar outro jogo (same) agora com os valores removidos
  (define (remove-col same group)
    (define matrix '())
    (for/list ([i (in-range (length same))] #:when(not (empty? (remove-lin same group i))))
      (remove-lin same group i)
      )
    )
  
  (define (remove-lin same group col)
    (for/list ([j (in-range (length(list-ref same col)))] #:when(in-group group (position j col)))
      (list-ref (list-ref same col) j)
      )
    )
  
  (remove-col same group)
  )

; Esta é a função principal. Ela é chamada pelo arquivo resame-main.rkt que
; passa como parâmetro o nome do arquivo do jogo.  Esta função deve ler o jogo
; do arquivo, resolver e imprimir a resolução.
(define (main file)
  (define same (generate-matrix file))
  (define col (length same))
  (define lin (length (list-ref same 1)))
  (define solution (same-solve same))
  (define (solve same solution ini fim lin col)
    (cond [(< ini fim)
           (printf "~a ~s\n\n" (position-lin (list-ref solution ini)) (position-col (list-ref solution ini)))
           (define group (same-create-group same (list-ref solution ini)))
           (define new-same (same-remove-group same group))
           (write-matrix (matrix-transpose (put-zero  new-same lin col)))
           (printf "\n")
           (solve new-same solution (+ ini 1) fim lin col)
           ]
          )
    )
  (if (list? solution)
      (solve same solution 0 (length solution) lin col)
      (printf "sem-solucao\n")
      )
  )

;; struct postion
(struct position (lin col) #:transparent)




;; Algumas funções que você pode achar útil

;cria uma lista de strings separadas por espaç
(define (string-split s)
  (regexp-split #px"\\s+" s))

;Não sei pra que server ;p
(define (read-matrix port)
  (reverse
   (for/list ([line (in-lines port)])
     (string-split line))))

;printa uma matriz como uma matriz...
(define (write-matrix matrix)
  (for ([line (reverse matrix)])
    (printf "~a\n" (string-join line " "))))

;rotaciona a matriz
(define (matrix-transpose lst)
  (if (or (empty? lst) (empty? (first lst)))
      empty
      (cons (map first lst)
            (matrix-transpose (map rest lst)))))

(define (put-zero matrix lin col)
  (define max-col (length matrix))
  (for/list ([i (in-range col)])
    (define max-lin (cond [(> max-col i) (length (list-ref matrix i))]
        [else 0]))    
    (for/list ([j (in-range lin)])
      (if (and (< j max-lin) (< i max-col))
          (list-ref (list-ref matrix i) j)
          "0")
      )
    )
  )





;;testes
;(define same (generate-matrix "3-3-3"))
;(define p (position 1 0))
;(define group (same-create-group same p))
;(same-remove-group same group)
;(main "3-3-3")