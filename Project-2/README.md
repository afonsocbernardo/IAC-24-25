# ========================================
# Identificacao do grupo:  A50

1.	113749, Manuel Raquel 
2. 	113820, Afonso Bernardo
3. 	114047, Pedro Carrola
# ========================================
# Descricao da ISA Implementada
#
# == Formato das Instrucoes ==
8 bits por instrução:

addi,subi: bit7=0(opcode), bits6-5 = opcode, bits4–0 = imediato unsigned

abs,relu: bit7=0(opcode), bits6-5 = opcode, bits 4-0 = irrelevante
li: bit7=1(opcode), bits6-0 = imediato 

# Justificar decisões: 

Por ser possivel efetuar tanto adicoes como subtracoes, consideramos despropositado que o imediato
em qualquer uma das situacoes fosse negativo deste modo poupamos um bit que servirá para representar valores maiores

# == Sumario dos Estagios do Pipeline==
## Descrever brevemente cada estagio (componentes de hardware utilizados)

apesar de nao estarem divididos por registos, ja que achamos que o circuito tem um caminho critico muito
curto e portanto nao seria necessario faze lo, o nosso circuito tem 4 estagios:
 IF: PC e seu incrementador, ROM; ID: os dois Splitters, MUX1, MUX2; EX: Registo, Extensores de bits, Somador, Subtrator, MUX3, MUX4; WB: Registo

# == Sinais de Controlo ==
## Explicar o que cada sinal ativa/desativa/seleciona e como sao gerados.

De cima para baixo:

Mux1: bits 6-5 das intrucoes indicam ao mux qual das operacoes addi,subi,abs e relu foi requisitada

Mux2: bit 7 das instrucoes indicam ao mux qual das operacoes foi requisitada alguma das anteriores ou li

Mux3: usado na funcao abs indica se o valor do registo é negativo ou positivo, é o bit mais significativo do mesmo

Mux4: usado na funcao relu indica se o valor do registo é negativo ou positivo, é o bit mais significativo do mesmo

# ========================================
# Requisitos do enunciado que *nao* estao corretamente implementados: (indicar um por linha, ou responder "nenhum")

nenhum

# ========================================
# Top-3 das otimizacoes que a vossa solucao incorpora: (maximo 140 caracteres por cada otimizacao)

1. Na funcao li, ao usarmos apenas um digito como opcode, temos disponiveis 7 bits para representar o imediato pretendido

2. Por considerarmos despropositado que o imediato fosse negativo no addi e no subi poupamos um bit que servirá para representar valores maiores

3. Fizemos o pipeline de forma a que os caminhos estivessem o mais equilibrados possivel em termos de numero de operacoes

# ========================================
