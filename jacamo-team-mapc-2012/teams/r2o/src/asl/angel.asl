//TODO talvez o anjo pode dizer quando o contest terminou, o numero de vertices e arestas e quando o contest iniciou.
!start.

+!start: 
	true 
<- 
	!loadAgentNames;
	.print("Agent angel loaded.").

{ include("loadAgents.asl") }

+!tellMyName[source(AgentName)]:
	friend(AgentName, NameContest, _)
<-
	.send(AgentName, tell, myNameInContest(NameContest)).
	
+!tellMyName[source(AgentName)]:
	true
<-
	.print("Problem with agent ", AgentName).
	
+!tellVertices(V):
	true
<-
	.broadcast(tell, vertices(V)).
	
+!tellEdges(E):
	true
<-
	.broadcast(tell, edges(E)).
	
+!tellSimEnd:
	true
<-
	.broadcast(tell, simEnd).	