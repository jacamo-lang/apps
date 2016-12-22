// The repairers don't import these rules

//If I'm disabled and there is a repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal :- is_disabled & position(MyV) & myTeam(MyTeam) & 
		       edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer).
//If I'm disabled and there is a repairer at the same vertex, so I'm going to wait
is_wait_repair_goal :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
		       visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer) & Entity \== MyName.
