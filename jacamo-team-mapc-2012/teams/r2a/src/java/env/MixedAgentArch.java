package env;

import graphLib.Graph;
import jason.architecture.AgArch;

public class MixedAgentArch extends AgArch {
    private Graph graph = new Graph();
    
    @Override
    public void init() throws Exception {
    }
    
    public Graph getGraph() {
    	return graph;
    }
    
    public void newGraph() {
    	graph = new Graph();
    }
}