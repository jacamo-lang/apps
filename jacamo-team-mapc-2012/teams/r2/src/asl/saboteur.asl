//agent saboteur
{ include("commonBeliefs.asl") }

// conditions for goal selection
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.
is_buy_goal    :- (
					energy(MyE) & energyRequired(Er) & MyE < Er |
					health(MyH) & healthRequired(Hr) & MyH < Hr |
					strenght(MyS) & strengthRequired(Sr) & MyS < Sr
				  ) & money(MyM) & MyM > 2.
is_survey_goal :- position(MyV) & infinite(INF) & edge(MyV,_,INF).  // some edge to adjacent vertex is not surveyed
is_attack_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam.
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & not visitedVertex(V, _), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(.length(Options)), Options, Op).
						   
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & energy(MyE) & costAttack(CostAttack) &
						   .setof(V, edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & MyE >= W + CostAttack, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & visibleVertex(V, Team) & Team \== none & Team \== MyTeam, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/* The sequence of the priority plans */
+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_attack_goal(Entity) <- !init_goal(attack(Entity)).
+!select_goal : there_is_enemy_nearby(Op) <- !init_goal(followEnemy(Op)).
+!select_goal : is_buy_goal    <- !init_goal(buy).
+!select_goal : is_survey_goal <- !init_goal(survey).
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
	+costAttack(2).
    
+!buy: 
	money(M) & health(MyH) & healthRequired(Hr) & MyH < Hr
<- 
	.print("I am going to buy shield! My money is ",M);
    !do(buy(shield)).
    
+!buy: 
	money(M) & strength(MyS) & strengthRequired(Sr) & MyS < Sr
<- 
	.print("I am going to buy sabotageDevice! My money is ",M);
    !do(buy(sabotageDevice)).

+!buy: 
	money(M) & energy(MyE) & energyRequired(Er) & MyE < Er
<- 
	.print("I am going to buy battery! My money is ",M);
    !do(buy(battery)).
    
+!attack(Entity):  
	true
<- 
	.print("I am going to attack an entity and its name is ", Entity);
    !do(attack(Entity)).
    
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	edge(MyV,Op,W) & energy(MyE) & costAttack(CostAttack) & MyE < W + CostAttack
<- 
	.print("I have chose to attack an enemy at ",Op, " but I don't have enough energy. I'm going to recharge firstly.I have ", MyE, " and I need ", W + CostAttack);
	!recharge.
	
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
	position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
	edge(MyV,Op,W) & energy(MyE) & costAttack(CostAttack) & MyE >= W + CostAttack
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
 			
//Percepts
/* Percepts Vertex */
@visibleVertex1[atomic]
+visibleVertex(V, Team):
	true
<-
	-vertex(V, _);
	+vertex(V, Team).
	
/* ##############################
 * ########### EXTRAS ###########
 * ##############################
 */
 