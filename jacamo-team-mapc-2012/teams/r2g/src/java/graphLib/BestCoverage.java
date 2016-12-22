package graphLib;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class BestCoverage {
	private int queue[] = new int[301];
	private boolean white[] = new boolean[301];
	private int depth[] = new int[301];
	private boolean alive[] = new boolean[301];
	
	public List<Integer> execute(Graph g, int d) {
		ArrayList<Integer> list = new ArrayList<Integer>();
		
		int best = Graph.NULL;
		int vBest = Graph.NULL;
		int fbegin;
		int fend;
		int u;
		int currentValue;
		
		for (int i = 0; i <= g.getSize(); i++) {
			alive[i] = true;
		}
		
		for (int i = 0; i <= g.getSize(); i++) {
			
			if (alive[i]) {
				for (int j = 0; j <= g.getSize(); j++) {
					white[j] = true;
				}
				
				fbegin = 0;
				fend = 0;
				currentValue = 0;
				alive[i] = false;
				
				queue[fend++] = i;
				depth[i] = 0;
				white[i] = false;
				
				while (fbegin < fend) {
					u = queue[fbegin++];
					
					if (depth[u] <= d) {
						currentValue+=g.values[u];
					} else {
						break;
					}
					
					for (int j = 0; j < g.grade[u]; j++) {
						int v = g.adj[u][j];
						if (white[v]) {
							white[v] = false;
							depth[v] = depth[u]+1;
							queue[fend++] = v;
						}
					}
				}
				
				if (currentValue > vBest) {
					vBest = currentValue;
					best = i;
				}
			}
			
		}
		
		
		if (best != Graph.NULL) {
			list.add(best);
			list.add(vBest);
		}
		return list;
	}
}
