// Agent teste in project smadasMAPC2012

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("hello world.").

/*
+step(S):
	ia.vertex(vertex6, Team)
<-
	.print("$$$ Step ", S," Teste: ", Team).
	
+step(S):
	true
<-
	.print("$$$ XX Step ", S).
	* 
	*/
	
+visibleVertex(V, Team):
	ia.vertex(V, _)
<-
	.print("%%%%%% PERCEBO VERTEX: ", V, " ", Team, " ", Team2).
	
+visibleVertex(V, Team):
	ia.vertex(V, Team2)
<-
	.print("PERCEBO VERTEX: ", V, " ", Team, " ", Team2).
	
+position(U):
	true
<-
	for (ia.edge(U, V, Cost)) {
		//ia.edge(U, V, Cost);
		.print("()()()()()() Edge: ", U, " -> ", V, " W: ", Cost);
	};
	.count(ia.edge(U, _, _), N);
	.print("============ Total ", N);
	ia.setVertexValue(U,N);
	.broadcast(tell, probedVertex(U, N)).
	
+step(S):
	position(U) & ia.probedVertex(U,X)
<-
	for (ia.probedVertex(Y, X)) {
		.print("#IGUAL# " , Y);
	};
	.print("FOI PROBED!!!!!!!!! ",X);
	ia.setVertexVisited(U,S);
	ia.visitedVertex(U, L);
	.print("Visitei em ", L).
