```@meta
CurrentModule = Oscar
CollapsedDocStrings = true
DocTestSetup = Oscar.doctestsetup()
```

# Graphs

## Introduction

Graphs are a fundamental object within all of mathematics and computer science.
A *graph* consists of two sets of data:

- a finite set $V := \{1,\ldots,n\}$ of *vertices*; and
- a finite set $E \subseteq V\times V$ of *edges*.

There are two types of graphs, *directed* and *undirected*. For a *directed
graph* the elements of $E$ are considered to be ordered pairs, for an
*undirected graph* the elements of $E$ are unordered pairs or rather sets with
two elements.

The interface is modeled alongside the
[Graphs.jl](https://juliagraphs.org/Graphs.jl/dev/) interface to
allow for easier integration elsewhere.

!!! warning
    The mechanism for removing a vertex is slightly different in out
    implementation to the `Graphs.jl` implementation: In `Graphs.jl` first
    the vertex to be removed is swapped with the last vertex, then the last
    vertex is removed. In our implementation, the vertex is removed and all
    subsequent vertices have their labels changed. Hence edges can be different
    in the two implementations after removing a vertex.

## Construction

```@docs
graph(::Type{T}, nverts::Int64) where {T <: Union{Directed, Undirected}}
dual_graph(p::Polyhedron)
vertex_edge_graph(p::Polyhedron; modulo_lineality=false)
graph_from_adjacency_matrix
graph_from_edges
graph_from_labeled_edges
```

### Modifying graphs
```@docs
add_edge!(g::Graph{T}, source::Int64, target::Int64) where {T <: Union{Directed, Undirected}}
add_vertices!(g::Graph{T}, n::Int64) where {T <: Union{Directed, Undirected}}
add_vertex!(g::Graph{T}) where {T <: Union{Directed, Undirected}}
rem_edge!(g::Graph{T}, s::Int64, t::Int64) where {T <: Union{Directed, Undirected}}
rem_vertex!(g::Graph{T}, v::Int64) where {T <: Union{Directed, Undirected}}
rem_vertices!(g::Graph{T}, a::AbstractVector{Int64}) where {T <: Union{Directed, Undirected}}
label!
```

## Auxiliary functions
```@docs
adjacency_matrix(g::Graph)
all_neighbors(g::Graph{T}, v::Int64) where {T <: Union{Directed, Undirected}}
automorphism_group_generators(g::Graph{T}) where {T <: Union{Directed, Undirected}}
connectivity(g::Graph{Undirected})
complete_graph(n::Int64)
complete_bipartite_graph(n::Int64, m::Int64)
degree(g::Graph, v::Int)
indegree(g::Graph{Directed}, v::Int)
outdegree(g::Graph{Directed}, v::Int)
vertices(g::Graph{T}) where {T <: Union{Directed, Undirected}}
edges(g::Graph{T}) where {T <: Union{Directed, Undirected}}
has_edge(g::Graph{T}, source::Int64, target::Int64) where {T <: Union{Directed, Undirected}}
has_vertex(g::Graph{T}, v::Int64) where {T <: Union{Directed, Undirected}}
laplacian_matrix(g::Graph)
n_edges(g::Graph{T}) where {T <: Union{Directed, Undirected}}
n_vertices(g::Graph{T}) where {T <: Union{Directed, Undirected}}
inneighbors(g::Graph{T}, v::Int64) where {T <: Union{Directed, Undirected}}
neighbors(g::Graph{T}, v::Int64) where {T <: Union{Directed, Undirected}}
outneighbors(g::Graph{T}, v::Int64) where {T <: Union{Directed, Undirected}}
shortest_path_dijkstra
signed_incidence_matrix(g::Graph)
is_isomorphic(g1::Graph{T}, g2::Graph{T}) where {T <: Union{Directed, Undirected}}
is_isomorphic_with_permutation(G1::Graph, G2::Graph)
is_bipartite(g::Graph{Undirected})
maximal_cliques(g::Graph{Undirected})
labelings(G::Graph)
```

### Edges
```@docs
dst(e::Edge)
reverse(e::Edge)
src(e::Edge)
```

### Visualization
```@docs
visualize(G::Graph{Union{Polymake.Directed, Polymake.Undirected}}; backend::Symbol=:threejs, filename::Union{Nothing, String}=nothing, kwargs...)
```
## Saving and loading

Objects of type `Graph` can be saved to a file and loaded with the methods
`load` and `save`.  The file is in JSON format and contains the underlying
polymake object. In particular, this file can now be read by both polymake and
OSCAR.

## Quantum Automorphisms
```@docs
quantum_automorphism_group(G::Graph{Undirected})
```
