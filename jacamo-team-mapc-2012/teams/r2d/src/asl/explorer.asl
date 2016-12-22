//agent explorer
{ include("commonBeliefs.asl") }

// conditions for goal selection
{ include("commonRules.asl") }
{ include("commonRules_notRepairer.asl") }

//Verify if the explorer is at an unprobed vertex, and he is the explorer with the highest priority when there are other explorers at the same vertex
is_probe_goal  :- position(MyV) & not ia.probedVertex(MyV,_) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyAgentName) &
				  not (visibleEntity(Entity, MyV, MyTeam, normal) & friend(AgentName, Entity, explorer) & Entity \== MyName & priorityEntity(AgentName, MyAgentName)).

//These 2 first consider the decision of the others explorers
/*
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V) & not nextStepExplorer(_,V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V) & not nextStepExplorer(_,V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/*
 * The only differente is that I don't care for some enemy there. I ignore enemies.
 */						   
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not nextStepExplorer(_,V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not nextStepExplorer(_,V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
				
/*
 * If there aren't options yet, so I choose to visit some already probedVertex, but I regard to:
 * - there isn't a dangerous enemy there
 * - there isn't any explorer friend going there
 * - I choose the best already probedVertex to go
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
						   .setof(Value, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,Value) & not there_is_enemy_at(V) & not nextStepExplorer(_,V), SetValues)
						   & .max(SetValues, MaxValue)
						   & .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,MaxValue), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0
						   & .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(Value, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,Value) & not there_is_enemy_at(V) & not nextStepExplorer(_,V), SetValues)
						   & .max(SetValues, MaxValue)
						   & .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,MaxValue), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0
						   & .nth(math.random(TotalOptions), Options, Op).

//These 2 consider if there's no way
/* I think this rule isn't used anymore
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & not nextStepExplorer(_,V) & not there_is_enemy_at(V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
*/
/*
 * I have no options to go, because my explorer friends choose all of them, so I choose my option regarding to:
 * - the next option is an unprobed vertex
 * - there aren't dangerous enemies there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/*
 * If I don't have options yet, so I choose the best probedVertex to go and that don't have enemy there.
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
						   .setof(Value, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,Value) & not there_is_enemy_at(V), SetValues)
						   & .max(SetValues, MaxValue)
						   & .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,MaxValue), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0
						   & .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(Value, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,Value) & not there_is_enemy_at(V), SetValues)
						   & .max(SetValues, MaxValue)
						   & .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,MaxValue), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0
						   & .nth(math.random(TotalOptions), Options, Op).

/*
 * By this time, I don't have any option to go!
 * I choose randomly
 */
is_good_destination(Op) :- position(MyV) &
						   .setof(V, ia.edge(MyV,V,_), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).						   

/*
 * This is the part of the Goodman algorithm
 * Check if there is some unprobed vertex adjacent to the all vertices with the current best found value 
 * If there isn't any unprobed adjacent vertex to these possible best vertices, so I actually found the best place of the map
 */
/*
there_is_possible_best_vertex :- bestProbedVertex(BestVertex, BestVertexValue) &
						ia.probedVertex(V,BestVertexValue) &
						(
							.count(ia.edge(V, _, _), N) & N == 0 
						|
							ia.edge(V, AdjV, _) & not ia.probedVertex(AdjV,_)
						).
*/

there_is_possible_best_vertex :- 
							(bestProbedVertex(unknown, _) | not bestProbedVertex(_, _))
						| 
							(
								bestProbedVertex(BestVertex, BestVertexValue) &
								ia.probedVertex(V,BestVertexValue) &
								(
									.count(ia.edge(V, _, _), N) & N == 0 
								|
									ia.edge(V, AdjV, _) & not ia.probedVertex(AdjV,_)
								)
							).

//These two rules aren't used correctly anymore... they must be replaced by the exploitation phase
is_stop_goal   :- position(MyV) & bestVertex(Value) & ia.probedVertex(MyV,Value).
is_full_energy_goal :- is_stop_goal & energy(MyE) & maxEnergy(Max) & MyE < Max * 0.99.


/* The sequence of the priority plans */
+!select_goal: 
	not there_is_possible_best_vertex & not swarmMode & .my_name(explorer1) 
<- 
	!setSwarmMode; 
	!select_goal.

+!select_goal:
	not numberWaits(_)
<-
	+numberWaits(0);
	!select_goal.
	
+!select_goal:
	numberWaits(K) & K >= 3
<-
	.print("I can't wait anymore!");
	//-numberWaits(_);
	//+numberWaits(0);
	-+numberWaits(0);
	//-nextStepExplorerAll(_);
	//+nextStepExplorerAll(10);
	-+nextStepExplorerAll(10);
	!select_goal.

+!select_goal:
	.my_name(explorer4) & nextStepExplorerAll(X) & X < 3 & numberWaits(K)
<-	
	.print("Waiting decision");
	//.wait({+nextStepExplorer(explorer2, V)}, 1000, EventTime);
	//.wait({+nextStepExplorerAll(3)},150);
	.wait(150);
	-+numberWaits(K+1);
	!select_goal.
	
+!select_goal:
	.my_name(explorer3) & nextStepExplorerAll(X) & X < 2 & numberWaits(K)
<-	

	.print("Waiting decision");
	//.wait({+nextStepExplorerAll(2)},150);
	.wait(150);
	-+numberWaits(K+1);
	!select_goal.
	
+!select_goal:
	.my_name(explorer2) & nextStepExplorerAll(X) & X < 1 & numberWaits(K)
<-	

	.print("Waiting decision");
	//.wait({+nextStepExplorerAll(1)},150);
	.wait(150);
	-+numberWaits(K+1);
	!select_goal.

+!select_goal : is_heartbeat_goal
	<-
	.print("I'm in the same place yet!!!!!!");
	.abolish(stepsSamePosition(_, _)); //TODO fazer alguma coisa se o agente ficar muito no mesmo lugar
	!select_goal.

+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_wait_repair_goal(V) <-
	.print("Waiting to be repaired."); 
	!init_goal(waitRepair(V)).
+!select_goal : is_next_destination_repair_vertex <- !init_goal(achieveDestinationRepair).
+!select_goal : is_route_repaired_goal <- !reviewMyPositionRepaired; !init_goal(repair_walk). //I'm going to be repaired by some agent
/*
+!select_goal : is_destination_repair_vertex(RepairerName) & step(S) <-
	.print("Waiting to be repaired ", S, ". I have an appointment with ", RepairerName); 
	!init_goal(recharge). //Instead of don't do anything, then recharge
	* 
	*/

+!select_goal : waitABit <- !init_goal(recharge).
+!select_goal : returnTo(VOld) & position(VOld) <- -returnTo(_); !select_goal.
+!select_goal : returnTo(VOld) & position(VCurrent) & not ia.edge(VCurrent, VOld, _) <- -returnTo(_); !select_goal.
	
+!select_goal : returnTo(VOld) & is_disabled <- -returnTo(_); !select_goal.
+!select_goal : no_way_to_go & is_leave_goal & not is_disabled <- !init_goal(survey).
+!select_goal : is_leave_goal & not is_disabled <- !init_goal(searchBestVertex).
+!select_goal : is_energy_goal | is_full_energy_goal <- !init_goal(recharge).
+!select_goal : returnTo(VOld) <- !init_goal(searchBestVertex).
+!select_goal : is_probe_goal & not is_disabled <- !init_goal(probe).
+!select_goal : is_survey_goal & not is_disabled & swarmMode <- !init_goal(survey).
+!select_goal : is_stop_goal   <- !init_goal(skip).
//+!select_goal : there_is_possible_best_vertex <- !init_goal(searchBestVertex). //TODO GO THERE!
+!select_goal                  <- !init_goal(searchBestVertex).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	+bestProbedVertex(unknown, 0);
	+bestVertex(11);
	+nextStepExplorerAll(0);
	
	+priorityEntity(explorer1, explorer2);
	+priorityEntity(explorer1, explorer3);
	+priorityEntity(explorer1, explorer4);
	
	+priorityEntity(explorer2, explorer3);
	+priorityEntity(explorer2, explorer4);
	
	+priorityEntity(explorer3, explorer4).
   
+!searchBestVertex: 
	returnTo(VOld)
<- 
	.print("I'm returning to ",VOld);
	!goto(VOld).
    
+!searchBestVertex: 
	is_good_destination(Op)
<- 
	.print("I have chose ",Op);
	!goto(Op).

+!searchBestVertex: 
	true
<- 
	.print("I don't know where I'm going, so I'm going to recharge");
	!recharge.
	
+!probe:
	bestVertex(Value)
<- 
   .print("Probing my location. I'm trying to find a vertex of value ", Value);
   !do(probe);
   !updateBestVertex;
   !checkBestVertex.
   
+!probe:
	true
<- 
   +bestVertex(11);
   !probe.

+!updateBestVertex:
	lastProbed(V,Value) & maxProbedVertex(VBest, ValueBest) & Value > ValueBest
<-
	//-maxProbedVertex(_, _);
	//+maxProbedVertex(V,Value).
	-+maxProbedVertex(V,Value).
	
+!updateBestVertex:
	lastProbed(V,Value) & not maxProbedVertex(_, _)
<-
	+maxProbedVertex(V,Value).
+!updateBestVertex: true <- true.

+!checkBestVertex:
	maxProbedVertex(V,Value) & bestVertex(Value)
<-
	.print("I found the best vertex here!!!!").
+!checkBestVertex: true <- true.
	
+!testingNewTargets:
	bestVertex(Value)
<-
	.print("Now I'm looking for a vertex of value ", Value).
	
+!checkBestVertex: true <- true.
 			
//Percepts
@probedVertex1[atomic]	
+probedVertex(V,Value) [source(percept)]: //my current probed vertex is less good than my last one
	lastProbed(VOld,ValueOld) & ValueOld > Value & lastPosition(VBefore)
<- 
	.print("Vertex probed: ", V, " with value ", Value, " is less good than my last one ", VOld, " with the value ", ValueOld);
	+returnTo(VBefore);
	ia.setVertexValue(V, Value);
	!broadcastProbe(V,Value);
	!evaluateProbedVertex(V, Value).
	
@probedVertex2[atomic]
+probedVertex(V,Value) [source(percept)]:
	lastProbed(VOld,ValueOld)
<- 
	.print("Vertex probed: ", V, " with value ", Value);
	-lastProbed(VOld,ValueOld);
	+lastProbed(V,Value);
	ia.setVertexValue(V, Value);
	!broadcastProbe(V,Value);
	!evaluateProbedVertex(V, Value).
	
@probedVertex3[atomic]
+probedVertex(V,Value) [source(percept)]:
	true
<- 
	.print("Vertex probed: ", V, " with value ", Value);
	+lastProbed(V,Value);
	ia.setVertexValue(V, Value);
	!broadcastProbe(V,Value);
	!evaluateProbedVertex(V, Value).
	
+probedVertex(V,Value) [source(self)]: true <- -probedVertex(V,Value).
@probedVertexBroadcast[atomic]
+probedVertex(V,Value):
	true
<- 
	ia.setVertexValue(V, Value);
	!evaluateProbedVertex(V, Value);
	-probedVertex(V,Value).
	
+!broadcastProbe(V,Value):
	true
<-
	.print("Sending probed vertex in broadcast ", V, " ", Value);
	.broadcast(tell,probedVertex(V,Value)).
+!broadcastProbe(V,Value): true <- true.

+!evaluateProbedVertex(V, Value):
	bestProbedVertex(_, BestValue) & Value > BestValue
<-
	.print("New best probed vertex found: ", V, " ", Value);
	//-bestProbedVertex(_, _);
	//+bestProbedVertex(V, Value).
	-+bestProbedVertex(V, Value).
+!evaluateProbedVertex(V, Value): true <- true.	
 
+!clearDecision:
 	true
 <-
 	.abolish(nextStepExplorerCounted(_));
 	.abolish(nextStepExplorer(_, _));
 	.abolish(nextStepExplorerAll(_));
 	.abolish(numberWaits(_));
 	+nextStepExplorerAll(0);
 	+numberWaits(0).
 	
@nextStepExplorer1[atomic] 	
 +nextStepExplorer(Ex, _):
 	not nextStepExplorerCounted(Ex) & nextStepExplorerAll(X)
 <-
 	+nextStepExplorerCounted(Ex);
 	//-nextStepExplorerAll(_);
 	//+nextStepExplorerAll(X+1).
 	-+nextStepExplorerAll(X+1).
    
@do0[atomic]
+!do(Act): 
	step(S) & stepDone(S)
<- 
	.print("ERROR! I already performed an action for this step! ", S).
 	
 // the following plans are used to send only one action each cycle
@do1[atomic]
+!do(goto(V)): 
	step(S) & .my_name(explorer1)
<- 
	.send(explorer2,tell,nextStepExplorer(explorer1, V));
	.send(explorer3,tell,nextStepExplorer(explorer1, V));
	.send(explorer4,tell,nextStepExplorer(explorer1, V));
	-+stepDone(S);
	goto(V);
	!clearDecision.

@do2[atomic]
+!do(goto(V)): 
	step(S) & .my_name(explorer2)
<- 
	.send(explorer3,tell,nextStepExplorer(explorer2, V));
	.send(explorer4,tell,nextStepExplorer(explorer2, V));
	-+stepDone(S);
	goto(V);
	!clearDecision.

@do3[atomic]
+!do(goto(V)): 
	step(S) & .my_name(explorer3)
<- 
	.send(explorer4,tell,nextStepExplorer(explorer3, V));
	-+stepDone(S);
	goto(V);
	!clearDecision.

@do4[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(explorer1) 
<-
	.send(explorer2,tell,nextStepExplorer(explorer1, V));
	.send(explorer3,tell,nextStepExplorer(explorer1, V));
	.send(explorer4,tell,nextStepExplorer(explorer1, V));
	.print("I'm explorer1, and I'm notifying my friends.");
	-+stepDone(S); 
	Act;
	!clearDecision.
	
@do5[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(explorer2) 
<-
	.send(explorer3,tell,nextStepExplorer(explorer2, V));
	.send(explorer4,tell,nextStepExplorer(explorer2, V));
	.print("I'm explorer2, and I'm notifying my friends.");
	-+stepDone(S); 
	Act;
	!clearDecision.

@do6[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(explorer3) 
<-
	.send(explorer4,tell,nextStepExplorer(explorer3, V)); 
	.print("I'm explorer3, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!clearDecision.
    
@do7[atomic]
+!do(Act): 
	step(S)
<- 
	.print("I'm explorer4, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!clearDecision.

+!newPosition(V): 
	true 
<- 
	!newPositionRepairedGoal(V).

/* SWARM */
+!setSwarmMode:
	bestProbedVertex(V, Value)
<-
	+swarmMode;
	.broadcast(tell, [bestProbedVertex(V, Value), swarmMode]);
	.print("## THE BEST PLACE WAS FOUND! ", V, " ", Value).
	