// energy lower than the minimum energy allowed
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.

// some edge to adjacent vertex is not surveyed
is_survey_goal :- position(MyV) & 
				  (
				  	infinite(INF) & ia.edge(MyV,_,INF)
				  |	
				    maxWeight(MAXWEIGHT) & ia.edge(MyV,_,MAXWEIGHT)
				  ).

// test if the agent is disabled
is_disabled :- health(MyHealth) & MyHealth <= 0.

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

//Verify if there is some repairer at vertex Op.
there_is_repairer_at(Op) :- myTeam(MyTeam) & myNameInContest(MyName) & 
					        visibleEntity(Entity, Op, MyTeam, _) & friend(_, Entity, repairer) & MyName \== Entity.

//Get the list of vertices with the value					        
list_vertex_by_value(Value, List) :- .setof(V, ia.probedVertex(V,Value), List).

//Test if I'm the same position for a long time
is_heartbeat_goal :- stepsSamePosition(Pos, T) & step(S) & S - T > 25.

//I'm going to be repaired by someone
is_route_repaired_goal  :- gotoVertexRepair(_, _, [_|T]) & not .empty(T).
