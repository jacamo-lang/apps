//agent saboteur
{ include("commonBeliefs.asl") }

// conditions for goal selection
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_notRepairer.asl") }

/*
 * I have the buy goal when:
 * my health is less than the strength of some enemy saboteur
 * my strength is less then the health of some enemy repairer or saboteur
 * I have enough money
 */
is_buy_goal    :- (is_buy_attack_goal | is_buy_shield_goal) & money(MyM) & MyM > 2.
				 
is_buy_attack_goal    :- strength(MyS) & strengthRequired(Sr) & MyS < Sr & .my_name(saboteur1).

is_buy_shield_goal    :- myMaxHealth(MyH) & healthRequired(Hr) & MyH < Hr.
/* 				 
is_buy_shield_goal    :-
					(
						//myMaxHealth(MyH) & healthRequired(Hr) & MyH < Hr 
						myMaxHealth(MyH) &
						(
							MyH < 4
							|
							(
								step(CurrentStep) &
								lastSeenEntity(Entity, Step) & entityStrength(Entity, MaxStrength) &
								MyH <= MaxStrength &
								CurrentStep - Step < 15
							)
						)
					).*/
				  
//attack if there is an enemy at the same vertex
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur")
						  & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- step(Step) & Step <= 200 & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer")
						  & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer")
						  & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Inspector")
						  & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer")
						  & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam
						  & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur") & strength(MyS) & entityHealth(Entity,MaxHealth) & MaxHealth > MyS.
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer").
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer").
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Inspector").
						  
there_is_more_saboteurs(SaboteurNameFriend) :- position(MyV) & step(S) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyNameJason) &
							visibleEntity(Entity, MyV, MyTeam, normal) & 
							Entity \== MyName &
							friend(SaboteurNameFriend, Entity, saboteur) & 
							visibleEntity(EntityTwo, MyV, Team, normal) &
							Team \== MyTeam &
							priorityEntity(SaboteurNameFriend, MyNameJason) &
							not nextStepSaboteur(SaboteurNameFriend, _, S).

/*
is_attack_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam
						  & i_have_more_priority.
						  */

//Test if there is other saboteurs at the same vertex and I have the highest priority
i_have_more_priority :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyAgentName) &
				  not (visibleEntity(Entity, MyV, MyTeam, normal) & friend(AgentName, Entity, saboteur) & Entity \== MyName & priorityEntity(AgentName, MyAgentName)).

