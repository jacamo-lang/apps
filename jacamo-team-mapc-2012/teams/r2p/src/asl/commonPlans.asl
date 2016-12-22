/* Begin CArtAgO initialization */

/*
 * Pode mandar uma lista de lugares bons... com os vertices
 * Talvez dividir em dois times de 10, os soldados 3 e 4 ficam num time e 1 e 2 no outro.
 * O reparador pode andar de um morrinho para outro
 */

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
	
+simStart:
	true
<-
	.print("Contest started!").
	
+vertices(V)[source(angel)]:
	true
<-
	.print("Max vertices is ", V);
	ia.setMaxVertices(V).
	
+vertices(V):
	true
<-
	.print("Received max vertices is ", V);
	.send(angel, achieve, tellVertices(V)).
	
+edges(E)[source(angel)]:
	true
<-
	.print("Max edges is ", E);
	ia.setMaxEdges(E).
	
+edges(E):
	true
<-
	.print("Received max edges is ", E);
	.send(angel, achieve, tellEdges(E)).
	
+steps(S):
	true
<-
	.print("Max steps is ", S).
   
@simEndP[atomic]
+simEnd:
	not finishedOK
<-
	!finishSimulation;
	+finishedOK.
	
+!finishSimulation:
	myNameInContest(MyName)
<-
	.print("Contest finished!"); 
	!resetSystem;
	+myNameInContest(MyName).
	
+!finishSimulation:
	true
<-
	.print("Contest finished, and I do not know my name!");
	.send(angel, achieve, tellMyName).

@resetSystem1[atomic]
+!resetSystem:
	true
<-
	.abolish(_); // clean all BB
	.drop_all_intentions;
	.drop_all_desires;
	ia.resetGraph.

+!init_goal(G): 
	money(M) & step(S) & position(V) & energy(E) & maxEnergy(Max) & lastActionResult(Result) & score(Score) & health(Health) & lastAction(LastAction) & lastStepScore(LastScore) & zonesScore(ZoneScore)
<- 
	.print("I am at ",V," (",E,"/",Max,"), my health is ", Health, " the goal for step ",S," is ",G, " and I have ", M, " of money. My last result was ", Result, ". My last action was ", LastAction, ". The score is ", Score, " and my last score was ", LastScore, " with zones ", ZoneScore);
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
    
+!recharge: 
	true
<- 
	.print("My energy is (I don't know), recharging");
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
	
+!goto(Op):
	true
<-
	.print("I think I lost a step").
	
+!tryAskBuy:
	money(M)
<-
	.print("I am going to ask to buy something! My money is ",M);
	+askedBuy;
	.send(inspector1, achieve, conceivePermissionToBuy);
	!select_goal.
	
+!skip:
	true
<- 
   .print("Nothing to do");
   !do(skip).
   
+!wait_next_step(S)  : step(S+1).
+!wait_next_step(S) <- .wait( { +step(_) }, 500, _); !wait_next_step(S).
   
/* Walk to be repaired */
+!repair_walk: 
	gotoVertexRepair(D, RepairerName, []) & .my_name(MyName)
<- 
	.send(RepairerName, achieve, notifyRepairerFree);
	-gotoVertexRepair(_,_,_);
	.print("I'm at the combined place, so I'm going to cancel my appointment.");
	-+hit(S).
	
+!repair_walk: 
	gotoVertexRepair(D, RepairerName, [H|T]) & position(H)
<- 
	-gotoVertexRepair(_, _, _);
	+gotoVertexRepair(D, RepairerName, T);
	!repair_walk.
    
+!repair_walk: 
	gotoVertexRepair(D, RepairerName, [H|T]) & position(MyV) & ia.edge(MyV,H,_)
<- 
	.print("I'm going to be cured by the agent ", RepairerName, " at ",H);
	!goto(H).
	
+!repair_walk: 
	gotoVertexRepair(D, RepairerName, [H|T]) & position(MyV) & not ia.edge(MyV,H,_) & .my_name(repairer1)
