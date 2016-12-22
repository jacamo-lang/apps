//agent saboteur
{ include("commonBeliefs.asl") }

// conditions for goal selection
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_notRepairer.asl") }

/*
 * I have the buy goal when:
 * my health is less than the strenght of some enemy saboteur
 * my strenght is less then the health of some enemy repairer or saboteur
 * I have enough money
 * 
 * TODO: the money isn't implemented yet 
 */
is_buy_goal    :-(
					//health(MyH) & healthRequired(Hr) & MyH < Hr |
					strenght(MyS) & strengthRequired(Sr) & MyS < Sr
				 ) & money(MyM) & MyM > 2.
				  
//attack if there is an enemy at the same vertex
is_attack_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur")
						  & not nextStepSaboteur(_,Entity).
is_attack_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer")
						  & not nextStepSaboteur(_,Entity).
is_attack_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer")
						  & not nextStepSaboteur(_,Entity).
is_attack_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam
						  & not nextStepSaboteur(_,Entity).
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



/* The sequence of the priority plans */
+!select_goal:
	not numberWaits(_)
<-
	+numberWaits(0);
	!select_goal.
	
+!select_goal: //TODO ajustar para 3
	numberWaits(K) & K >= 3
<-
	.print("I can't wait anymore!");
	-+numberWaits(0);
	-+nextStepSaboteurAll(10);
	!select_goal.

+!select_goal:
	.my_name(saboteur4) & nextStepSaboteurAll(X) & X < 3 & numberWaits(K)
<-	
	.print("Waiting decision");
	//.wait({+nextStepSaboteur(saboteur2, V)}, 1000, EventTime);
	//.wait({+nextStepSaboteurAll(3)},150);
	.wait(150);
	-+numberWaits(K+1);
	!select_goal.
	
+!select_goal:
	.my_name(saboteur3) & nextStepSaboteurAll(X) & X < 2 & numberWaits(K)
<-	

	.print("Waiting decision");
	//.wait({+nextStepSaboteurAll(2)},150);
	.wait(150);
	-+numberWaits(K+1);
	!select_goal.
	
+!select_goal:
	.my_name(saboteur2) & nextStepSaboteurAll(X) & X < 1 & numberWaits(K)
<-	

	.print("Waiting decision");
	//.wait({+nextStepSaboteurAll(1)},150);
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
 */

+!select_goal : waitABit <- !init_goal(recharge).
+!select_goal : is_attack_goal(Entity) & not is_disabled <- !init_goal(attack(Entity)).
+!select_goal : there_is_enemy_nearby(Op) & not is_disabled <- !init_goal(followEnemy(Op)).
+!select_goal : is_buy_goal & canBuy & not is_disabled    <- !init_goal(buy).
+!select_goal : is_buy_goal & not canBuy & not is_disabled & not askedBuy   <- !tryAskBuy.
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).
+!select_goal : pathTogoSwarm(_, _) & not is_at_swarm_position & pathTogoSwarm(_, []) <- !cancelSwarmTravel; !select_goal.
+!select_goal : pathTogoSwarm(_, _) & not is_at_swarm_position <- !init_goal(walkSwarm).
+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	+strengthRequired(6); //equal than max health of enemy saboteur or repairer 
	+healthRequired(5); //one more than max strength of enemy saboteur
	+costAttack(2);
	
	+priorityEntity(saboteur1, saboteur2);
	+priorityEntity(saboteur1, saboteur3);
	+priorityEntity(saboteur1, saboteur4);
	
	+priorityEntity(saboteur2, saboteur3);
	+priorityEntity(saboteur2, saboteur4);
	
	+priorityEntity(saboteur3, saboteur4).
    
+!buy:
	money(M)
<- 
	.abolish(canBuy);
	.print("I am going to buy sabotageDevice! My money is ",M);
    !do(buy(sabotageDevice)).
    
/*
+!buy:
	money(M) & health(MyH) & healthRequired(Hr) & MyH < Hr
<- 
	.print("I am going to buy shield! My money is ",M);
    !do(buy(shield)).
 */
 
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
 	.abolish(nextStepSaboteur(_, _));
 	.abolish(nextStepSaboteurAll(_));
 	.abolish(numberWaits(_));
 	+nextStepSaboteurAll(0);
 	+numberWaits(0).
 	
@nextStepSaboteur1[atomic] 	
 +nextStepSaboteur(Ex, _):
 	not nextStepSaboteurCounted(Ex) & nextStepSaboteurAll(X)
 <-
 	+nextStepSaboteurCounted(Ex);
 	//-nextStepSaboteurAll(_);
 	//+nextStepSaboteurAll(X+1).
 	-+nextStepSaboteurAll(X+1).
 	
@nextStepSaboteur2[atomic] 	
 +nextStepSaboteur(Ex, _):
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
	.print("ERROR! I already performed an action for this step! ", S).
 	
 // the following plans are used to send only one action each cycle
@do1[atomic]
+!do(attack(V)): 
	step(S) & .my_name(saboteur1)
<- 
	.send(saboteur2,tell,nextStepSaboteur(saboteur1, V));
	.send(saboteur3,tell,nextStepSaboteur(saboteur1, V));
	.send(saboteur4,tell,nextStepSaboteur(saboteur1, V));
	-+stepDone(S);
	attack(V);
	!clearDecision.

@do2[atomic]
+!do(attack(V)): 
	step(S) & .my_name(saboteur2)
<- 
	.send(saboteur3,tell,nextStepSaboteur(saboteur2, V));
	.send(saboteur4,tell,nextStepSaboteur(saboteur2, V));
	-+stepDone(S);
	attack(V);
	!clearDecision.

@do3[atomic]
+!do(attack(V)): 
	step(S) & .my_name(saboteur3)
<- 
	.send(saboteur4,tell,nextStepSaboteur(saboteur3, V));
	-+stepDone(S);
	attack(V);
	!clearDecision.

@do4[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(saboteur1) 
<-
	.send(saboteur2,tell,nextStepSaboteur(saboteur1, saboteur1Skip));
	.send(saboteur3,tell,nextStepSaboteur(saboteur1, saboteur1Skip));
	.send(saboteur4,tell,nextStepSaboteur(saboteur1, saboteur1Skip));
	.print("I'm saboteur1, and I'm notifying my friends.");
	-+stepDone(S); 
	Act;
	!clearDecision.
	
@do5[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(saboteur2) 
<-
	.send(saboteur3,tell,nextStepSaboteur(saboteur2, saboteur2Skip));
	.send(saboteur4,tell,nextStepSaboteur(saboteur2, saboteur2Skip));
	.print("I'm saboteur2, and I'm notifying my friends.");
	-+stepDone(S); 
	Act;
	!clearDecision.

@do6[atomic]
+!do(Act): 
	step(S) & position(V) & .my_name(saboteur3) 
<-
	.send(saboteur4,tell,nextStepSaboteur(saboteur3, saboteur3Skip)); 
	.print("I'm saboteur3, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!clearDecision.
    
@do7[atomic]
+!do(Act): 
	step(S)
<- 
	.print("I'm saboteur4, and I'm notifying my friends.");
	-+stepDone(S);
	Act;
	!clearDecision.

+!newPosition(V): 
	true 
<- 
	!newPositionRepairedGoal(V);
	!newPositionSwarmGoal(V).
	
+!newStepPosAction(S):	true <- true.