//agent explorer
{ include("commonBeliefs.asl") }

// conditions for goal selection
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.
is_survey_goal :- position(MyV) & infinite(INF) & edge(MyV,_,INF).  // some edge to adjacent vertex is not surveyed
is_leave_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & (entityType(Entity, "Saboteur") | not entityType(Entity, _)).
there_is_enemy_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam. //TODO tratar sabotador
is_probe_goal  :- position(MyV) & not evaluatedVertex(MyV,_).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & not evaluatedVertex(V, _) & not there_is_enemy_at(V), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
						   
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(Value, edge(MyV,V,W) & W \== INF & evaluatedVertex(V,Value) & not there_is_enemy_at(V), SetValues)
						   & .max(SetValues, MaxValue)
						   & .setof(V, edge(MyV,V,W) & W \== INF & evaluatedVertex(V,MaxValue), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0
						   & .nth(math.random(.length(Options)), Options, Op).
						   
is_stop_goal   :- position(MyV) & bestVertex(Value) & evaluatedVertex(MyV,Value).
is_full_energy_goal :- is_stop_goal & energy(MyE) & maxEnergy(Max) & MyE < Max * 0.99.

/* The sequence of the priority plans */
+!select_goal : returnTo(VOld) & position(VOld)  <- -returnTo(_); !select_goal.
+!select_goal : is_leave_goal <- !init_goal(searchBestVertex).
+!select_goal : is_energy_goal | is_full_energy_goal <- !init_goal(recharge).
+!select_goal : returnTo(VOld) <- !init_goal(searchBestVertex).
+!select_goal : is_probe_goal  <- !init_goal(probe).
+!select_goal : is_survey_goal <- !init_goal(survey).
+!select_goal : is_stop_goal   <- !init_goal(skip).
+!select_goal                  <- !init_goal(searchBestVertex).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	+bestVertex(11).
   
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

+!updateBestVertex:
	lastProbed(V,Value) & maxProbedVertex(VBest, ValueBest) & Value > ValueBest
<-
	-maxProbedVertex(_, _);
	+maxProbedVertex(V,Value).
	
+!updateBestVertex:
	lastProbed(V,Value) & not maxProbedVertex(_, _)
<-
	+maxProbedVertex(V,Value).
+!updateBestVertex: true <- true.

+!checkBestVertex:
	maxProbedVertex(V,Value) & bestVertex(Value)
<-
	.print("I found the best vertex here!!!!"). //Notify everyone

+!checkBestVertex: 
	step(S) & bestVertex(Value) & explorationPhase(ExplorationPhase) & S > ExplorationPhase
<- 
	.print("I didn't found the best vertice yet, so I think my target is too hard.");
	-+bestVertex((Value-1));
	-+explorationPhase((ExplorationPhase * 2));
	!testingNewTargets.
	
+!testingNewTargets:
	bestVertex(Value) & explorationPhase(ExplorationPhase)
<-
	.print("Now I'm looking for a vertex of value ", Value, " until the step ", ExplorationPhase).
	
+!checkBestVertex: true <- true.
 			
//Percepts
/* Percepts Vertex */
@visibleVertex1[atomic]
+visibleVertex(V, Team):
	true
<-
	-vertex(V, _);
	+vertex(V, Team).
	
@probedVertex1[atomic]	
+probedVertex(V,Value): //my current probed vertex is less good than my last one
	lastProbed(VOld,ValueOld) & ValueOld > Value & lastPosition(VBefore)
<- 
	.print("Vertex probed: ", V, " with value ", Value, " is less good than my last one ", VOld, " with the value ", ValueOld);
	+returnTo(VBefore);
	+evaluatedVertex(V,Value).
	
@probedVertex2[atomic]
+probedVertex(V,Value):
	lastProbed(VOld,ValueOld)
<- 
	.print("Vertex probed: ", V, " with value ", Value);
	-lastProbed(VOld,ValueOld);
	+lastProbed(V,Value);
	+evaluatedVertex(V,Value).
	
@probedVertex3[atomic]
+probedVertex(V,Value):
	true
<- 
	.print("Vertex probed: ", V, " with value ", Value);
	+evaluatedVertex(V,Value);
	+lastProbed(V,Value).

/* ##############################
 * ########### EXTRAS ###########
 * ##############################
 */

@steps1[atomic]		
+steps(S):
	true
<-
	+totalSteps(S);
	+explorationPhase((S*0.02));
	.print("The total of steps is ", S);
	!testingNewTargets.
	