// energy lower than the minimum energy allowed
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.
is_full_energy_goal :- energy(MyE) & maxEnergy(Max) & MyE < Max.

// some edge to adjacent vertex is not surveyed
is_survey_goal :- position(MyV) & 
				  (
				  	infinite(INF) & ia.edge(MyV,_,INF)
				  |	
				    maxWeight(MAXWEIGHT) & ia.edge(MyV,_,MAXWEIGHT)
				  ).

// test if the agent is disabled
is_disabled :- health(MyHealth) & MyHealth <= 0.

there_is_disable_friend_at_same_vertex_as_repairer(V) :- myTeam(MyTeam) & myNameInContest(MyName) &
								visibleEntity(Entity, V, MyTeam, disabled) &
								Entity \== MyName &
								visibleEntity(EntityRepairer, V, MyTeam, _) &
								EntityRepairer \== MyName &
								friend(_, EntityRepairer, repairer) & 
								EntityRepairer \== Entity.

// test if there is a dangerous enemy at the same vertex. A dangerous enemy is an unknown enemy or a Saboteur.
// Obs.: It isn't used by the saboteurs
is_leave_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & (entityType(Entity, "Saboteur") | not entityType(Entity, _)).

// test if don't have any direction to go with the edge already surveyed (W != INF)
no_way_to_go :- position(MyV) & infinite(INF) &
				.setof(V, ia.edge(MyV,V,W) & W \== INF, []).
				
// test if the agent is at the destination vertex to be repaired
is_destination_repair_vertex(RepairerName) :- position(MyV) & gotoVertexRepair(MyV,RepairerName,_).

// test if the agent is next to the destination vertex to be repaired
is_next_destination_repair_vertex :- gotoVertexRepair(_,_,[D|T]) & position(MyV) & ia.edge(MyV,D,_) & not .member(MyV,T).
//is_next_destination_repair_vertex :- gotoVertexRepair(D,_,_) & position(MyV) & ia.edge(MyV,D,_).

//Verify if there is some dangerous enemies at vertex Op. A dangerous enemy is an unknown enemy or a Saboteur 
there_is_enemy_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam & (entityType(Entity, "Saboteur") | not entityType(Entity, _)).
there_is_dangerous_enemy_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur").
there_is_friend_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, MyTeam, normal).

//Verify if there is some repairer at vertex Op.
there_is_repairer_at(Op) :- myTeam(MyTeam) & myNameInContest(MyName) & 
					        visibleEntity(Entity, Op, MyTeam, _) & friend(_, Entity, repairer) & MyName \== Entity.

//Get the list of vertices with the value					        
list_vertex_by_value(Value, List) :- .setof(V, ia.probedVertex(V,Value), List).

//Test if I'm the same position for a long time
is_heartbeat_goal :- stepsSamePosition(Pos, T) & step(S) & S - T > 25.

//I'm going to be repaired by someone
is_route_repaired_goal  :- gotoVertexRepair(_, _, [_|T]) & not .empty(T).

/* This rules are used to force the agent to move for a good place */
//I'm settled
//is_at_swarm_position_test :- noMoreVertexToProbe & is_at_swarm_position & is_linked_region & not is_inside_team_region.
is_at_swarm_position_test :- noMoreVertexToProbe & is_at_swarm_position & is_linked_region_weak & not is_inside_team_region_weak.

//I'm at swarm position
is_at_swarm_position :- position(Pos) & allowedArea(NeighborhoodOutside, NeighborhoodInside) & (.member(Pos, NeighborhoodOutside) | .member(Pos, NeighborhoodInside)).

//I'm inside of team region
is_inside_team_region :- 
						 (
						 	there_is_friend_more_priority
						 	|
						 	is_inside_team_friends
						 ).
						 
is_inside_team_region_weak :- 
						 (
						 	(there_is_friend_more_priority_nearby | there_is_friend_more_priority) 
						 	|
						 	is_inside_team_friends
						 ).
						 
is_inside_team_friends :- not (position(MyV) & myTeam(MyTeam) & ia.edge(MyV,V,_) & ia.vertex(V, Team) & MyTeam \== Team).
is_inside_team_region_walk :- is_inside_team_region_weak.

//I'm linked with at least 2 vertex of my team
is_linked_region :- position(MyV) & myTeam(MyTeam) &
					.setof(V, 
						   ia.edge(MyV,V,_) & ia.vertex(V, MyTeam), 
						   Options
					) & .length(Options, TotalVertexMyTeam) & TotalVertexMyTeam >= 2.
					
