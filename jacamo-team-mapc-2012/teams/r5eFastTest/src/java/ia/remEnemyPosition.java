// Internal action code for project smadasMAPC2012

package ia;

import graphLib.GlobalGraph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class remEnemyPosition extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        
    	GlobalGraph graph = GlobalGraph.getInstance();
    	
    	int id = (int) ((NumberTerm) args[0]).solve();
    	String enemy = args[1].toString();
    	graph.remEnemyPosition(id, enemy);
    	
        return true;
    }
}
