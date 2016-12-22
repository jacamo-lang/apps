//agent repairer
{ include("commonBeliefs.asl") }

// conditions for goal selection
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.
is_buy_goal    :- (
					energy(MyE) & energyRequired(Er) & MyE < Er |
					health(MyH) & healthRequired(Hr) & MyH < Hr |
					strenght(MyS) & strengthRequired(Sr) & MyS < Sr
				  ) & money(MyM) & MyM > 2.
is_survey_goal :- position(MyV) & infinite(INF) & edge(MyV,_,INF).  // some edge to adjacent vertex is not surveyed
is_parry_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur").
is_repair_goal(Entity) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & visibleEntity(Entity, MyV, MyTeam, disabled) & Entity \== MyName.
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & not visitedVertex(V, _), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(.length(Options)), Options, Op).
						   
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
						   .setof(V, edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/* The sequence of the priority plans */
+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_parry_goal <- !init_goal(parry).
+!select_goal : is_repair_goal(Entity) <- !init_goal(repair(Entity)).
+!select_goal : is_survey_goal <- !init_goal(survey).
+!select_goal : there_is_disabled_friend_nearby(Op) <- !init_goal(followFriend(Op)).
+!select_goal : is_buy_goal    <- !init_goal(buy).
+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	+healthRequired(5). //one more than max strength of enemy saboteur
    
+!buy: 
	money(M) & health(MyH) & healthRequired(Hr) & MyH < Hr
<- 
	.print("I am going to buy shield! My money is ",M);
    !do(buy(shield)).
    
+!repair(Entity):  
	true
<- 
	.print("I am going to repair an entity and its name is ", Entity);
    !do(repair(Entity)).
    
+!followFriend(Op): 
	true
<- 
	.print("I have chose to repair a friend at ",Op);
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
	
+!parry:  
	true
<- 
	.print("I am going to parry because there's a saboteur here");
    !do(parry).
 			
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
 