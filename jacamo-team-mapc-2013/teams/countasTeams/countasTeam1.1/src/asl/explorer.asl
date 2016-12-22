{ include("mod.common.asl") }

!start.

/* Plans */

+!start : true <- 
	.print("hello world.");
	makeArtifact("a0","artifacts.Test",[10],Id);
	focus(Id);
	.print("Artifact created.");
	inc.
	
+count(X)
   <- .print("Count is ",X).
   
+tick
   <- .print("Tick ").