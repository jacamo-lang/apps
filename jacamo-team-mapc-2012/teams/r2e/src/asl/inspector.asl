//agent inspector
{ include("commonBeliefs.asl") }

// conditions for goal selection
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_notRepairer.asl") }

/*
 * the inspect goal is enabled when:
 * - there is an enemy at the same vertex than an inspector
 * - the enemy wasn't inspected before OR the interval between the last inspected and the current step is great than the "time between inspections"
 * - if I have more priority than other inspectors at the same vertex
 */
is_inspect_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, _) & Team \== MyTeam 
				  & timeBetweenInspect(Time) & step(S) &
				  (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time) &
				  i_have_more_priority.
				  
//Test if there is other inspectors at the same vertex and I have the highest priority
i_have_more_priority :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyAgentName) &
				  not (visibleEntity(Entity, MyV, MyTeam, normal) & friend(AgentName, Entity, inspector) & Entity \== MyName & priorityEntity(AgentName, MyAgentName)).

/*
 * Check if there is an enemy in some adjacent vertex and test regarding to:
 * - the enemy wasn't inspected before OR the interval between the last inspected and the current step is great than the "time between inspections"
 * - I have enough energy to go that vertex and execute the action inspect (MyE >= W + CostInspect), where W is the cost of the edge and CostInspect is the cost of the inspect action
 * - I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) 
							 & timeBetweenInspect(Time) & step(S)
							 & energy(MyE) & costInspect(CostInspect) &
						   .setof(
						   		V, 
						   			ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, _) & Team \== MyTeam
						   			& (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time)
						   			& MyE >= W + CostInspect, 
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) 
							 & timeBetweenInspect(Time) & step(S)
							 & energy(MyE) & costInspect(CostInspect) &
						   .setof(
						   		V, 
						   			ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, _) & Team \== MyTeam
						   			& (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time)
						   			& MyE >= W + CostInspect, 
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
/*
 * The only different is that I don't regard to my Energy and cost of the edge.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) 
							 & timeBetweenInspect(Time) & step(S) &
						   .setof(
						   		V, 
						   			ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, _) & Team \== MyTeam
						   			& (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time), 
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) 
							 & timeBetweenInspect(Time) & step(S) &
						   .setof(
						   		V, 
						   			ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, _) & Team \== MyTeam
						   			& (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time), 
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
						   
/*
 * This rule check if there is an adjacent vertex that is dominated by the enemy team, but it is possible that don't have any enemy there.
 * I only choose the vertices than I didn't visit in some interval of steps
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF)
							& timeBetweenInspect(Time) & step(S) &
						   .setof(
						   		V, 
						   			ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam
						   			& (not ia.visitedVertex(V, _) | myVisitedVertex(V, SVisit) & S - SVisit > Time),
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF)
							& timeBetweenInspect(Time) & step(S) &
						   .setof(
						   		V, 
						   			ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam
						   			& (not ia.visitedVertex(V, _) | myVisitedVertex(V, SVisit) & S - SVisit > Time),
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
						   
/* The sequence of the priority plans */
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
+!select_goal : is_inspect_goal & not is_disabled <- !init_goal(inspect).
+!select_goal : no_way_to_go & (there_is_enemy_nearby(Op) | is_leave_goal) & not is_disabled <- !init_goal(survey).
+!select_goal : there_is_enemy_nearby(Op) & not is_disabled <- !init_goal(followEnemy(Op)).
+!select_goal : is_leave_goal  <- !init_goal(random_walk).
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).
+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	+maxStrengthSeen(1); 
	+maxHealthSeen(1);
	+timeBetweenInspect(100);
	+costInspect(2);
	
	+priorityEntity(inspector1, inspector2);
	+priorityEntity(inspector1, inspector3);
	+priorityEntity(inspector1, inspector4);
	
	+priorityEntity(inspector2, inspector3);
	+priorityEntity(inspector2, inspector4);
	
	+priorityEntity(inspector3, inspector4).
	
+!inspect:  
	true
<- 
	.print("I am going to inspect an entity");
    !do(inspect).
    
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	ia.edge(MyV,Op,W) & energy(MyE) & costInspect(CostInspect) & MyE < W + CostInspect
<- 
	.print("I have chose to inspect an enemy at ",Op, " but I don't have enough energy. I'm going to recharge firstly.I have ", MyE, " and I need ", W + CostInspect);
	!recharge.
	
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	ia.edge(MyV,Op,W) & energy(MyE) & costInspect(CostInspect) & MyE >= W + CostInspect
<- 
	.print("I have chose to inspect an enemy at ",Op, " and I have enough energy. I have ", MyE, " and I need ", W + CostInspect);
	!goto(Op).
    
+!followEnemy(Op): 
	true
<- 
	.print("I have chose to inspect an enemy at ",Op);
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
 			
//Percepts
/* Percepts Entity */
@inspectedEntity1[atomic]
+inspectedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange):
	step(S)
<-
	-evaluatedEntity(Entity, _, _, _, _, _, _, _, _, _);
	+evaluatedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange);
	-lastInspectEntity(Entity, _);
	+lastInspectEntity(Entity, S);
	!broadcastInspect(Entity, Type);
	+entityType(Entity, Type);
	!evaluateHealth(MaxHealth, Type);
	!evaluateStrength(Strength, Type);
	.print("The entity ", Entity, " was inspected Energy (", Energy, ",", MaxEnergy, ") Health (", Health, ",", MaxHealth, ") Strength ", Strength).

+!broadcastInspect(Entity, Type):
	not entityType(Entity, Type)
<-
	.print("Sending inspected entity in broadcast ", Entity, " ", Type);
	.broadcast(tell,entityType(Entity, Type)).
+!broadcastInspect(Entity, Type): true <- true.
	
+!evaluateHealth(Health, Type):
	maxHealthSeen(MaxH) & Health > MaxH & (Type == "Saboteur" | Type == "Repairer")
<-
	//-maxHealthSeen(_);
	//+maxHealthSeen(Health);
	-+maxHealthSeen(Health);
	.print("I saw a new max Health of a ", Type).
+!evaluateHealth(Health, Type): true <- true.
	
+!evaluateStrength(Strength, Type):
	maxStrengthSeen(MaxS) & Strength > MaxS & Type == "Saboteur"
<-
	//-maxStrengthSeen(_);
	//+maxStrengthSeen(Strength);
	-+maxStrengthSeen(Strength);
	.print("I saw a new max Strength of a ", Type).
+!evaluateStrength(Strength, Type): true <- true.
	
@do0[atomic]
+!do(Act): 
	step(S) & not stepDone(S)
<- 
	-+stepDone(S);
	Act.

@do1[atomic]
+!do(Act): 
	step(S)
<- 
	.print("ERROR! I already performed an action for this step! ", S).

+!newPosition(V): 
	true 
<- 
	!newPositionRepairedGoal(V).

+money(M):
	true
<-
	-+currentMoney(M).

@conceivePermissionToBuy1[atomic]
+!conceivePermissionToBuy[source(AgentName)]:
	currentMoney(M) & M > 2
<-
	-+currentMoney(M-2);
	.print(AgentName, " wants to buy something, I grant this permission...");
	.send(AgentName, tell, canBuy).

+!conceivePermissionToBuy[source(AgentName)]:
	true
<-
	.print(AgentName, " wants to buy something, I don't grant this permission...").
		