<- 	
	.print("Ops! REPAIR Wrong way to ",H, ". I'm going to select other goal to do.");
	
	+hit(S);
	.abolish(hit(repairer1, _));
	+hit(repairer1, Pos);
	
	.abolish(pathProposal(repairer1, _, _, _));
	.abolish(closest(_, repairer1, _));
	+closest(none, repairer1, INF);
	
	.send(RepairerName, achieve, notifyRepairerFree);
	-gotoVertexRepair(_,_,_);
	
	!searchRepairerToHelp(repairer1, Pos).
	
+!repair_walk: 
	gotoVertexRepair(D, RepairerName, [H|T]) & position(MyV) & not ia.edge(MyV,H,_) & .my_name(MyName)
<- 
	.print("Ops! REPAIR Wrong way to ",H, ". I'm going to select other goal to do.");
	
	.send(RepairerName, achieve, notifyRepairerFree);
	-gotoVertexRepair(_,_,_);
	-+hit(S);
	.send(repairer1, tell, hit(MyName, MyV));
	
	!select_goal.

+!repair_walk: 
	not gotoVertexRepair(_, RepairerName, _)
<- 
	.print("Ops! REPAIR Cancel my appointment. Very wrong way to ",H, ". I'm going to select other goal to do.");
	
	!select_goal.
	
+!newPositionRepairedGoal(V): 
	gotoVertexRepair(D, RepairerName, [V|[]])
<- 
	.print("REPAIR I arrived at ", V).
	
+!newPositionRepairedGoal(V):
	gotoVertexRepair(D, RepairerName, [V|T]) 
<- 
	-gotoVertexRepair(_, _, _);
	+gotoVertexRepair(D, RepairerName, T);
	.print("REPAIR I'm at ", V, ". My travel is: ", T).

+!newPositionRepairedGoal(V): true <- true.

+!reviewMyPositionRepaired([V|[]]): true <- true.
+!reviewMyPositionRepaired([V|T]):
	position(V) & gotoVertexRepair(D, RepairerName, _) 
<-
	-gotoVertexRepair(_, _, _);
	+gotoVertexRepair(D, RepairerName, T).
+!reviewMyPositionRepaired([V|T]):
	position(MyV) 
<-
	!reviewMyPositionRepaired(T).
+!reviewMyPositionRepaired:
	gotoVertexRepair(_, _, Route)
<-
	!reviewMyPositionRepaired(Route).
/* End walk repair */
   
//###### Percepts ######
/* Percept a new step */
+step(S):
	lastStep(LastS) 
<- 
	.abolish(finishedOK);
	.print("Current step is ", S, " last was ", LastS);
	!calculateTotalSumVertices;
	!recoverySystem(S, LastS);
	.abolish(lastStep(_));
	+lastStep(S);
	!newStepPreAction(S);
	.abolish(askedBuy); //I don't asked to buy in this step
	!select_goal;
	!newStepPosAction(S);
	!!newStepPosActionParalel(S).
	
/* Percept a new step */
+step(S):
	true 
<- 
	.abolish(finishedOK);
	.print("Current step is ", S);
	!calculateTotalSumVertices;
	+lastStep(S);
	!newStepPreAction(S);
	.abolish(askedBuy); //I don't asked to buy in this step
	!select_goal;
	!newStepPosAction(S);
	!!newStepPosActionParalel(S).
	
+!heartbeat:
	position(Pos) & not stepsSamePosition(Pos, _) & step(S)
<-
	.abolish(stepsSamePosition(_, _));
	+stepsSamePosition(Pos, S).
+!heartbeat: true <- true.
	
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
	-+currentPosition(V);
	!newPosition(V).
	
@position2[atomic]	
+position(V):
	not (lastPosition(_) | currentPosition(_)) & step(S)
<-
	!broadcastVisit(V, S);
	ia.setVertexVisited(V, S);
	-myVisitedVertex(V, _);
	+myVisitedVertex(V, S);
	+lastPosition(V);
	+currentPosition(V);
	!newPosition(V).
	
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
	
+health(0):
	is_wait_repair_goal(_)
<-
	true.	

+health(0):
	.my_name(repairer1) & position(Pos) & step(S) & not hit(_) & infinite(INF)
