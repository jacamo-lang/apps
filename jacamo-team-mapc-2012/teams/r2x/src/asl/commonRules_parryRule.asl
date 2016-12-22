/*
 * If I'm at some vertex with an enemy saboteur, so I count how many friends are there too.
 * I choose to leave or to parry using probability.
 * The probability to execute parry is: 1.0 / N, where N is the amount of friends
 */
is_parry_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) &
		 Team \== MyTeam & entityType(Entity, "Saboteur") &
		 .count(visibleEntity(_, MyV, MyTeam, normal), N) &
		 .random(K) & K <= (1.0 / N).

