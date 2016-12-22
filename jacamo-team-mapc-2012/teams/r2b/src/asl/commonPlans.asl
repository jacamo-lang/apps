/* Begin CArtAgO initialization */
//!startCArtAgOEnvironment.
+!startCArtAgOEnvironment: 
	true
<- 
	.print("Loading environment");
	!setupTool(GraphArtifact);
	focus(GraphArtifact);
	+artifact(graph, GraphArtifact);
	.print("Loaded environment").
	
+!setupTool(C): true
	<- 
		makeArtifact("graph", "artifacts.Graph", [], C).

-!setupTool(C): true
	<-
		lookupArtifact("graph", C).
/* End CArtAgO initialization */

+simStart
<-
	.print("Contest started!").
	
+vertices(V):
	true
<-
	.print("Max vertices is ", V);
	ia.setMaxVertices(V).
	
+edges(E):
	true
<-
	.print("Max edges is ", E);
	ia.setMaxEdges(E).
   
+simEnd:
	myNameInContest(MyName)
<- 
	.abolish(_); // clean all BB
	.drop_all_desires;
	ia.resetGraph;
	+myNameInContest(MyName).

+!init_goal(G): 
	money(M) & step(S) & position(V) & energy(E) & maxEnergy(Max) & lastActionResult(Result) & score(Score) & health(Health) & lastAction(LastAction)
<- 
	.print("I am at ",V," (",E,"/",Max,"), my health is ", Health, " the goal for step ",S," is ",G, " and I have ", M, " of money. My last result was ", Result, ". My last action was ", LastAction, ". The score is ", Score);
	!G.
	
+!init_goal(G): 
	step(S) & position(V) & energy(E) & maxEnergy(Max)
<- 
	.print("Something wrong... I'going try to don't lose the step. I'm at ",V," (",E,"/",Max,"). My action for step ",S," is ", G);
	!G.
      
+!init_goal(_)
<- 
	.print("No step yet... wait a bit");
    .wait(500);
	!select_goal.
	
+!survey:
	true
<- 
	.print("Surveying");
	!do(survey).

+!recharge: 
	energy(MyE)
<- 
	.print("My energy is ",MyE,", recharging");
    !do(recharge).

/* GOTO disabled state */
+!goto(Op):
	is_disabled & maxEnergy(MaxE) & position(MyV) & ia.edge(MyV, Op, W) & maxWeight(W) & W > MaxE //I have to buy more batteries and I don't have enough money
<-
	.print("I'm disabled. My max energy is ", MaxE, " but I need ", 10, " and I don't have money");
	!recharge. //TODO I have to choose an alternative: In order to don't lose a step, I choose recharge 
	
+!goto(Op):
	is_disabled & energy(MyE) & position(MyV) & ia.edge(MyV, Op, W) & maxWeight(W) & W > MyE //That's too expensive
<-
	.print("I'm disabled. My current energy is ", MyE, " but I need ", W);
	!recharge. //firstly, I'm going to recharge.
	
+!goto(Op):
	is_disabled & position(MyV) & ia.edge(MyV, Op, W) & maxWeight(W) //I can go!
<-
	.print("I'm disabled. My current vertex is ", MyV, " and I'm going to' ", Op);
	!do(goto(Op)).

/* GOTO enabled state */    
+!goto(Op):
	maxEnergy(MaxE) & position(MyV) & ia.edge(MyV, Op, W) & W > MaxE //I have to buy more batteries 
	&  
	money(MyM) & costBattery(CostBattery) & MyM >= CostBattery //And I have money to buy one
<-
	.print("I'm enabled. My max energy is ", MaxE, " but I need ", W);
	!do(buy(battery)). //firstly, I'm going to buy a new battery.
	
+!goto(Op):
	maxEnergy(MaxE) & position(MyV) & ia.edge(MyV, Op, W) & W > MaxE //I have to buy more batteries and I don't have enough money
<-
	.print("I'm enabled. My max energy is ", MaxE, " but I need ", W, " and I don't have money");
	!recharge. //TODO I have to choose an alternative: In order to don't lose a step, I choose recharge 
	
+!goto(Op):
	energy(MyE) & position(MyV) & ia.edge(MyV, Op, W) & W > MyE //That's too expensive
