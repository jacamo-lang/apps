//agent inspector
{ include("commonBeliefs.asl") }

// conditions for goal selection
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.
is_survey_goal :- position(MyV) & infinite(INF) & edge(MyV,_,INF).  // some edge to adjacent vertex is not surveyed
is_leave_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur").
is_inspect_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, _) & Team \== MyTeam 
				  & timeBetweenInspect(Time) & step(S) &
				  (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & not visitedVertex(V, _), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
						   
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(.length(Options)), Options, Op).
						   
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) 
							 & timeBetweenInspect(Time) & step(S)
							 & energy(MyE) & costInspect(CostInspect) &
						   .setof(
						   		V, 
						   			edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, _) & Team \== MyTeam
						   			& (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time)
						   			& MyE >= W + CostInspect, 
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) 
							 & timeBetweenInspect(Time) & step(S) &
						   .setof(
						   		V, 
						   			edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, _) & Team \== MyTeam
						   			& (not lastInspectEntity(Entity, _) | lastInspectEntity(Entity, SInspect) & S - SInspect > Time), 
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF)
							& timeBetweenInspect(Time) & step(S) &
						   .setof(
						   		V, 
						   			edge(MyV,V,W) & W \== INF & visibleVertex(V, Team) & Team \== none & Team \== MyTeam
						   			& (not visitedVertex(V, _) | visitedVertex(V, SVisit) & S - SVisit > Time),
						   		Options
						   )
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/* The sequence of the priority plans */
+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_inspect_goal <- !init_goal(inspect).
+!select_goal : there_is_enemy_nearby(Op) <- !init_goal(followEnemy(Op)).
+!select_goal : is_leave_goal  <- !init_goal(random_walk).
+!select_goal : is_survey_goal <- !init_goal(survey).
+!select_goal : is_buy_goal    <- !init_goal(buy).
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
	+costInspect(2).
	
+!inspect:  
	true
<- 
	.print("I am going to inspect an entity");
    !do(inspect).
    
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	edge(MyV,Op,W) & energy(MyE) & costInspect(CostInspect) & MyE < W + CostInspect
<- 
	.print("I have chose to inspect an enemy at ",Op, " but I don't have enough energy. I'm going to recharge firstly.I have ", MyE, " and I need ", W + CostInspect);
	!recharge.
	
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	edge(MyV,Op,W) & energy(MyE) & costInspect(CostInspect) & MyE >= W + CostInspect
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
/* Percepts Vertex */
@visibleVertex1[atomic]
+visibleVertex(V, Team):
	true
<-
	-vertex(V, _);
	+vertex(V, Team).

/* Percepts Entity */
@inspectedEntity1[atomic]
+inspectedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange):
	step(S)
<-
	-evaluatedEntity(Entity, _, _, _, _, _, _, _, _, _);
	+evaluatedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange);
	-lastInspectEntity(Entity, _);
	+lastInspectEntity(Entity, S);
	!broadcast(Entity, Type);
	+entityType(Entity, Type);
	!evaluateHealth(MaxHealth, Type);
	!evaluateStrength(Strength, Type);
	.print("The entity ", Entity, " was inspected Energy (", Energy, ",", MaxEnergy, ") Health (", Health, ",", MaxHealth, ") Strength ", Strength).

+!broadcast(Entity, Type):
	not entityType(Entity, Type)
<-
	.broadcast(tell,entityType(Entity, Type)).
+!broadcast(Entity, Type): true <- true.
	
+!evaluateHealth(Health, Type):
	maxHealthSeen(MaxH) & Health > MaxH & (Type == "Saboteur" | Type == "Repairer")
<-
	-maxHealthSeen(_);
	+maxHealthSeen(Health);
	.print("I saw a new max Health of a ", Type).
+!evaluateHealth(Health, Type): true <- true.
	
+!evaluateStrength(Strength, Type):
	maxStrengthSeen(MaxS) & Strength > MaxS & Type == "Saboteur"
<-
	-maxStrengthSeen(_);
	+maxStrengthSeen(Strength);
	.print("I saw a new max Strength of a ", Type).
+!evaluateStrength(Strength, Type): true <- true.
	
/* ##############################
 * ########### EXTRAS ###########
 * ##############################
 */
 