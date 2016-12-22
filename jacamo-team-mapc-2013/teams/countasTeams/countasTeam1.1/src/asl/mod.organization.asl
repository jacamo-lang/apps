/* Organization Plans */

+!adoptRole(Role, Group) <-
	lookupArtifact(Group, IDGrGroup);
	focus(IDGrGroup);
	+gr(Group, IDGrGroup).
	/* *** moved to count-as *** 
	adoptRole(Role) [artifact_id(IDGrGroup)];   
	.print("Adopted role ", Role, " in ", Group)
	*/
	
+!attendScheme(S) <-
	lookupArtifact(S, SchArtId);
	focus(SchArtId);
	+sch(S,SchArtId);
	.print("Attending scheme ", S).
	
+!quit_mission(M,S) <-
	leaveMission(M) [artifact_name(S)].
	
/*	moved to count-as
+obligation(Ag,Norm,committed(Ag,Mission,Scheme),DeadLine): 
	.my_name(Ag)

<- 
	.print("I am obliged to commit to ",Mission);
    commitMission(Mission)[artifact_name(Scheme)].*/
  
	
+obligation(Ag,Norm,achieved(Scheme,Goal,Ag),DeadLine): 
	.my_name(Ag)
<- 
	.print("I am obliged to achieve goal ", Goal);
	!Goal.
	//goalAchieved(Goal)[artifact_name(Scheme)].
	
+obligation(Ag,Norm,What,DeadLine): 
	.my_name(Ag)
<- 
   	.print("I am obliged to", What, ", but I don't know what to do!").
   	
+!g1 <- .print("Going to achieve g1").
+!g2 <- .print("Going to achieve g2").
+!g3 <- .print("Going to achieve g3"). 

+!focusGroupArtifact(Group) <-
	lookupArtifact(Group, IDGrGroup);
	focus(IDGrGroup);
	+gr(Group, IDGrGroup).