/*
 * Test if there is some enemy at some adjacent vertex. It regards to:
 * - I have enough energy to go to the vertex and execute the action attack (MyE >= W + CostAttack), where W is the cost of the edge and CostAttack is the cost of the attack action
 * I may have more options, so I choose ramdomly
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & energy(MyE) & costAttack(CostAttack) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & MyE >= W + CostAttack, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & energy(MyE) & costAttack(CostAttack) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & MyE >= W + CostAttack, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/*
 * The only different is that I don't regard to my Energy and cost of the edge.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/*
 * This rule check if there is an adjacent vertex that is dominated by the enemy team, but it is possible that don't have any enemy there.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
						   
noMoreVertexToProbe :- true.

/* Inside of good area */
get_vertex_to_go_attack(D, Path) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
												allowedArea(NeighborhoodOutside, NeighborhoodInside) &
											.setof(V,
												visibleEntity(Entity, V, Team, _) & 
												MyTeam \== Team &
												(not entityType(Entity, _) | entityType(Entity, "Saboteur")) &
												(.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_attack(D, Path) :- position(MyV) & 
												allowedArea(NeighborhoodOutside, NeighborhoodInside) &
											.setof(V,
												ia.visibleEnemy(Entity, V) & 
												(not entityType(Entity, _) | entityType(Entity, "Saboteur")) &
												(.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_attack(D, Path) :- position(MyV) & myTeam(MyTeam) & 
												allowedArea(NeighborhoodOutside, NeighborhoodInside) &
											.setof(V,
												visibleEntity(Entity, V, Team, _) & 
												MyTeam \== Team &
												(.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_attack(D, Path) :- position(MyV) & 
												allowedArea(NeighborhoodOutside, NeighborhoodInside) &
											.setof(V,
												ia.visibleEnemy(Entity, V) & 
												(.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

/* Outside of good area */
get_vertex_to_go_attack_search(D, Path) :- position(MyV) & myTeam(MyTeam) & 
											.setof(V,
												visibleEntity(Entity, V, Team, _) & 
												MyTeam \== Team &
												(not entityType(Entity, _) | entityType(Entity, "Saboteur")) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_attack_search(D, Path) :- position(MyV) &
											.setof(V,
												ia.visibleEnemy(Entity, V) & 
												(not entityType(Entity, _) | entityType(Entity, "Saboteur")) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_attack_search(D, Path) :- position(MyV) & myTeam(MyTeam) &
											.setof(V,
												visibleEntity(Entity, V, Team, _) & 
												MyTeam \== Team  
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_attack_search(D, Path) :- position(MyV) &
											.setof(V,
												ia.visibleEnemy(Entity, V) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).


/* The sequence of the priority plans */
+!select_goal:
	there_is_more_saboteurs(SaboteurNameFriend) & not numberWaits(_)
<-
	+numberWaits(0);
	!select_goal.
	
+!select_goal: //TODO ajustar para 3
	(there_is_more_saboteurs(SaboteurNameFriend) & numberWaits(K) & K >= 14) | (step(0) & not nextStepSaboteurAll(10))
<-
	.print("I can't wait anymore!");
	-+numberWaits(0);
	-+nextStepSaboteurAll(10);
	!select_goal.

+!select_goal:
	there_is_more_saboteurs(SaboteurNameFriend) & numberWaits(K)
<-	
	.print("Waiting decision ", SaboteurNameFriend);
	.wait(150);
	-+numberWaits(K+1);
	!select_goal.



+!select_goal : is_heartbeat_goal
	<-
	.print("I'm in the same place yet!!!!!!");
	.abolish(stepsSamePosition(_, _)); //TODO fazer alguma coisa se o agente ficar muito no mesmo lugar
	!select_goal.

+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_wait_repair_goal_general(V) <-
	.print("Waiting to be repaired."); 
	!init_goal(waitRepair(V)).
//+!select_goal : is_next_destination_repair_vertex <- !init_goal(achieveDestinationRepair).
+!select_goal : is_route_repaired_goal <- !reviewMyPositionRepaired; !init_goal(repair_walk). //I'm going to be repaired by some agent

+!select_goal : is_buy_goal & 
				canBuy & 
				not is_disabled & 
				position(Pos) & 
				not there_is_enemy_at(Pos) <- !init_goal(buy).
+!select_goal : 
				is_buy_goal & 
				not canBuy & 
				not is_disabled & 
				not askedBuy &
				position(Pos) &   
				not there_is_enemy_at(Pos) <- !tryAskBuy.
+!select_goal : waitABit <- !init_goal(recharge).

+!select_goal : is_disabled <- !init_goal(walk_repair_forever_alone).

+!select_goal : is_attack_goal(Entity) & not is_disabled <- !init_goal(attack(Entity)).
+!select_goal : there_is_enemy_nearby(Op) & there_is_dangerous_enemy_at(Op) &
				is_full_energy_goal & 
				not is_disabled & not is_almost_full_map <- !init_goal(recharge).
+!select_goal : there_is_enemy_nearby(Op) & not is_disabled & not is_almost_full_map <- !init_goal(followEnemy(Op)).
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).
+!select_goal : pathTogoSwarm(_, _) & not is_at_swarm_position & pathTogoSwarm(_, []) <- !cancelSwarmTravel; !select_goal.
+!select_goal : pathTogoSwarm(_, _) & not is_at_swarm_position & not is_almost_full_map <- !init_goal(walkSwarm).

+!select_goal : not is_disabled & is_good_map_conquered <-
	.print("Good map conquered!"); 
	!init_goal(recharge).
	
+!select_goal : not is_disabled & not there_is_enemy_inside_my_good_area(V) & is_at_swarm_position_test <-
	.print("Stop! Stand still!"); 
	!init_goal(recharge).
	
+!select_goal : there_is_enemy_inside_my_good_area(V) <- !init_goal(walk_attack_area).
+!select_goal : not is_at_swarm_position <- !init_goal(walk_attack_area_search).

+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	+strengthRequired(3); //equal than max health of enemy saboteur or repairer 
	+healthRequired(4); //one more than max strength of enemy saboteur
	+costAttack(2);
	
	+priorityEntity(saboteur1, saboteur2);
	+priorityEntity(saboteur1, saboteur3);
	+priorityEntity(saboteur1, saboteur4);
	
	+priorityEntity(saboteur2, saboteur3);
	+priorityEntity(saboteur2, saboteur4);
	
	+priorityEntity(saboteur3, saboteur4);
	.print("Initialized!").
    
+!buy:
	is_buy_shield_goal & money(M) & myMaxHealth(MyH)
<- 
	.abolish(canBuy);
	.print("I am going to buy shield! My money is ",M, " my max health is ", MyH);
    !do(buy(shield)).
    
+!buy:
	is_buy_attack_goal & money(M) & strength(MyS) & .my_name(saboteur1)
<- 
	.abolish(canBuy);
	.print("I am going to buy sabotageDevice! My money is ",M);
    !do(buy(sabotageDevice)).
 
+!attack(Entity):  
	true
<- 
	.print("I am going to attack an entity and its name is ", Entity);
    !do(attack(Entity)).
    
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	ia.edge(MyV,Op,W) & energy(MyE) & costAttack(CostAttack) & MyE < W + CostAttack
<- 
	.print("I have chose to attack an enemy at ",Op, " but I don't have enough energy. I'm going to recharge firstly.I have ", MyE, " and I need ", W + CostAttack);
	!recharge.
	
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	ia.edge(MyV,Op,W) & energy(MyE) & costAttack(CostAttack) & MyE >= W + CostAttack
<- 
	.print("I have chose to attack an enemy at ",Op, " and I have enough energy. I have ", MyE, " and I need ", W + CostAttack);
	!goto(Op).
    
+!followEnemy(Op): 
	true
<- 
	.print("I have chose to attack an enemy at ",Op);
	!goto(Op).
    
+!random_walk: 
	is_good_destination(Op)
<- 
	.print("I have chose ",Op);
	!goto(Op).
    
+!random_walk: 
	true
<- 
	.print("I don't know where I'm going, so I'm going to recharge");
	!recharge.
 			
+!clearDecision:
 	true
 <-
 	.abolish(nextStepSaboteurCounted(_));
 	.abolish(nextStepSaboteur(_, _, _));
 	.abolish(nextStepSaboteurAll(_));
 	.abolish(numberWaits(_));
 	+nextStepSaboteurAll(0);
 	+numberWaits(0).
 	
@nextStepSaboteur1[atomic] 	
 +nextStepSaboteur(Ex, _, _):
 	not nextStepSaboteurCounted(Ex) & nextStepSaboteurAll(X)
 <-
 	+nextStepSaboteurCounted(Ex);
 	//-nextStepSaboteurAll(_);
 	//+nextStepSaboteurAll(X+1).
 	-+nextStepSaboteurAll(X+1).
 	
@nextStepSaboteur2[atomic] 	
 +nextStepSaboteur(Ex, _, _):
 	not nextStepSaboteurCounted(Ex) & not nextStepSaboteurAll(_)
 <-
 	+nextStepSaboteurCounted(Ex);
 	//-nextStepSaboteurAll(_);
 	//+nextStepSaboteurAll(X+1).
 	-+nextStepSaboteurAll(1).
    
@do0[atomic]
+!do(Act): 
	step(S) & stepDone(S)
<- 
	!clearDecision;
	.print("ERROR! I already performed an action for this step! ", S).
 	
 // the following plans are used to send only one action each cycle
@do1[atomic]
+!do(attack(V)): 
	step(S) & .my_name(saboteur1)
<-
	!clearDecision; 
	.send(saboteur2,tell,nextStepSaboteur(saboteur1, V, S));
	.send(saboteur3,tell,nextStepSaboteur(saboteur1, V, S));
	.send(saboteur4,tell,nextStepSaboteur(saboteur1, V, S));
	-+stepDone(S);
	attack(V);
	!!synchronizeGraph.

@do2[atomic]
+!do(attack(V)): 
	step(S) & .my_name(saboteur2)
<-
	!clearDecision; 
	.send(saboteur3,tell,nextStepSaboteur(saboteur2, V, S));
	.send(saboteur4,tell,nextStepSaboteur(saboteur2, V, S));
	-+stepDone(S);
	attack(V);
	!!synchronizeGraph.

@do3[atomic]
+!do(attack(V)): 
	step(S) & .my_name(saboteur3)
<-
	!clearDecision; 
	.send(saboteur4,tell,nextStepSaboteur(saboteur3, V, S));
	-+stepDone(S);
	attack(V);
	!!synchronizeGraph.

@do4[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(saboteur1) 
<-
	!clearDecision;
	.send(saboteur2,tell,nextStepSaboteur(saboteur1, saboteur1Skip, S));
	.send(saboteur3,tell,nextStepSaboteur(saboteur1, saboteur1Skip, S));
	.send(saboteur4,tell,nextStepSaboteur(saboteur1, saboteur1Skip, S));
	.print("I'm saboteur1, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!!synchronizeGraph.
	
@do5[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(saboteur2) 
<-
	!clearDecision;
	.send(saboteur3,tell,nextStepSaboteur(saboteur2, saboteur2Skip, S));
	.send(saboteur4,tell,nextStepSaboteur(saboteur2, saboteur2Skip, S));
	.print("I'm saboteur2, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!!synchronizeGraph.

@do6[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(saboteur3) 
<-
	!clearDecision;
	.send(saboteur4,tell,nextStepSaboteur(saboteur3, saboteur3Skip, S)); 
	.print("I'm saboteur3, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!!synchronizeGraph.
    
@do7[atomic]
+!do(Act): 
	step(S)
<-
	!clearDecision; 
	.print("I'm saboteur4, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!!synchronizeGraph.

+!newPosition(V): 
	true 
<- 
	!newPositionRepairedGoal(V);
	!newPositionSwarmGoal(V).
	
+!newStepPosAction(S):	true <- true. //revisar lista de inimigos a cada 2 steps, dar abolish em tudo que for source(self) no final desse step usar mesma estrutura de visibleEntity

+!walk_attack_area_search:
	get_vertex_to_go_attack_search(D, Path)
<-
	.print("I'm mode attack on search. I'm going to ", D, " using path: ", Path);
	!testWalkAttackArea(D);
	!gotoPathAttack(Path).
	
+!walk_attack_area_search: 
	true
<- 
	.print("I'm mode attack on search. I do not know any path.");
	!random_walk.

+!walk_attack_area:
	get_vertex_to_go_attack(D, Path)
<-
	.print("I'm mode attack on. I'm going to ", D, " using path: ", Path);
	!testWalkAttackArea(D);
	!gotoPathAttack(Path).
	
+!walk_attack_area: 
	true
<- 
	.print("I'm mode attack on. I do not know any path.");
	!random_walk.

+!testWalkAttackArea(D):
	visibleEntity(Entity, D, Team, _) & myTeam(MyTeam) & Team \== MyTeam
<-
	.print("I'm mode attack on. I can see ", Entity, " at ", D).
	
+!testWalkAttackArea(D):
	true
<-
	.print("I'm mode attack on. I do not see anyone at ", D).
	
+!gotoPathAttack([]):
	true
<-
	.print("I'm mode attack on. I do not know any path and I'm lost.");
	!random_walk.
	
+!gotoPathAttack([V|[]]):
	position(V)
<-
	.print("I'm mode attack on. I do not know any path and I'm lost two.");
	!random_walk.
	
+!gotoPathAttack([V|T]):
	position(V)
<-
	!gotoPathAttack(T).
	
+!gotoPathAttack([V|_]):
	true
<-
	.print("I'm mode attack on. My next step is ", V);
	!goto(V).


+!setEntityNewMaxStrength(Entity, MaxStrength):
	true
<-
	-entityStrength(Entity, _);
	+entityStrength(Entity, MaxStrength).
	
+!setEntityHealth(Entity, MaxHealth):
	true
<-
	-entityHealth(Entity, _);
	+entityHealth(Entity, MaxHealth).
	
@evaluateEntityNewMaxStrength1[atomic]
+!evaluateEntityNewMaxStrength(Entity):
	entityStrength(Entity, MaxStrength) & healthRequired(Current) & MaxStrength > Current -1
<-
	.print("New MaxStrength seen: ", MaxStrength, " setting healthRequired to ", MaxStrength +1);
	-+healthRequired(MaxStrength +1).
+!evaluateEntityNewMaxStrength(Entity): true <- true.

@evaluateEntityNewMaxStrength2[atomic]
+!evaluateEntityHealth(Entity):
	entityHealth(Entity, MaxHealth) & strengthRequired(Current) & MaxHealth > Current & entityType(Entity, "Saboteur")
<-
	.print("New MaxHealth seen: ", MaxHealth, " setting strengthRequired to ", MaxHealth);
	-+strengthRequired(MaxHealth).
+!evaluateEntityHealth(Entity): true <- true.

+!processEntity(Entity):
	true
<-
	!evaluateEntityNewMaxStrength(Entity);
	!evaluateEntityHealth(Entity).
	
{ include("loadAgents.asl") }