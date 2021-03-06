//agent sentinel
{ include("commonBeliefs.asl") }

// conditions for goal selection
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_notRepairer.asl") }
{ include("commonRules_parryRule.asl") }

noMoreVertexToProbe :- true.

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
//+!select_goal : is_next_destination_repair_vertex <- !init_goal(achieveDestinationRepair).
+!select_goal : is_route_repaired_goal <- !reviewMyPositionRepaired; !init_goal(repair_walk). //I'm going to be repaired by some agent
/*
+!select_goal : is_destination_repair_vertex(RepairerName) & step(S) <-
	.print("Waiting to be repaired ", S, ". I have an appointment with ", RepairerName); 
	!init_goal(recharge). //Instead of don't do anything, then recharge
 */
+!select_goal : waitABit <- !init_goal(recharge).

+!select_goal : is_disabled <- !init_goal(walk_repair_forever_alone).

+!select_goal : is_parry_goal & not is_disabled <- !init_goal(parry).
+!select_goal : is_survey_goal & not is_disabled  <- !init_goal(survey).
+!select_goal : pathTogoSwarm(_, _) & not is_at_swarm_position & pathTogoSwarm(_, []) <- !cancelSwarmTravel; !select_goal.
+!select_goal : not is_almost_full_map & pathTogoSwarm(_, _) & not is_at_swarm_position <- !init_goal(walkSwarm).
//+!select_goal : is_leave_goal & not is_disabled & is_at_swarm_position <- !init_goal(parry).
+!select_goal : is_leave_goal & not is_disabled & not is_almost_full_map <- !init_goal(random_walk).
+!select_goal : is_leave_goal & not is_disabled & is_almost_full_map <- !init_goal(parry).
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).

+!select_goal : not is_disabled & is_good_map_conquered <-
	.print("Good map conquered!"); 
	!init_goal(recharge).

+!select_goal : not is_disabled & is_at_swarm_position_test <-
	.print("Stop! Stand still!"); 
	!init_goal(recharge).

+!select_goal: noMoreVertexToProbe & not is_at_swarm_position & get_vertex_to_go_swarm(D, Path) <- !init_goal(gotoPathFastSwarm(Path)).

//+!select_goal: noMoreVertexToProbe & is_at_swarm_position & not is_disabled & (is_inside_team_friends | there_are_more_friends_than_enemies_my_position) & get_path_to_some_border_vertex(D, Path) <- !init_goal(gotoPathOutsideGoodArea(D, Path)).
//+!select_goal: noMoreVertexToProbe & is_at_swarm_position & not is_disabled & not is_at_swarm_position_test & going_swarm_inside_goal & get_path_to_some_inside_vertex(D, Path) <- !init_goal(gotoPathInsideGoodArea(D, Path)).

/*+!select_goal: noMoreVertexToProbe & is_at_swarm_position & is_wait_attack_goal <-
			.print("Waiting to be attacked!"); 
			!init_goal(recharge). */

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
@do0[atomic]
+!do(Act): 
	step(S) & not stepDone(S)
<- 
	-+stepDone(S);
	Act;
	!!synchronizeGraph.

@do1[atomic]
+!do(Act): 
	step(S)
<- 
	.print("ERROR! I already performed an action for this step! ", S).

+!newPosition(V): 
	true 
<- 
	!newPositionRepairedGoal(V);
	!newPositionSwarmGoal(V);
	!!broadcastCurrentPosition(V).
	
+!newStepPosAction(S):	
	true 
<- 
	true.
	
+!processEntity(Entity): true <- true.

{ include("loadAgents.asl") }