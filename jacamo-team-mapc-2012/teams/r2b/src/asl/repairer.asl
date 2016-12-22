//agent repairer
{ include("commonBeliefs.asl") }

// conditions for goal selection
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_parryRule.asl") }

/*
 * I have the buy goal when:
 * my health is less than the strenght of some enemy saboteur
 * I have enough money
 * 
 * TODO: the money isn't implemented yet 
 */
is_buy_goal    :- health(MyH) & healthRequired(Hr) & MyH < Hr
				  & money(MyM) & MyM > 2.

/*
 * Check if there is a friend at the same vertex and he is disabled
 * TODO maybe it is interesting to check the priority if there is more than 1 repairer at the same vertex
 */
is_repair_goal(Entity) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & visibleEntity(Entity, MyV, MyTeam, disabled) & Entity \== MyName.

/*
 * Check if there is a friend at some adjacent vertex and he is disabled
 * TODO it's interesting have priority when there is more than one disabled friend.
 */
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
						   .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

//If I'm disabled and there is a normal repairer at some adjacent vertex, so I'm going to wait 
is_wait_repair_goal :- is_disabled & position(MyV) & myTeam(MyTeam) & 
						ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, normal) & friend(_, Entity, repairer).
//If I'm disabled and there is a normal or disabled repairer at the same vertex, so I'm going to wait
is_wait_repair_goal :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
						visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer) & Entity \== MyName.
//If I'm disabled and there is a disabled repairer at some adjacent vertex, so I'm going to wait if my friend has higher priority
is_wait_repair_goal :- is_disabled & position(MyV) & myTeam(MyTeam) & .my_name(MyAgentName) & 
						ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(AgentName, Entity, repairer) & priorityEntity(AgentName, MyAgentName).


/* The sequence of the priority plans */
+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_parry_goal & not is_disabled <- !init_goal(parry).
+!select_goal : is_leave_goal <- !init_goal(random_walk).
+!select_goal : is_repair_goal(Entity) <- !init_goal(repair(Entity)).
+!select_goal : is_wait_repair_goal <-
	.print("Waiting to be repaired."); 
	!init_goal(recharge). //Instead of don't do anything, then recharge
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).
+!select_goal : there_is_disabled_friend_nearby(Op) <- !init_goal(followFriend(Op)).
+!select_goal : is_buy_goal & not is_disabled   <- !init_goal(buy).
+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
	true
<-
	+priorityEntity(repairer1, repairer2);
	+priorityEntity(repairer1, repairer3);
	+priorityEntity(repairer1, repairer4);
	
	+priorityEntity(repairer2, repairer3);
	+priorityEntity(repairer2, repairer4);
	
	+priorityEntity(repairer3, repairer4);
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
// the following plan is used to send only one action each cycle
+!do(Act): 
	step(S)
<- 
	Act. // perform the action (i.e., send the action to the simulator)
    //!wait_next_step(S). // wait for the next step before going on
