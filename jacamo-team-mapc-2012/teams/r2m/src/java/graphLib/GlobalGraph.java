package graphLib;

import ia.synchronizeGraph;

public class GlobalGraph {
	private static GlobalGraph globalGraph = new GlobalGraph();
	private Graph graph;
	
	private GlobalGraph() {
		graph = new Graph();
	}
	
	public static GlobalGraph getInstance() {
		return globalGraph;
	}
	
	public synchronized void reset() {
		graph = new Graph();
	}
	
	public synchronized void addEdge(String vertexU, String vertexV, int weight) {
		graph.addEdge(vertexU, vertexV, weight);
	}
	
	public Graph getGraph() {
		return graph;
	}
}
