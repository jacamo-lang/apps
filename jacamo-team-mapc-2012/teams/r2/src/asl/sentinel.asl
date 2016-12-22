//agent sentinel
{ include("commonBeliefs.asl") }
// conditions for goal selection
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.
is_survey_goal :- position(MyV) & infinite(INF) & edge(MyV,_,INF).  // some edge to adjacent vertex is not surveyed
is_parry_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur").
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & not visitedVertex(V, _), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
						   
is_good_destination(Op) :- position(MyV) & infinite(INF) &
 						   .setof(V, edge(MyV,V,W) & W \== INF, Options)
 						   & .length(Options, TotalOptions) & TotalOptions > 0 &
 						   .nth(math.random(.length(Options)), Options, Op). 

/* The sequence of the priority plans */
+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_parry_goal <- !init_goal(parry).
+!select_goal : is_survey_goal <- !init_goal(survey).
+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	true.
    
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
 