<-
	+hit(S);
	.abolish(hit(repairer1, _));
	+hit(repairer1, Pos);
	
	.print("repairer1 was hit at ", Pos);
	.abolish(pathProposal(repairer1, _, _, _));
	.abolish(closest(_, repairer1, _));
	+closest(none, repairer1, INF);
	
	!searchRepairerToHelp(repairer1, Pos).
	
+health(0):
	.my_name(MyName) & position(Pos) & step(S) & not hit(_)
<-
	+hit(S);
	.send(repairer1, tell, hit(MyName, Pos)).

@health2[atomic]
+health(MyH):
	MyH > 0 & hit(_) & gotoVertexRepair(_, RepairerName,_)
<-
	.print("I'm cured! Notifying my repairer... ", RepairerName);
	.send(repairer1, tell, iWasRepaired);
	.send(RepairerName, achieve, notifyRepairerFree);
	.abolish(gotoVertexRepair(_,_,_));
	.abolish(hit(_));
	.abolish(waitABit);
	!evaluateMaxHealth(MyH).
	
@health3[atomic]
+health(MyH):
	MyH > 0 & hit(_)
<-
	.print("I'm cured!");
	.send(repairer1, tell, iWasRepaired);
	.abolish(gotoVertexRepair(_,_,_));
	.abolish(hit(_));
	.abolish(waitABit);
	!evaluateMaxHealth(MyH).
	
@health4[atomic]
+health(MyH):
	MyH > 0 & waitABit
<-
	.print("I'm cured!");
	.send(repairer1, tell, iWasRepaired);
	.abolish(gotoVertexRepair(_,_,_));
	.abolish(hit(_));
	.abolish(waitABit);
	!evaluateMaxHealth(MyH).
	
+!evaluateMaxHealth(MyH):
	not myMaxHealth(_)
<-
	+myMaxHealth(MyH).
	
+!evaluateMaxHealth(MyH):
	myMaxHealth(MyMaxH) & MyH > MyMaxH
<-
	-+myMaxHealth(MyH).
+!evaluateMaxHealth(MyH): true <- true.
	
+!testIHaveAppointmentButImCured:
	gotoVertexRepair(_,RepairerName,_) & health(MyH) & MyH > 0
<-
	.print("I'm cured! Notifying my repairer... ", RepairerName);
	.send(repairer1, tell, iWasRepaired);
	.send(RepairerName, achieve, notifyRepairerFree);
	-gotoVertexRepair(_,_,_);
	-hit(_).
+!testIHaveAppointmentButImCured: true <- true.
	
+!cancelAppointment:
	hit(_) & gotoVertexRepair(_, RepairerName,_)
<-
	.print("My repairer cancel the appointment... ", RepairerName);
	-gotoVertexRepair(_,_,_).
	
+!cancelAppointment:
	hit(_)
<-
	.print("My repairer cancel the appointment... ");
	-gotoVertexRepair(_,_,_).
	
+!cancelAppointment:
	health(0) & step(S) & not hit(_)
<-
	.print("My repairer cancel the appointment... ");
	+hit(S);
	-gotoVertexRepair(_,_,_).
	
+!cancelAppointment:
	true
<-
	.print("My repairer cancel the appointment... No problem.");
	-gotoVertexRepair(_,_,_).

+!gotoRepaired(D, Path)[source(RepairerName)]:
	health(MyH) & MyH > 0
<-
	.print("I'm cured before appointment! Notifying my repairer... ", RepairerName);
	.send(repairer1, tell, iWasRepaired);
	.send(RepairerName, achieve, notifyRepairerFree);
	.abolish(gotoVertexRepair(_,_,_));
	.abolish(hit(_));
	.abolish(waitABit).

+!gotoRepaired(D, Path)[source(RepairerName)]:
	currentPosition(MyV)
<-
	+gotoVertexRepair(D, RepairerName, Path);
	.print("I'm at ", MyV , " have to go to ", D).
	
+!achieveDestinationRepair: 
	gotoVertexRepair(_, _, [D|_]) & position(MyV)
