package graphLib2countas;

import graphLib.GlobalGraph;
import graphLib.observable.IObserver;
import graphLib.observable.ObservableGraph;
import jason.RevisionFailedException;
import jason.asSyntax.Literal;
import jason.asSyntax.parser.ParseException;
import static jason.asSyntax.ASSyntax.parseLiteral;
import static jason.asSyntax.ASSyntax.createAtom;
import static jason.asSyntax.ASSyntax.createLiteral;
import countas.CountAsEngine;
import countas.exception.CountAs_ObservableStateException;


public class GraphLib2Countas implements IObserver{
	CountAsEngine engine;
	private GlobalGraph globalGraph = GlobalGraph.getInstance();
	private String currentThereIsUnprobedVertex = null; //current value of thereIsUnprobedVertex 

	public GraphLib2Countas(CountAsEngine engine){
                System.out.println("[GraphLib2Countas] instantiating..");
		this.engine = engine;
		((ObservableGraph)globalGraph.getGraph()).registerObserver(this);
		//globalGraph.getGraph().registerObserver(this);
	}


	@Override
	public void update(String functor, String atom, String source) {
		if(functor.equals("thereIsUnprobedVertex")){
			if(!atom.equals(currentThereIsUnprobedVertex)){
				Literal prop = createProp(functor, atom, source);
				try {
					if(currentThereIsUnprobedVertex==null){					
						engine.addProp(prop);						
					}
					else{
						engine.updateProp(prop);
					}
					currentThereIsUnprobedVertex = atom;
				} catch (CountAs_ObservableStateException e) {
					e.printStackTrace();
				} catch (RevisionFailedException e) {
					e.printStackTrace();
				} catch (ParseException e) {
					e.printStackTrace();
				}
			}


		}
	}
	private Literal createProp(String functior, String atom, String source){
		
		Literal l = createLiteral(functior, createAtom(atom));
		l.addSource(createAtom(source));
		return l;
	}




}
