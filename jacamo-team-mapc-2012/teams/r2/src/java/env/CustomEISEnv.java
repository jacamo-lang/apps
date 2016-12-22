package env;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import static jason.eis.Translator.perceptToLiteral;

import eis.EILoader;
import eis.EnvironmentListener;
import eis.iilang.EnvironmentState;
import eis.iilang.Parameter;
import eis.iilang.Percept;

import jason.JasonException;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.asSyntax.parser.ParseException;
import jason.eis.EISAdapter;
import jason.eis.Translator;

public class CustomEISEnv extends EISAdapter {
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
	                }
	            }
	        }
	        
	        super.init(args);
		} catch (ParseException e) {
			e.printStackTrace();
		}
    }
	
    @Override
    protected List<Literal> addEISPercept(List<Literal> percepts, String ag) {
        return percepts;
    }
}
