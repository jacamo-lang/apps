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

