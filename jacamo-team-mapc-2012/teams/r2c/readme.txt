Nesse time foram implementadas as seguintes funcionalidades:
1) Estratégia simples de reparação, onde reparador vai atrás do ferido.
- Reparadores podem trocar de feridos para atender
- Feridos podem desmarcar com o reparador
- Feridos na fila podem pedir novo atendimento mais tarde
- Usado Dijkstra para calcular menor caminho (em termos de energia) entre o reparador e o ferido
- Decidido que atende o reparador mais próximo disponível
2) Modificado forma de percepção dos steps para que não haja mais perdas
3) Alterado os limites de vértices e arestas
4) Deixado o inspector1 como gerente de compras, agentes que precisam comprar algo pedem permissao para ele
5) Criada uma intenção inicial para checar se um agente esta parado no mesmo lugar a muito tempo (talvez o time inimigo possa manter nossos agentes parados)... A ideia dessa intenção é usar ela pra fazer o agente sair daquele lugar (random).

type
    > ant
to run the team

