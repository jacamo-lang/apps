package graphLib.observable;

import graphLib.observable.IObserver;

public interface ISubject{
	/*public void registerObserver(IObserver o); */
	public void removeObserver(IObserver o);
	public void notifyObservers(String functor, String atom, String source);
}
