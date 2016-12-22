!start.

+!start: .my_name(MyName) <- 
	!loadAgentNames;
	?friend(MyName, MyNameContest, _, _);
	+myNameInContest(MyNameContest).
	