<- 
	.print("I'm going to ",D, " to be repaired, because I'm at ", MyV);
	!goto(D).	
+!achieveDestinationRepair: true <- !select_goal.
	
+!waitRepair(V):
	position(V) & there_is_enemy_at(V)
<- 
	!init_goal(recharge).
	
+!waitRepair(V):
	position(MyV) & there_is_enemy_at(MyV)
<- 
	!goto(V).

+!waitRepair(V):
	true
<- 
	!init_goal(recharge).
	
+!newStepPreAction(S):
	waitingSince(SWait) & S - SWait >= 3
<-
	.abolish(waitABit);
	-waitingSince(_);
	!newStepPreAction(S).
	
+!newStepPreAction(S):
	health(0) & hit(StepHit) & not .number(StepHit)
<-
	.print("StepHit is not a number and I'm disabled.");
	.abolish(hit(_));
	+hit(S);
	!newStepPreAction(S).
	
+!newStepPreAction(S):
	hit(StepHit) & not .number(StepHit)
<-
	.print("StepHit is not a number and I'm not disabled.");
	.abolish(hit(_));
	!newStepPreAction(S).

+!newStepPreAction(S):
	.random(X) & hit(StepHit) & S - StepHit >= (X * 6) + 3 & not gotoVertexRepair(_,_,_) & .my_name(repairer1) & position(Pos) & infinite(INF)
<-
	.print("I'm waiting too much. I will try to notify the repairers again.");
	
	+hit(S);
	.abolish(hit(repairer1, _));
	+hit(repairer1, Pos);
	
	.abolish(pathProposal(repairer1, _, _, _));
	.abolish(closest(_, repairer1, _));
	+closest(none, repairer1, INF);
	
	!searchRepairerToHelp(repairer1, Pos).
	
+!newStepPreAction(S):
	.random(X) & hit(StepHit) & S - StepHit >= (X * 6) + 3 & not gotoVertexRepair(_,_,_) & .my_name(MyName) & position(Pos)
<-
	.print("I'm waiting too much. I will try to notify the repairers again.");
	-+hit(S);
	.send(repairer1, tell, hit(MyName, Pos)).
	
+!newStepPreAction(S):
	hit(StepHit) & S - StepHit >= 13 & gotoVertexRepair(_,RepairerName,_) & .my_name(repairer1) & position(Pos) & infinite(INF)
<-
	.print("I'm waiting too much. I will try to notify the repairers again.");
	
	+hit(S);
	.abolish(hit(repairer1, _));
	+hit(repairer1, Pos);
	
	.abolish(pathProposal(repairer1, _, _, _));
	.abolish(closest(_, repairer1, _));
	+closest(none, repairer1, INF);
	
	.send(RepairerName, achieve, notifyRepairerFree);
	-gotoVertexRepair(_,_,_);
	
	!searchRepairerToHelp(repairer1, Pos).
	
+!newStepPreAction(S):
	hit(StepHit) & S - StepHit >= 13 & gotoVertexRepair(_,RepairerName,_) & .my_name(MyName) & position(Pos)
<-
	.send(RepairerName, achieve, notifyRepairerFree);
	-gotoVertexRepair(_,_,_);
	.print("I'm waiting too much. I will try to notify the repairers again.");
	-+hit(S);
	.send(repairer1, tell, hit(MyName, Pos)).

+!newStepPreAction(S):
	true
<-
	!testIHaveAppointmentButImCured.
	
//Initialize the beliefs every time when the agent enter in the environment
@myName1[atomic]
+myNameInContest(MyName):
	not infinite(_)
<-
	.print("Recebi");
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
	
+!recoverySystem(S, LastS):
	myNameInContest(MyName) & S < LastS
<- 
	.print("Recovery system started!");
	!resetSystem;
	+myNameInContest(MyName).
	
+!recoverySystem(S, LastS):
	S < LastS
<- 
	.print("Recovery system started without my name!");
	!resetSystem;
	.send(angel, achieve, tellMyName).

+!recoverySystem(S, LastS):
	not myNameInContest(MyName)
<- 
	.print("Recovery system started without my name two!");
	!resetSystem;
	.send(angel, achieve, tellMyName).
	
