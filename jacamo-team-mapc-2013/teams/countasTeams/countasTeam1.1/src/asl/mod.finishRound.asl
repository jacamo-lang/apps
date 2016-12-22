/* Finish a round */
@simEndP1[atomic]
+simEnd[source(percept)]:
    true 
<-
    !finishSimulation.
    
+!finishSimulation:
    .my_name(MyName) & friend(MyName, MyNameContest, _, _)
<-
    .print("Contest finished!"); 
    !resetSystem;
    !loadAgentNames;
    +myNameInContest(MyNameContest);
    .send(coach, achieve, countFinish).
    
+!resetSystem:
    true
<-
    .abolish(_); // clean all BB
    ia.resetGraph;
    .drop_all_intentions;
    .drop_all_desires.
	
+bye <- .stopMAS.