//agent sentinel
{ include("commonBeliefs.asl") }

// conditions for goal selection
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_notRepairer.asl") }
{ include("commonRules_parryRule.asl") }

/* The sequence of the priority plans */
+!select_goal : is_wait_repair_goal <-
	.print("Waiting to be repaired."); 
	!init_goal(recharge). //Instead of don't do anything, then recharge
+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_parry_goal & not is_disabled <- !init_goal(parry).
+!select_goal : is_leave_goal <- !init_goal(random_walk).
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).
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
	
// the following plan is used to send only one action each cycle
+!do(Act): 
	step(S)
<- 
	Act. // perform the action (i.e., send the action to the simulator)
    //!wait_next_step(S). // wait for the next step before going on
 
{ include("probedVertex.asl") }