<-
	.print("I'm enabled. My current energy is ", MyE, " but I need ", W);
	!recharge. //firstly, I'm going to recharge.
	
+!goto(Op):
	position(MyV) //I can go!
<-
	.print("I'm enabled. My current vertex is ", MyV, " and I'm going to' ", Op);
	!do(goto(Op)).
	
+!skip:
	true
<- 
   .print("Nothing to do");
   !do(skip).
   
+!wait_next_step(S)  : step(S+1).
+!wait_next_step(S) <- .wait( { +step(_) }, 500, _); !wait_next_step(S).
   
//###### Percepts ######
+step(S): //TESTE
	S < 2 & position(V)
<- 
	.print("Current step is ", S);
	//skip.
	+firstPosition(V);
	!select_goal.
 
/* Percept a new step */
+step(S):
	true 
<- 
	.print("Current step is ", S);
	//skip.
	//!shortestPath;
	!select_goal.
	
+!shortestPath:
	position(S) & firstPosition(D) & step(14) & myNameInContest(b3)
<-
	ia.shortestPath(S, vertex340, Path);
	.print("&&&&&&&&&&&&&&&&&&&&&&Printedddddddd: ", Path).
+!shortestPath: true <- true.
-!shortestPath: 
	true 
<- 
	.print("&&&&&&&&&&&&&&& Problema ").
	
/* Percepts Position */
@position1[atomic]	
+position(V):
	currentPosition(VOld) & step(S)
<-
	!broadcastVisit(V, S);
	ia.setVertexVisited(V, S);
	-myVisitedVertex(V, _);
	+myVisitedVertex(V, S);
	//-lastPosition(_);
	//+lastPosition(VOld);
	-+lastPosition(VOld);
	//-currentPosition(_);
	//+currentPosition(V).
	-+currentPosition(V).
	
@position2[atomic]	
+position(V):
	not (lastPosition(_) | currentPosition(_)) & step(S)
<-
	!broadcastVisit(V, S);
	ia.setVertexVisited(V, S);
	-myVisitedVertex(V, _);
	+myVisitedVertex(V, S);
	+lastPosition(V);
	+currentPosition(V).
	
+!broadcastVisit(V, S):
	not ia.visitedVertex(V, S)
<-
	.broadcast(tell,visitedVertex(V, S)).
+!broadcastVisit(V, S): true <- true.
	
/* Percepts Entity */
@visibleEntity1[atomic]
+visibleEntity(Entity, V, Team, Status):
	myNameInContest(Entity) & not myTeam(_)
<-
	+myTeam(Team).
	
@visibleEntity2[atomic]
+visibleEntity(Entity, V, Team, Status):
	true
<-
	-entity(Entity, Team, _, _);
	+entity(Entity, Team, V, Status).

//Initialize the beliefs every time when the agent enter in the environment
@myName1[atomic]
+myNameInContest(MyName):
	true
<-
	+infinite(10000);
	+maxWeight(10);
	
	+costBattery(100);
	+costShield(100);
	+costSabotageDevice(100);
	+costSensor(100);
	
	+minEnergy(2); //2 is the safe minimum to allow the agent to execute actions
	+myNameInContest(MyName);
	!init;
	!loadAgentNames.
	
+!loadAgentNames: 
	true
<-
   +friend(explorer1, b1, explorer);
   +friend(explorer2, b2, explorer);
   +friend(repairer1, b3, repairer);
   +friend(repairer2, b4, repairer);
   +friend(saboteur1, b5, saboteur);
   +friend(saboteur2, b6, saboteur);
   +friend(sentinel1, b7, sentinel);
   +friend(sentinel2, b8, sentinel);
   +friend(inspector1, b9, inspector);
   +friend(inspector2, b10, inspector);
   +friend(explorer3, b11, explorer);
   +friend(explorer4, b12, explorer);
   +friend(repairer3, b13, repairer);
   +friend(repairer4, b14, repairer);
   +friend(saboteur3, b15, saboteur);
   +friend(saboteur4, b16, saboteur);
   +friend(sentinel3, b17, sentinel);
   +friend(sentinel4, b18, sentinel);
   +friend(inspector3, b19, inspector);
   +friend(inspector4, b20, inspector).