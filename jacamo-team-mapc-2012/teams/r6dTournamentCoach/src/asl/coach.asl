!start.

/*
 * Strategy 1: Try buy!
 * Strategy 2: Do not buy!
 */

+!start: 
	true 
<- 
	!loadAgentNames;
	.print("Agent coach loaded.").

{ include("loadAgents.asl") }

+entity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange, S):
	not friend(_, Entity, _) 
<-
	!processHealth(Team, Type, Health, S);
	!processStrength(Team, Type, Strength, S);
	!sendMeStrategy(Team);
	-entity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange, S).
	//.print("Receive data from entity ", Entity, " of team ", Team, " of type ", Type, " with Health ", Health, " and Strength ", Strength).
	
+!processHealth(Team, Type, Health, S):
	Type == "Saboteur" & Health >= 4
<-
	//.print("Team ", Team, " buy health");
	-~buy(Team, Type, health);
	+buy(Team, Type, health).
+!processHealth(Team, Type, Health, S):
	Type == "Saboteur" & Health <= 3 & not buy(Team, Type, health) & S > 300
<-
	//.print("Team ", Team, " do not buy health");
	+~buy(Team, Type, health).
+!processHealth(_, _, _, _): true <- true.

+!processStrength(Team, Type, Strength, S):
	Type == "Saboteur" & Strength >= 4
<-
	//.print("Team ", Team, " buy strength");
	-~buy(Team, Type, strength);
	+buy(Team, Type, strength).
+!processStrength(Team, Type, Strength, S):
	Type == "Saboteur" & Strength <= 3 & not buy(Team, Type, strength) & S > 300
<-
	//.print("Team ", Team, " do not buy strength");
	+~buy(Team, Type, strength).
+!processStrength(_, _, _, _): true <- true.
	
+ranking(Rank):
	true
<-
	true.
	//.print("Receive rank ", Rank).
	
+!sendMeStrategy(Team):
	buy(Team, _, _) | not ~buy(Team, _, _)
<-
	//.print("Sending strategy 1 X");
	!sendStrategy(1).
	
+!sendMeStrategy(Team):
	simEnd(Team) & ~buy(Team, _, _) & not buy(Team, _, _)
<-
	//.print("Sending strategy 2 X");
	!sendStrategy(2).
	
+!sendMeStrategy(Team):
	true
<-
	//.print("Sending strategy 1 Y");
	!sendStrategy(1).
	
+!sendStrategy(Strategy):
	true
<-
	//.print("Sending strategy ", Strategy);
	.send(saboteur1, achieve, setStrategy(Strategy));
	.send(saboteur2, achieve, setStrategy(Strategy));
	.send(saboteur3, achieve, setStrategy(Strategy));
	.send(saboteur4, achieve, setStrategy(Strategy)).
	
+!setSimEnd(Team):
	true
<-
	//.print("Received simEnd!");
	+simEnd(Team).