+!recoverySystem(S, LastS):
	true
<- 
	true.
	
{ include("loadAgents.asl") }
   
+waitABit:
	not waitingSince(_) & step(S)
<-
	+waitingSince(S).

+!calculeShortestPath(S, D, PathX, LenghtX):
	true
<-
	ia.shortestPath(S, D, Path, Lenght);
	PathX = Path;
	LenghtX = Lenght;
	.print("The shortest path between ", S, " and ", D, " is ", PathX, " with lenght ", Lenght).
	
/* SWARM */
+swarmMode:
	true
<-
	.print("SWARM: swarm mode on").
	
+!gotoSwarmPlace:
	bestCoverageSwarm(V, Value, List) & currentPosition(S) //& list_vertex_by_value(Value, List)
<-
	.print("SWARM: Going to some best vertex! ", List);
	ia.shortestPathDijkstraComplete(S, List, D, Path, Lenght);
	.print("SWARM: Best vertex to go is ", S, " -> ", D, " with path: ", Path, " and lenght: ", Lenght);
	!prepareTogoSwarmPlace(Path, D).
	
-!gotoSwarmPlace:
	bestCoverageSwarm(V, Value, List) & currentPosition(S) & noMoreVertexToProbe
	& not (
			.my_name(explorer1) | .my_name(explorer2) | 
			.my_name(explorer3) | .my_name(explorer4)
		  )
<-
	.send(explorer1, achieve, calculeSomePathForMe(S, List));
	.send(explorer2, achieve, calculeSomePathForMe(S, List));
	.send(explorer3, achieve, calculeSomePathForMe(S, List));
	.send(explorer4, achieve, calculeSomePathForMe(S, List));
	.print("SWARM: I do not know any way to go to best place. Need help!").
	
-!gotoSwarmPlace:
	true
<-
	.abolish(bestCoverageSwarm(_, _, _));
	.print("SWARM: I do not know any way to go to best place. Waiting...").
	
+!prepareTogoSwarmPlace(Path, PosAim):
	.list(Path) & currentPosition(S)
<-
	.abolish(pathTogoSwarm(_,_));
	+pathTogoSwarm(PosAim, Path);
	.print("SWARM: My choose is ", Path, " from ", S, " to achieve ", PosAim).
	
+!prepareTogoSwarmPlace(Path, PosAim):
	step(S)
<-
	.print("SWARM: My choose is wait and wait");
	.wait( { +step(S+2) }, 1000, _);
	.print("SWARM: I'm going again");
	!gotoSwarmPlace.
	
+!prepareTogoSwarmPlace(Path, PosAim):
	true
<-
	.print("SWARM: My choose is wait and wait (no step)");
	.wait( { +step(_) }, 100, _);
	!prepareTogoSwarmPlace(Path, PosAim).

+!setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood):
	currentPosition(Pos) & .member(Pos,Neighborhood)
<-
	.abolish(bestVertexArea(_));
	+bestVertexArea(BestVertex);
	.print("## NEW BEST COVERAGE received, but I'm at ", Pos , " Vertex: ", BestVertex, " Value: ", BestValue, " Neighborhood: ", Neighborhood);
	!ajustAllowedDistance.
	
+!setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood):
	true
<-
	.abolish(bestCoverageSwarm(_, _, _));
	.abolish(pathTogoSwarm(_, _));
	.abolish(bestVertexArea(_));
	+bestVertexArea(BestVertex);
	.print("## NEW BEST COVERAGE received! Vertex: ", BestVertex, " Value: ", BestValue, " Neighborhood: ", Neighborhood);
	+bestCoverageSwarm(BestVertex, BestValue, Neighborhood);
	!ajustAllowedDistance;
	!gotoSwarmPlace.
	

+!ajustAllowedDistance:
	step(S) & S < 100
<-
	!setAllowedDistance(1,0).
	
+!ajustAllowedDistance:
	step(S) & S < 800
<-
	!setAllowedDistance(2,0).
	
+!ajustAllowedDistance:
	true
<-
	!setAllowedDistance(3,1).
	
