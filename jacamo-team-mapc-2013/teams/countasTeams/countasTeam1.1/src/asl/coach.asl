{ include("mod.loadAgents.asl") }

finishes(0).

!start.

+!start <- 
    .my_name(Me);
	
	!!loadAgentNames;

	/* Starting count-as stuff */
	cartago.new_obj("countas4cartago.RuleEngine",[],Id); 
    setWSPRuleEngine(Id);
	makeArtifact("countasArt","countas4cartago.CountAs_Artifact",[Id],CountAsArt);  
    focus(CountAsArt);	 	
	addProgram("src/org/mapc.countas"); //load the count-as program
    startGui; //start the count-as graphical user interface


	
	makeArtifact(grMain,"ora4mas.nopl.GroupBoard",["src/org/org.xml", team, false, true ],IDGrMain);
	setOwner(Me);
	focus(IDGrMain);
	+gr(grMain, IDGrMain);
	
	/* *** moved to count-as *** 
    adoptRole(leader)[artifact_id(IDGrMain)];  
 	!callFriendsToJoinGroup*/
      .

	  
/* If all agents are joined to the group, I can start the scheme */
+formationStatus(ok)[artifact_name(_,"grMain")] <-
	!setupScheme.
	
+!setupScheme <-
	!run_scheme(schDiscoverMap);
	!callFriendsToAttendScheme.
	
+!run_scheme(S): gr(grMain,IDGrMain) <- 
    makeArtifact(S,"ora4mas.nopl.SchemeBoard",["src/org/org.xml", discoverMap, false, true ],SchArtId);
	focus(SchArtId);
	
    /* Moved to count-as
    +sch(S,SchArtId);	
	addScheme(S)[artifact_id(IDGrMain)]; */
	
	.print("The scheme is on."). 
	
-!run_scheme(S)[error(I),error_msg(M)] <- .print("Failed to create scheme ",S," -- ",I,": ",M).
	
/* Call agents to join the group */
/* *** Moved to count-as ***
   +!callFriendsToJoinGroup <-
	.send([explorer1, explorer2, explorer3, explorer4, explorer5], achieve, adoptRole(explorer, grMain));
	.send(explorer6, achieve, adoptRole(explorerLeader, grMain));
	
	.send([sentinel1, sentinel2, sentinel3, sentinel4, sentinel5], achieve, adoptRole(sentinel, grMain));
	.send(sentinel6, achieve, adoptRole(sentinelLeader, grMain));
	
	.send([inspector1, inspector2, inspector3, inspector4, inspector5], achieve, adoptRole(inspector, grMain));
	.send(inspector6, achieve, adoptRole(inspectorLeader, grMain));
	
	.send([repairer1, repairer2, repairer3, repairer4, repairer5], achieve, adoptRole(repairer, grMain));
	.send(repairer6, achieve, adoptRole(repairerLeader, grMain));
	
	.send([saboteur1, saboteur2, saboteur3], achieve, adoptRole(saboteur, grMain));
	.send(saboteur4, achieve, adoptRole(saboteurLeader, grMain)).
*/
	
/* Call agents to attend the scheme */
+!callFriendsToAttendScheme <-
	.send([
		   explorer1, explorer2, explorer3, explorer4, explorer5, explorer6,
		   sentinel1, sentinel2, sentinel3, sentinel4, sentinel5, sentinel6,
		   inspector1, inspector2, inspector3, inspector4, inspector5, inspector6,
		   repairer1, repairer2, repairer3, repairer4, repairer5, repairer6,
		   saboteur1, saboteur2, saboteur3, saboteur4
	      ], 
		achieve, attendScheme(schDiscoverMap)
	).
	
/* The round finished for all agentes */
@countFinish[atomic]
+!countFinish: 
	finishes(N)
<-
    .print(N+1);
	-+finishes(N+1).

+finishes(N): .count(friend(_, _, _, _), N) & sch(S, SchArtId) & gr(Group, GroupArtId)
<-
	-+finishes(0);
    .print("All agents finished! ", Group);
    removeScheme(S)[artifact_id(GroupArtId)]; 
	disposeArtifact(SchArtId);
	//.broadcast(achieve, focusGroupArtifact(Group));
	!setupScheme.

/*+simEnd: 
	.count(friend(_, _, _, _), NAgents) & .findall(N,simEnd[source(_)],NEnds) & .length(NEnds, NAgents)
	& sch(S,SchArtId) & gr(Group, _)
<-
    .abolish(simEnd); //Nao funciona
    .print("All agents finished! ", Group);
	disposeArtifact(SchArtId);
	.broadcast(achieve, focusGroupArtifact(Group));
	!setupScheme. */

+!focusGroupArtifact.
