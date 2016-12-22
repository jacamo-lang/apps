package graphLib;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class GlobalGraph {
	private static GlobalGraph globalGraph = new GlobalGraph();
	private Graph graph;
	private String positions[] = new String[21];
	private Map<String, String> positionsEnemies[] = new ConcurrentHashMap[21];
	
	private GlobalGraph() {
		graph = new Graph();
		
		for (int i = 0; i < 21; i++) {
			positions[i] = null;
			positionsEnemies[i] = new ConcurrentHashMap<String, String>();
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
			positionsEnemies[i].clear();
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
	
	public void addEnemyPosition(int id, String enemy, String vertex) {
		//System.out.println("Tentando add " + id + " e " + enemy + " a " + vertex + " " + positionsEnemies[id]);
		positionsEnemies[id].put(enemy, vertex);
	}
	
	public void remEnemyPosition(int id, String enemy) {
		//System.out.println("Tentando rem " + id + " e " + enemy + " a " + positionsEnemies[id]);
		positionsEnemies[id].remove(enemy);
	}
	
	public Map<String, String> getMapEnemiesFromId(int id) {
		return positionsEnemies[id];
	}
}