+!newPositionSwarmGoal(V): 
	pathTogoSwarm(D, [V|[]])
<- 
	.print("SWARM GOING: I arrived at ", V).
	
+!newPositionSwarmGoal(V): 
	pathTogoSwarm(D, [V|T])
<- 
	-pathTogoSwarm(_, _);
	+pathTogoSwarm(D, T);
	.print("SWARM GOING: I'm at ", V, ". My travel is: ", T).
	
+!newPositionSwarmGoal(V): true <- true.

+!cancelSwarmTravel:
	true
<-
	.abolish(bestCoverageSwarm(_, _, _));
	.abolish(pathTogoSwarm(_, _)).
	
/* SWARM GOING */
+!walkSwarm: 
	pathTogoSwarm(D, [])
<- 
	.print("SWARM CURIOUS: I'm already at aim. Choosing another goal.");
	!select_goal.
	
+!walkSwarm: 
	pathTogoSwarm(D, [H|T]) & position(H)
<- 
	-pathTogoSwarm(_, _);
	+pathTogoSwarm(D, T);
	!walkSwarm.
	
+!walkSwarm: 
	pathTogoSwarm(D, [H|T]) & position(MyV) & ia.edge(MyV,H,_)
<- 
	.print("SWARM I'm going to vertex ", H);
	!goto(H).
	
+!walkSwarm: 
	pathTogoSwarm(D, [H|T]) & position(MyV) & not ia.edge(MyV,H,_)
<- 
	.print("Ops! SWARM Wrong way to ",H, ". I'm going to select other goal to do.");
	!cancelSwarmTravel;
	!select_goal.

+!walkSwarm:
	true
<-
	.print("SWARM, choosing another goal");
	!select_goal.
	
+!setAllowedDistance(DistanceOutside, DistanceInside):
	not allowedDistance(DistanceOutside,DistanceInside)
<-
	.print("New allowed distance setted to ", DistanceOutside, " and ", DistanceInside);
	-allowedDistance(_,_);
	+allowedDistance(DistanceOutside,DistanceInside).
+!setAllowedDistance(DistanceOutside, DistanceInside): true <- true.
	
+!calculeAllowedArea(DistanceOutside,DistanceInside):
	bestVertexArea(D)
<-
	//ia.neighborhood(D, Distance, Neighborhood);
	ia.walkAreaSwarm(D, DistanceOutside, DistanceInside, NeighborhoodOutside, NeighborhoodInside);
	.print("SWARM WALKING INSIDE. I can walk inside of (border) ", NeighborhoodOutside, " or inside of  ", NeighborhoodInside);
	.abolish(allowedArea(_, _));
	+allowedArea(NeighborhoodOutside, NeighborhoodInside).
+!calculeAllowedArea(DistanceOutside,DistanceInside): true <- true.
-!calculeAllowedArea(DistanceOutside,DistanceInside): 
	true 
<- 
	.print("I do not know any vertex from the best area!").
	
+!newStepPosActionParalel(S):
	allowedDistance(DistanceOutside,DistanceInside)
<-
	!ajustAllowedDistance;
	!calculeAllowedArea(DistanceOutside,DistanceInside).
+!newStepPosActionParalel(S): true <- true.
/* END SWARM GOING */

+!synchronizeGraph:
	step(S) & lastSync(Last) & S - Last > 3
<-
	.print("Synchronizing...");
	-+lastSync(S);
	ia.synchronizeGraph.
	
+!synchronizeGraph:
	not lastSync(_)
<-
	+lastSync(0).
	
+!synchronizeGraph:
	true
<-
	true.

+!calculateTotalSumVertices:
	.my_name(explorer4) & ia.sumVertices(Total)
<-
	.print("Calculating the sum of all vertices: ", Total);
	!updateTotalSumVertices(Total);
	.broadcast(achieve, updateTotalSumVertices(Total)).
+!calculateTotalSumVertices: true <- true.

@updateTotalSumVerticesP[atomic]
+!updateTotalSumVertices(Total):
	true
<-
	.abolish(sumVertices(_));
	+sumVertices(Total).