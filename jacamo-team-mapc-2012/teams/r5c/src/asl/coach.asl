!start.


/*
 * Strategy 1: A good strategy to win the contest (rational)
 * Strategy 2: To keep our saboteurs attacking hardly
 * Strategy 3: A strategy to win the contest by forcing the enemy to buy things if their agents buy things
 */

+!start: 
	true 
<- 
	+currentStrategy(1);
	!loadAgentNames;
	.print("Agent angel loaded.").

{ include("loadAgents.asl") }


+entity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange):
	not friend(_, Entity, _) 
<-
	!processHealth(Type, Health);
	!processStrength(Type, Strength);
	.print("Receive data from entity ", Entity).
	
+!processHealth(Type, Health):
	Type == "Saboteur" & Health >= 5
<-
	+buy(Type, health).
+!processHealth(_, _): true <- true.

+!processStrength(Type, Strength):
	Type == "Saboteur" & Strength >= 5
<-
	+buy(Type, strength).
+!processStrength(_, _): true <- true.
	
+ranking(Rank):
	true
<-
	.print("Receive rank ", Rank);
	!processRank(Rank).
	
+!processRank(2):
	buy(_, strength) | buy(_, health)
<-
	.wait(300);
	.print("I lost the match, so change the strategy to 2").
	/*.send(saboteur1, achieve, setStrategy(2));
	.send(saboteur2, achieve, setStrategy(2));
	.send(saboteur3, achieve, setStrategy(2));
	.send(saboteur4, achieve, setStrategy(2)). */
	
+!processRank(2):
	true
<-
	.wait(300);
	.print("I lost the match, so change the strategy to 3").
	/*.send(saboteur1, achieve, setStrategy(3));
	.send(saboteur2, achieve, setStrategy(3));
	.send(saboteur3, achieve, setStrategy(3));
	.send(saboteur4, achieve, setStrategy(3)). */	

+!processRank(_): true <- true.

+finish:
	true
<-
	.abolish(entity(_, _, _, _, _, _, _, _, _, _));
	.abolish(ranking(_));
	.abolish(buy(_, _)).