//I'm linked with at least 2 vertex of my team, but there are no friends there
is_linked_region_weak :- position(MyV) & myTeam(MyTeam) &
					.setof(V, 
						   ia.edge(MyV,V,_) & ia.vertex(V, MyTeam) & not visibleEntity(_, V, MyTeam, normal), 
						   Options
					) & .length(Options, TotalVertexMyTeam) & TotalVertexMyTeam >= 2.
			
//if (is_linked_region_weak | is_linked_region & not is_inside_team_region) entao OK

//There are more friends with priority at the same vertex. I'm going to wait
there_is_friend_more_priority :- position(MyV) & .my_name(MyName) & myTeam(MyTeam) & myNameInContest(MyNameContest) & 
								visibleEntity(Entity, MyV, MyTeam, normal) & MyNameContest \== Entity &
								friend(FriendName, Entity, _) &
								generalPriority(MyName, MyPriority) &
								generalPriority(FriendName, MyFriendPriority) &
								MyFriendPriority < MyPriority.
								
there_are_more_friends :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyNameContest) & 
								visibleEntity(Entity, MyV, MyTeam, normal) & MyNameContest \== Entity.
								
there_is_friend_more_priority_nearby :- position(MyV) & .my_name(MyName) & myTeam(MyTeam) & myNameInContest(MyNameContest) &
								ia.edge(MyV,V,_) & 
								visibleEntity(Entity, V, MyTeam, normal) & MyNameContest \== Entity &
								friend(FriendName, Entity, _) &
								generalPriority(MyName, MyPriority) &
								generalPriority(FriendName, MyFriendPriority) &
								MyFriendPriority < MyPriority.
								
there_are_more_friends_nearby :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyNameContest) & 
								ia.edge(MyV,V,_) & 
								visibleEntity(Entity, V, MyTeam, normal) & MyNameContest \== Entity.

is_almost_full_map :- step(S) & S > 200 & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.8.
is_almost_full_map :- step(S) & S > 100 & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.9.

is_good_map_conquered :- is_almost_full_map.
is_good_map_conquered :- step(S) & S > 200 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.32 & at_some_good_zone_score(0.34).
is_good_map_conquered :- step(S) & S > 130 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.35 & at_some_good_zone_score(0.35).
is_good_map_conquered :- step(S) & S > 80 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.38 & at_some_good_zone_score(0.35).
is_good_map_conquered :- step(S) & S > 25 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.4 & at_some_good_zone_score(0.35).

at_some_good_zone_score(Perc) :- zonesScore(Score) & zoneScore(MyZoneScore) & (MyZoneScore / Score) >= Perc.
					  
//there is enemy inside my good area
there_is_enemy_inside_my_good_area(V) :- 
									  ((visibleEntity(Entity, V, Team, normal) | ia.visibleEnemy(Entity, V)) & not friend(_, Entity, _) & (entityType(Entity, "Saboteur") | not entityType(Entity, _))) & 
									  allowedArea(NeighborhoodOutside, NeighborhoodInside) &
									  (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)).
									  
is_dangerous_entity(Entity) :- myTeam(MyTeam) & entity(Entity, _, Team, _) & Team \== MyTeam & (not entityType(Entity, _) | entityType(Entity, "Saboteur")).

get_vertex_to_go_repair_forever_alone(D, Path) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
												allowedArea(NeighborhoodOutside, NeighborhoodInside) &
											.setof(V,
												visibleEntity(Entity, V, MyTeam, _) & 
												friend(_, Entity, repairer) & Entity \== MyName &
												(.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_repair_forever_alone(D, Path) :- position(MyV)  & .my_name(MyAgentName) &
												allowedArea(NeighborhoodOutside, NeighborhoodInside) & 
												.setof(V, 
												friend(AgentName, _, repairer) & generalPriority(AgentName, Id) &
												AgentName \== MyAgentName &
												ia.getAgentPosition(Id, V) &
												(.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside))
												, List
											) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_repair_forever_alone(D, Path) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
											.setof(V,
												visibleEntity(Entity, V, MyTeam, _) & 
												friend(_, Entity, repairer) & Entity \== MyName
											,List) &
											not .empty(List) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).

get_vertex_to_go_repair_forever_alone(D, Path) :- position(MyV)  & .my_name(MyAgentName) & .setof(V, 
												friend(AgentName, _, repairer) & generalPriority(AgentName, Id) &
												AgentName \== MyAgentName &
												ia.getAgentPosition(Id, V)
												, List
											) &
											ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght).