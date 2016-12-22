package graphLib;

import ia.synchronizeGraph;

public class GlobalGraph {
	private static GlobalGraph globalGraph = new GlobalGraph();
	private Graph graph;
	public String positions[] = new String[21];
	
	private GlobalGraph() {
		graph = new Graph();
		
		for (int i = 0; i < 21; i++) {
			positions[i] = null;
		}
	}
	
	public static GlobalGraph getInstance() {
		return globalGraph;
	}
	
	public synchronized void reset() {
		if (graph.getEdges() > 0)
			graph = new Graph();
		for (int i = 0; i < 21; i++) {
			positions[i] = null;
		}		
	}
	
	public synchronized void addEdge(String vertexU, String vertexV, int weight) {
		graph.addEdge(vertexU, vertexV, weight);
	}
	
	public Graph getGraph() {
		return graph;
	}
	
	public String getPosition(int id) {
		return positions[id];
	}
	
	public void setPosition(int id, String pos) {
		positions[id] = pos;
	}
}

