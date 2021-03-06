// Internal action code for project smadasMAPC2012

package ia;

import env.MixedAgentArch;
import graphLib.GlobalGraph;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class resetGraph extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        
        arch.newGraph();
        GlobalGraph.getInstance().reset();
        
        return true;
    }
}
