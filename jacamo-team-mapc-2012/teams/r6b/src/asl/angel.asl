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
	
+!tellSteps(S):
	true
<-
	.broadcast(tell, steps(S)).

+!tellSimEnd:
	true
<-
	.broadcast(tell, simEnd).
+!tellSimEnd: true <- true.		