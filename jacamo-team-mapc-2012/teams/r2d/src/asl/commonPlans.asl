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

/* 
+simStart[source(percept)]:
	not notifyFriends & vertices(V) & edges(E)
<-
	.broadcast(tell, [vertices(V), edges(E)]);
	+notifyFriends;
	.print("Contest started!").*/
	
+simStart[source(percept)]:
	true
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
	
+steps(S):
	true
<-
	.print("Max steps is ", S).
   
+simEnd:
	myNameInContest(MyName)
<- 
	.print("Contest finished!");
	.abolish(_); // clean all BB
	.drop_all_intentions;
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
	.print("I am going to ask to buy sabotageDevice! My money is ",M);
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
	gotoVertexRepair(D, RepairerName, [H|T]) & position(H)
<- 
	-gotoVertexRepair(_, _, _);
	+gotoVertexRepair(RepairerName, T);
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
	true 
<- 
	.print("Current step is ", S);
	!newStepPreAction(S);
	.abolish(askedBuy); //I don't asked to buy in this step
	!select_goal.
	
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
	.abolish(waitABit).
	
@health3[atomic]
+health(MyH):
	MyH > 0 & hit(_)
<-
	.print("I'm cured!");
	.send(repairer1, tell, iWasRepaired);
	.abolish(gotoVertexRepair(_,_,_));
	.abolish(hit(_));
	.abolish(waitABit).
	
@health4[atomic]
+health(MyH):
	MyH > 0 & waitABit
<-
	.print("I'm cured!");
	.send(repairer1, tell, iWasRepaired);
	.abolish(gotoVertexRepair(_,_,_));
	.abolish(hit(_));
	.abolish(waitABit).
	
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
	step(S) & waitingSince(SWait) & S - SWait >= 3
<-
	.abolish(waitABit);
	-waitingSince(_);
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
   
+waitABit:
	not waitingSince(_) & step(S)
<-
	+waitingSince(S).
	
/* SWARM */
+swarmMode:
	true
<-
	.print("SWARM: swarm mode on").
