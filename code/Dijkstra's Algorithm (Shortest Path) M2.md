# Dijkstra's Algorithm (Shortest Path)
An implementation of Dijkstra's algorithm to find the shortest path in a graph.
```
:N g !           // Pop the graph from the stack
  u 0 !          // Initialize u (index) to 0
  g /S (         // Loop over all nodes in the graph
    u g ? d < (  // If the node at index u has a smaller distance
      u g !      // Update u to be the new minimum
    )
    u 1 + u !    // Increment u
  )
  u !            // Return the index of the minimum distance node
;

:D g ! s ! d !   // Pop the graph, start node, and distances from the stack
  d ! v /F !     // Initialize distances and visited nodes
  g /S (         // Loop over all nodes in the graph
    N m !        // Get the minimum distance node using N
    m u !        // Update distances of neighboring nodes
  )
  d .            // Print the shortest path
;
```

# Example of Calling the Function:
```
[ 0 7 9 0 0 14 0 0 10 15 0 11 0 6 ] g !  // Graph (Adjacency matrix)
[ 0 999 999 999 999 ] d !               // Distances (start at 0, others infinity)
0 s !                                   // Start node is 0
g s d D                                 // Call Dijkstra's algorithm
```
# Explanation:
- Graph: `[ 0 7 9 0 0 14 0 0 10 15 0 11 0 6 ]` represents an adjacency matrix.
-Distances: `[ 0 999 999 999 999 ]` represents the distances from the start node to all other nodes,
  - initialized with infinity (or a large value) except the start node (which is 0).
- Start Node: `s = 0` sets the start node to 0.
