// Internal action code for project smadasMAPC2012

package ia;

import java.util.Iterator;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class vertex extends DefaultInternalAction {
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
        Term vertex = args[0];
        
        Term teamTerm;
        String result = graph.getTeamAtVertex(((Atom) vertex).getFunctor());
        if (result.equals("none")) {
        	teamTerm = new Atom(result);
        } else {
        	teamTerm = new StringTermImpl(result);
        }
        
        return un.unifiesNoUndo(args[1], teamTerm);
    }
}
