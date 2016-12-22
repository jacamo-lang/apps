package graphLib.observable;

import graphLib.Graph;
import java.util.ArrayList;

public class ObservableGraph extends Graph implements ISubject{

	private ArrayList<IObserver> observers;
	private String toNotify;
	

	public ObservableGraph(){
		super();
		observers = new ArrayList<IObserver>();
	}


	@Override
	public void setVertexValue(String vertexV, int value) {
		super.setVertexValue(vertexV, value);
		Boolean thereIsUnprobed = this.thereIsUnprobedVertex();		
		notifyObservers("thereIsUnprobedVertex",thereIsUnprobed.toString(),"graphLib");	
		
	}

	public void registerObserver(IObserver o){
		observers.add(o);
	}

	public void removeObserver(IObserver o){
		observers.remove(o);
	}

	
	public void notifyObservers(String functor, String atom, String source){
		for(int i=0; i<observers.size(); i++){
			IObserver observer = (IObserver)observers.get(i);
			observer.update(functor, atom, source);
		}
	}

}
