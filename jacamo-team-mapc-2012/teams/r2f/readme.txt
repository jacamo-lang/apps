Nesse time foram implementadas as seguintes funcionalidades:
1) Estratégia extremamente dummy a respeito de exploitação. Basicamente agora os exploradores fazem uma avaliação da melhor área a cada 15 steps, onde cada explorador calcula a melhor área que ele conhece. Depois cada explorador envia sua proposta ao explorer1, que escolhe a melhor área dentre elas, e avisa todos os demais agentes. Então os agentes que não estão fazendo nada vão começar a se reunir na área boa do mapa...
PS: Ainda há sobreposição de agentes no mesmo vértice e vários problemas, mas essa é uma versão dummy mesmo.
2) Trabalhado um pouco na estratégia de ataque e reparação novamente, onde reparadores e sabotadores negociam ataque e reparação quando há muitos agentes no mesmo vértice, para que eles não reparassem por exemplo o mesmo alvo.
3) Criado alguns novos algoritmos de grafos e também internal actions, como o BestCoverage, Neighborhood e DijkstraAlgorithmComplete.

Algumas idéias em aberto que pretendo colocar:
1) Fazer como no Titan, quando eles estabelecem uma área de defesa. Notei que é praticamente impossível ficar dominando uma área grande sem que o inimigo ataque aos montes, então não vale apena gastar tempo criando um algoritmo perfeito de posicionamento. Então mais vai valer apena os agentes poderem ter mais liberdade, porém eles não podem sair de dentro da área boa. Ex: estipulamos que a área boa seja composto por todos os vértices da distância de 3 saltos, logo nenhum agente pode sair fora dessa área.
2) Também tentar manter menos agentes possíveis no meio da fronteira, ou seja, eles tentam ficar sempre nos vértices da fronteira como primeira opção, caso não seja possível então eles ficam dentro.
3) Notei que muitos agentes não sabem o caminho para chegar na área boa no inicio do jogo, então eles poderão pedir para os agentes exploradores, desde que os exploradores continuam a explorar o mapa, entao eles saberão o caminho mais cedo ou mais tarde.
4) Tratar sobreposição num vértice. Na verdade sabotadores atacando e reparadores podem ficar num mesmo vértice, pois separei eles uma hora para melhorar o ataque, e piorou muito!
5) Notei que os reparadores estão comprando muita saúde... hehehe, então vou tentar diminuir isso e comparar os resultados.
6) Pela nova estratégia os sabotadores acabam não comprando nada, desde que eles estão sempre ocupados batendo em alguém... então vai precisar balancear isso também. :)
7) Atualmente os sentinelas eu deixo parado na área boa, mas é porque ainda não implementei a movimentação deles.

type
    > ant
to run the team

