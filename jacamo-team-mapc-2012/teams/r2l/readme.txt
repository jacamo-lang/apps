Nesse time foram implementadas as seguintes funcionalidades:
1) Ele é baseado no R2i.
2) Permite que sejam usados dois morrinhos ao invés de 1. Alguns testes mostraram que dois times diferentes tinham pego dois morrinhos diferentes no mapa. Então há dois morrinhos as vezes ao invés de 1.
3) Foi necessário criar uma sincronização entre os grafos de cada agente. Agora existe também um grafo global, mas que os agentes executam uma internal action para atualizar. Isso foi necessário pois os exploradores tinham visões parciais do grafo e ocorreu de uma vez não pegarem o lugar bom, devido aquela parte do grafo estar dividida entre dois exploradores diferentes.

type
    > ant
to run the team

