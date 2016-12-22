package env;

import static jason.eis.Translator.perceptToLiteral;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import eis.iilang.Percept;
import jason.JasonException;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.asSyntax.parser.ParseException;
import jason.eis.EISAdapter;

public class CustomEISEnv extends EISAdapter {
	private static Map<String, AgentListenerEvents> listeners = new HashMap<String, AgentListenerEvents>();
	private static Map<String, String> agToMassimContest = new HashMap<String, String>();
	
	public static void addAgentListenerEvents(String agName, AgentListenerEvents agArch) {
		listeners.put(agName, agArch);
		if (agToMassimContest.containsKey(agToMassimContest.get(agName)))
			agArch.addBelief(Literal.parseLiteral("myNameInContest("+agToMassimContest.get(agName)+")"));
	}
	
    @Override
    public void init(String[] args) {
        // associate agents to users
    	try {
	        for (int i=1; i<args.length; i++) {
	            Term t = ASSyntax.parseTerm(args[i]);
	            if (t.isStructure()) {
	                Structure arg = (Structure)t;
	                if (arg.getFunctor().equals("agent_entity")) {
	                    addPercept(arg.getTerm(0).toString(), Literal.parseLiteral("myNameInContest("+arg.getTerm(2).toString()+")"));
	                    agToMassimContest.put(arg.getTerm(0).toString(), arg.getTerm(2).toString());
	                }
	            }
	        }
	        
	        super.init(args);
	        
	        //startCartago();
		} catch (ParseException e) {
			e.printStackTrace();
		}
    }
    
    @Override
    protected List<Literal> addEISPercept(List<Literal> percepts, String ag) {
        return percepts;
    }
    
    public void handlePercept(String agent, Collection<Percept> percepts) {        
        try {
            clearPercepts(agent);
            Literal[] jasonPers = new Literal[percepts.size()];
            int i = 0;
            for (Percept p: percepts) {
                jasonPers[i++] = perceptToLiteral(p);
            }
            
            listeners.get(agent).notifyPercepts(jasonPers);
            //addPercept(agent, jasonPers);
            //informAgsEnvironmentChanged(agent); // wake up the agent
        } catch (JasonException e) {
            e.printStackTrace();
        }
    }
}
