Nesse time foram implementadas as seguintes funcionalidades:
1) Exploração
#1 Exploradores se coordenam através de prioridades para não darem probed no mesmo vértice e também para não escolherem o mesmo destino.
PS: Existe exceção quando o explorador precisa voltar ao vértice anterior para localizar um destino melhor. Neste caso ambos escolhem o destino diferente, porém o vértice de retorno é o mesmo. Isso ocorre devido ao busca em profundidade que foi feito. Isso ocorre no final quando estão já estão na zona boa.
#2 Os demais agentes apenas compartilham vértices visitados a fim de não repetirem um mesmo vértice. Repetem somente quando não tem outra possibilidade em aberto. A escolha do melhor vértice se baseia no fato de ter ou não inimigo, se foi ou não já visitado...
#3 As prioridades dos exploradores também funcionam já com timeout, pois haviam casos em que um explorador demorava para decidir e o outro perdia o step.

2) Implementado algoritmo de dijkstra para caminhos mínimos. Ainda não é usado em nenhuma parte do jogo. Também implementado as estruturas básicas do grafo. Apenas tem um teste simples no step 13. Os agentes constroem o grafo adicionando os vértices e arestas.

3) Compartilhamento de informações
#1 Compartilhado os vértices probed com broadcast entre todos os agentes. Penso que isso pode servir como pistas aos demais agentes quando estes não sabem como chegar em determinado local.
#2 Compartilhado os agentes inspecionados entre todos os agentes. Isso é útil para que os agentes decidam se podem ou não arriscar visitar um vértice com determinado inimigo.
#3 Compartilhado vértices visitados. Isso ajuda os agentes a saberem se outro agente já passou por alí antes.
#4 Arestas do grafo NÃO são compartilhadas.

4) Demarcado exatamente onde está a zona boa. A idéia que usei para saber se a zona é ótima é parecida com o algoritmo de Goodman (explico melhor na reunião).

5) Definido um comportamento básico para agentes que estão desabilitados.
Isso ainda não existia no R2. Agora os agentes executam apenas ações que eles podem executar quando desabilitados.
Também se houver um reparador próximo a ele (num vértice adjacente) ele fica parado para ser atendido. Em caso de serem dois reparadores é testado um esquema de prioridade também, para saber qual reparador espera pelo outro. Em caso de um dos reparadores estar "enabled", este vai até o outro reparador.

6) Tratado quando vários agentes estão no mesmo vértice e tem um sabotador inimigo. Neste caso os agentes que possuem parry resolver com uma probabilidade se vão sair do vértice ou dar parry. A probabilidade é calculada da seguinte forma: P = 1 / N, onde N é o número de agentes nossos no vértice.

7) Também tratado prioridade nos inspetores. Não tratei nos demais agentes, talvez é questão de discutir.

type
    > ant
to run the team

