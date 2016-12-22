// The explorers don't import these rules

/*
 * Choose the vertex to go that it isn't visited by any of my friends. The vertex wasn't visited yet.
 * TODO: maybe this rule have to be different. Some entities have to regard enemies.
 */
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF & not visitedVertex(V, _),Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(TotalOptions), Options, Op).

/*
 * Choose the vertex to go that I know the cost of the edge
 */
is_good_destination(Op) :- position(MyV) & infinite(INF) &
						   .setof(V, edge(MyV,V,W) & W \== INF, Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(.length(Options)), Options, Op).
						   
/*
 * By this time, I don't have any option to go!
 * I choose randomly
 */
is_good_destination(Op) :- position(MyV) & 
						   .setof(V, edge(MyV,V,_), Options)
						   & .length(Options, TotalOptions) & TotalOptions > 0 &
						   .nth(math.random(.length(Options)), Options, Op).
						    
