package graphLib;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class Graph {
	public static final int INF = 10000;
	public static final int NULL = -1;
	public static final int MAXVERTICES = 1000;
	
	private int vertexCounter = 0;
	
	private Map<String, Integer> vertex2integer = new HashMap<String, Integer>();
	private Map<Integer, String> integer2vertex = new HashMap<Integer, String>();
	
	public int values[] = new int[MAXVERTICES];
	public int grade[] = new int[MAXVERTICES];
	public int w[][] = new int[MAXVERTICES][MAXVERTICES];
	public int adj[][] = new int[MAXVERTICES][MAXVERTICES];
	
	
	
	public Graph() {
		//Graph initialization
		for (int i = 0; i < MAXVERTICES; i++) {
			values[i] = 1; //Every vertex not probed has 1
			grade[i]  = 0; //The initial grade of each vertex is 0
			for (int j = 0; j < MAXVERTICES; j++) {
				w[i][j] = INF; //The initial weight of each edge if INFINITE 
			}
		}
	}
	
	private void addVertex(String vertexV) {
		if (!vertex2integer.containsKey(vertexV)) {
			vertex2integer.put(vertexV, vertexCounter);
			integer2vertex.put(vertexCounter, vertexV);
			vertexCounter++;
		}
	}
	
	public void addEdge(String vertexU, String vertexV, int weight) {
		//Add both vertex into the hashmaps
		addVertex(vertexU);
		addVertex(vertexV);
		
		//Get the id of each vertex
		int u = vertex2integer.get(vertexU);
		int v = vertex2integer.get(vertexV);
		
		//Add the weight of the edge
		w[u][v] = w[v][u] = weight;
		//Add the edge into the graph and increase the grade of each vertex
		adj[u][grade[u]++] = v;
		adj[v][grade[v]++] = u;
		
		//System.out.println("add " + u + " - " + v + " " + weight);
	}

	public void setVertexValue(String vertexV, int value) {
		//Add vertex into the hashmaps
		addVertex(vertexV);
		
		//Get the id of each vertex
		int v = vertex2integer.get(vertexV);
		
		//Update the value of the vertex
		values[v] = value;
	}
	
	public int getSize() {
		return vertexCounter;
	}
	
	public List<String> getShortestPath(String vertexS, String vertexD) {
		LinkedList<String> result = null;
		if (vertex2integer.containsKey(vertexS) && vertex2integer.containsKey(vertexD)) {
			DijkstraAlgorithm dijkstra = new DijkstraAlgorithm();
			
			int s = vertex2integer.get(vertexS);
			int d = vertex2integer.get(vertexD);
			
			List<Integer> resultDijkstra = dijkstra.execute(this, s, d);
			
			result = new LinkedList<String>();
			
			for (int i : resultDijkstra) {
				result.addFirst(integer2vertex.get(i));
			}
		}
		
		return result;
	}
	
	//This method can be deleted, it's only a sample about how to use the graph
	void sample() {
		//get the adj of some vertex
		int u = 23; //23 is the id of some vertex (to get this id use "vertex2integer.get(vertexU)", where vertexU is the name of the vertex)
		
		for (int i = 0; i < grade[u]; i++) {
			int v = adj[u][i]; //v is the id of some adj vertex of u
			
			int currentW = w[u][v]; //currentW is the weight of the edge u -> v
		}
	}
}
