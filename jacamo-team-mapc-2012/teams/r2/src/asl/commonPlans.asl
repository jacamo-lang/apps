+simStart
<-
	.print("Contest started!").
   
+simEnd 
<- 
	.abolish(_); // clean all BB
	.drop_all_desires.

+!init_goal(G): 
	money(M) & step(S) & position(V) & energy(E) & maxEnergy(Max) & lastActionResult(Result) & score(Score) & health(Health)
<- 
	.print("I am at ",V," (",E,"/",Max,"), my health is ", Health, " the goal for step ",S," is ",G, " and I have ", M, " of money. My last result was ", Result, ". The score is ", Score);
	!G.
      
+!init_goal(_)
<- 
	.print("No step yet... wait a bit");
    .wait(500);
	!select_goal.
	
+!survey:
	true
<- 
	.print("Surveying");
	!do(survey).

+!recharge: 
	energy(MyE)
<- 
	.print("My energy is ",MyE,", recharging");
    !do(recharge).
    
+!goto(Op):
	maxEnergy(MaxE) & position(MyV) & edge(MyV, Op, W) & W > MaxE //I have to buy more batteries 
	&  
	money(MyM) & costBattery(CostBattery) & MyM >= CostBattery //And I have money to buy one
<-
	.print("My max energy is ", MaxE, " but I need ", W);
	!do(buy(battery)). //firstly, I'm going to buy a new battery.
	
+!goto(Op):
	maxEnergy(MaxE) & position(MyV) & edge(MyV, Op, W) & W > MaxE //I have to buy more batteries and I don't have enough money
<-
	.print("My max energy is ", MaxE, " but I need ", W, " and I don't have money");
	!recharge. //TODO I have to choose an alternative: In order to don't lose a step, I choose recharge 
	
+!goto(Op):
	energy(MyE) & position(MyV) & edge(MyV, Op, W) & W > MyE //That's too expensive
<-
	.print("My current energy is ", MyE, " but I need ", W);
	!recharge. //firstly, I'm going to recharge.
	
+!goto(Op):
	position(MyV) //I can go!
<-
	.print("My current vertex is ", MyV, " and I'm going to' ", Op);
	!do(goto(Op)).
	
+!skip:
	true
<- 
   .print("Nothing to do");
   !do(skip).
   
// the following plan is used to send only one action each cycle
+!do(Act): 
	step(S)
<- 
	Act. // perform the action (i.e., send the action to the simulator)
    //!wait_next_step(S). // wait for the next step before going on
   
+!wait_next_step(S)  : step(S+1).
+!wait_next_step(S) <- .wait( { +step(_) }, 500, _); !wait_next_step(S).
   
//###### Percepts ###### 
/* Percept a new step */
+step(S):
	true 
<- 
	.print("Current step is ", S);
	//skip.
	!select_goal.
	
/* Percepts Position */
@position1[atomic]	
+position(V):
	currentPosition(VOld) & step(S)
<-
	-visitedVertex(V, _);
	+visitedVertex(V, S);
	-lastPosition(_);
	+lastPosition(VOld);
	-currentPosition(_);
	+currentPosition(V).
	
@position2[atomic]	
+position(V):
	not (lastPosition(_) | currentPosition(_)) & step(S)
<-
	-visitedVertex(V, _);
	+visitedVertex(V, S);
	+lastPosition(V);
	+currentPosition(V).
	
/* Percepts Edge */
@surveyedEdge1[atomic]
+surveyedEdge(U, V, W): 
	true 
<-
	//.print("Surveyed edge: ", U, " ", V, " ", W);
	-edge(U, V, _); -edge(V, U, _);
	+edge(U, V, W); +edge(V, U, W). 

@visibleEdge1[atomic]
+visibleEdge(U, V):
	not edge(U, V, _) & infinite(INF)
<-
	//.print("New edge: ", U, " ", V);
	+edge(U, V, INF); +edge(V, U, INF).
	
/* Percepts Entity */
@visibleEntity1[atomic]
+visibleEntity(Entity, V, Team, Status):
	myNameInContest(Entity) & not myTeam(_)
<-
	+myTeam(Team).
	
@visibleEntity2[atomic]
+visibleEntity(Entity, V, Team, Status):
	true
<-
	-entity(Entity, Team, _, _);
	+entity(Entity, Team, V, Status).

//Initialize the beliefs every time when the agent enter in the environment
@myName1[atomic]
+myNameInContest(MyName):
	true
<-
	+infinite(10000);
	
	+costBattery(100);
	+costShield(100);
	+costSabotageDevice(100);
	+costSensor(100);
	
	+minEnergy(2); //2 is the safe minimum to allow the agent to execute actions
	+myNameInContest(MyName);
	!init.