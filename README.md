# RootedTrees

[![CI](https://github.com/eascarrunz/RootedTrees/actions/workflows/CI.yml/badge.svg)](https://github.com/eascarrunz/RootedTrees/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/eascarrunz/RootedTrees/branch/master/graph/badge.svg?token=YzxqojSzCf)](https://codecov.io/gh/eascarrunz/RootedTrees)

A small phylogenetics package for learning and experimenting with phylogenetic data 
structures and algorithms. Sometimes it's been useful for actual work too!

There is no documentation website yet, but most of the exported functions have docstrings. Here is an example of the basic functionality:

```
using RootedTrees

# Create a symmetric binary tree with 16 outer nodes
tree = symmetric_tree(16, k = 2)    # Tree of type RTree{Dict,Dict}

# Nodes are objects with a numeric ID in the tree
# Get a single node from its ID:
c = getnode(tree, 12)

# Or a vector of nodes
v = getnode(tree, [12, 4, 14])

# Is `p` an inner or an outer node?
isinner(c)    # false
isouter(c)    # true

# Nodes can have string labels. `c` was given one based on its ID.
getlabel(c)    # "12"

# Give it a more intersting label
setlabel!(c, "🐟")

# Get the length of the branch of node `c`
brlength(c)    # nothing

# The tree was generated without branch lengths. We can change that.
# Get an iterator with all the nodes of the tree with `getnode*s*`
allnodes = getnodes(tree)    # 31-element Vector{RNode{Dict}}

# Set inner branch lengths to 1.0 and outer branch lengths to 2.0
brlength!.(filter(isinner, allnodes), 1.0)
brlength!.(filter(! isinner, allnodes), 2.0)

brlength(c)   # 2.0

# Nodes and branches have `data` for storing information. It can be of any type, but it is
# `Dict` by default.

# Functions for traversing trees
preorder(tree)
postorder(tree)

# Get the most recent common ancestor of a set of nodes
findmrca(tree, v)    # RNode{Dict}: #2 — "2"

# Check the result by plotting the tree
using Plots
plotly()    # This backend works best for emoji
plot(tree)

# And get Newick representations
newick(symmetric_tree(4))   # "((3,4)2,(6,7)5)1;"
```

## Planned features

\* Code can be borrowed from a previous project.

- [x] Preorder and postorder vectors *
- [x] Reroot *
- [x] Symmetric trees
- [ ] Asymmetric trees
- [ ] Random addition trees *
- [ ] MRCA *
- [ ] Bipartitions *
- [ ] TimeTree type *
    - [ ] Birth-Death simulation
- [x] Write strict Newick strings
- [x] Read strict Newick format
- [ ] Read Newick metacomments
- [x] Plot trees in "square elbow" style
    - [x] Recipe for Makie
    - [x] Recipe for RecipesBase *
