Nesse time foram implementadas as seguintes funcionalidades:
1) Ele é baseado no R2g.
2) Criado uma área em que os agentes podem andar quando estão na região boa. Essa área é formada por duas áreas. Uma borda, e uma área mais interior, onde a preferência é andar pela borda, enquanto que em outros casos pode-se andar pela área interior. Há exceções como o reparador e o sabotador. Essa área é calculada fazendo para cada vértice, somado os valores de todos os vizinhos até certa distância. Como critério desempate é escolhido um vértice de maior valor individual.
3) Permitido que outros agentes possam pedir ajuda para os exploradores para indicar um caminho para chegar na área boa, desde que no começo das partidas eles não sabem onde fica a área boa.


type
    > ant
to run the team

