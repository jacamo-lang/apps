package graphLib;

import java.util.LinkedList;
import java.util.List;

public class Neighborhood {
    private int queue[] = new int[301];
    private boolean white[] = new boolean[301];
    private int depth[] = new int[301];
    
    public List<Integer> execute(Graph g, int s, int d) {
        List<Integer> list = new LinkedList<Integer>();
        
        int fbegin;
        int fend;
        int u;
        
        for (int j = 0; j <= g.getSize(); j++) {
            white[j] = true;
        }
        
        fbegin = 0;
        fend = 0;
        
        queue[fend++] = s;
        depth[s] = 0;
        white[s] = false;
        list.add(s);
        
        
        u = s;
        for (int j = 0; j < g.grade[u]; j++) {
            int v = g.adj[u][j];
            if (white[v] && g.values[u] == g.values[v]) {
                white[v] = false;
                depth[v] = 0;
                queue[fend++] = v;
                list.add(v);
            }
        }
        
        int average = g.getAverageVertex();
        if (average >= 6)
            average = 5;
        int aveTwo = (int) (average + 0.9 * average + 0.4);
        int aveOne = (int) (average + 2);
        int v;
        int j;
        
        while (fbegin < fend) {
            u = queue[fbegin++];
            
            if (depth[u] > d + 1) {
                break;
            } else if (depth[u] > d) {
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v] && g.values[v] >= aveTwo) {
                        list.add(v);
                    }
                }
            } else if (depth[u] == d) {
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v] && g.values[v] >= aveOne) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                        list.add(v);
                    }
                }
            } else {
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v]) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                        list.add(v);
                    }
                }
            }
        }
            
        return list;
    }
    
    public void execute(Graph g, int s, int borderOut, int borderIn, List<Integer> listBorder, List<Integer> insideArea) {
        int fbegin;
        int fend;
        int u;
        
        for (int j = 0; j <= g.getSize(); j++) {
            white[j] = true;
        }
        
        fbegin = 0;
        fend = 0;
        
        queue[fend++] = s;
        depth[s] = 0;
        white[s] = false;
        insideArea.add(s);
        
        
        u = s;
        for (int j = 0; j < g.grade[u]; j++) {
            int v = g.adj[u][j];
            if (white[v] && g.values[u] == g.values[v]) {
                white[v] = false;
                depth[v] = 0;
                queue[fend++] = v;
                listBorder.add(v);
            }
        }
        
        int average = g.getAverageVertex();
        if (average >= 6)
            average = 5;
        int aveTwo = (int) (average + 0.9 * average + 0.4);
        int aveOne = (int) (average + 2);
        int v;
        int j;
        
        while (fbegin < fend) {
            u = queue[fbegin++];
            
            if (depth[u] > borderOut + 1) {
                break;
            } else if (depth[u] > borderOut) {
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v] && g.values[v] >= aveTwo) {
                        listBorder.add(v);
                    }
                }               
            } else if (depth[u] == borderOut) {
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v] && g.values[v] >= aveOne) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                        listBorder.add(v);
                    }
                }
            } else {
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v]) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                        
                        if (depth[v] <= borderIn) {
                            insideArea.add(v);
                        } else {
                            listBorder.add(v);
                        }
                    }
                }
            }
        }
    }
}
