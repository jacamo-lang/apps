package env;

import graphLib.GlobalGraph;
import graphLib.Graph;
import jason.architecture.AgArch;
import jason.asSemantics.Message;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Atom;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.StringTerm;
import jason.asSyntax.Term;
import jason.asSyntax.parser.ParseException;
import jason.bb.BeliefBase;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Queue;

public class MixedAgentArch extends AgArch implements AgentListenerEvents {
    private Graph graph = new Graph();
    private GlobalGraph globalGraph = GlobalGraph.getInstance();
    private String lastStep = null;
    private Literal[] lastPercepts = null;
    
    @Override
    public void init() throws Exception {
    	CustomEISEnv.addAgentListenerEvents(getAgName(), this);
    }
    
    public Graph getGraph() {
    	return graph;
    }
    
    public void newGraph() {
    	graph = new Graph();
    }
    
    public List<Literal> perceive() {
    	List<Literal> newPercepts = super.perceive();
    	if (lastPercepts != null) {
    		newPercepts = new ArrayList<Literal>();
    		
    		String functor;
    		int maxEdges = graph.getMaxEdges();
	    	for (Literal l : lastPercepts) {
	    		functor = l.getFunctor();
	    		
	    		if (functor.equals("visibleEdge")) {
	    			if (graph.getEdges() < maxEdges) {
	    				List<Term> terms = l.getTerms();
		    			graph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(), Graph.MAXWEIGHT);
		    			globalGraph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(), Graph.MAXWEIGHT);
		    			//System.out.println("#!!!# Edge: " + terms.get(0) + " -> " + terms.get(1));
	    			}
	    			continue;
	    		} else if (functor.equals("surveyedEdge")) {
	    			List<Term> terms = l.getTerms();
	    			graph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(),  (int) ((NumberTerm) terms.get(2)).solve());
	    			globalGraph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(),  (int) ((NumberTerm) terms.get(2)).solve());
	    			//System.out.println("# surveyedEdge: " + terms.get(0) + " -> " + terms.get(1) + " W: " + terms.get(2));
	    			continue;
	    		} else if (functor.equals("visibleVertex")) {
	    			List<Term> terms = l.getTerms();
	    			if (terms.get(1) instanceof Atom) {
	    				graph.addVertex(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor());
	    			} else {
	    				graph.addVertex(((Atom) terms.get(0)).getFunctor(), ((StringTerm) terms.get(1)).getString());
	    			}
	    			//System.out.println("# visibleVertex: " + terms.get(0) + " T: " + terms.get(1) + " " + terms.get(1).getClass().getName());
	    			continue;
	    		} else if (functor.equals("vertices")) {
	    			graph.setMaxVertices((int)((NumberTerm) l.getTerm(0)).solve());
	    		} else if (functor.equals("edges")) {
	    			graph.setMaxEdges((int)((NumberTerm) l.getTerm(0)).solve());
	    		}
	    		newPercepts.add(l);
	    	}
	    	
	    	lastPercepts = null;
    	}
    	return newPercepts;
    }
    
    @Override
    public void checkMail() {
    	super.checkMail(); 
    	if (!getAgName().startsWith("explorer")) {
	    	Queue<Message> mbox = getTS().getC().getMailBox();
	    	Iterator<Message> i = mbox.iterator();
	    	
	    	while (i.hasNext()) {
	    		Message im = i.next();
	    		
	    		if (im.getPropCont().toString().startsWith("probedVertex")) {
	    			i.remove();
	    			Literal l = null;
	    			if (im.getPropCont() instanceof Literal)
	    			    l = (Literal)im.getPropCont();
                    else
                        try {
                            l = ASSyntax.parseLiteral(im.getPropCont().toString());
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }	    			
	    			Atom vertexV = (Atom) l.getTerm(0);
	    			NumberTerm value = (NumberTerm) l.getTerm(1);
	    			
	    			graph.setVertexValue(vertexV.getFunctor(), (int)value.solve());
	    		} else if (im.getPropCont().toString().startsWith("visitedVertex")) {
	    			i.remove();
                    Literal l = null;
                    if (im.getPropCont() instanceof Literal)
                        l = (Literal)im.getPropCont();
                    else
                        try {
                            l = ASSyntax.parseLiteral(im.getPropCont().toString());
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }                 
	    			Atom vertexV = (Atom) l.getTerm(0);
	    			NumberTerm step = (NumberTerm) l.getTerm(1);
	    			
	    			graph.setVertexVisited(vertexV.getFunctor(), (int)step.solve());	    			
	    		} else if (im.getPropCont().toString().startsWith("pathProposal")) {
	    			
	    		}
	    	}
    	}
    }

	public void notifyPercepts(Literal... percepts) {
		lastPercepts = percepts;
		getArchInfraTier().wake();
	}

	public void addBelief(Literal belief) {
		getTS().getAg().getBB().add(belief);
	}

}