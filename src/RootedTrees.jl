module RootedTrees

const IDInt = UInt16    # Maximum of 65535

#======================#
#         CORE
#======================#

abstract type AbstractTree end
abstract type AbstractRTree <: AbstractTree end
abstract type AbstractNode end

include("RNode.jl")
export
    brlength, brlength!,
    getlabel, setlabel!,
    parent, children,
    indegee, outdegree,
    isouter, isinner

include("RTree.jl")
export
    getroot,
    getnode, getnodes,
    nnode, ninner, nouter,
    createtree

include("link.jl")
export link!, cut!, swap!

#------end of CORE------#

include("tree_builders.jl")
export symmetric_tree

include("read_newick.jl")
export parsenewick

foo = IOBuffer("((c1,c2,c3)x,s)p;")
tree = parsenewick(foo)

test_strings = [
    "(,,(,));",                              ## no nodes are named
    "(A,B,(C,D));",                          ## leaf nodes are named
    "(A,B,(C,D)E)F;",                        ## all nodes are named
    "(:0.1,:0.2,(:0.3,:0.4):0.5);",         ## all but root node have a distance to parent
    "(:0.1,:0.2,(:0.3,:0.4):0.5):0.0;" ,     ## all have a distance to parent
    "(A:0.1,B:0.2,(C:0.3,D:0.4):0.5);",      ## distances and leaf names (popular)
    "(A:0.1, 
    B:0.2 , (C:0.3,D:0.4) : 0.5 ) ;",      ## distances and leaf names (popular)
    "(A:0.1,B:0.2,(C:0.3,D:0.4)E:0.5)F;",    ## distances and all names
    "((B:0.2,(C:0.3,D:0.4)E:0.5)F:0.1)A;"   ## a tree rooted on a leaf node (rare)
    ]

parsenewick(test_strings[1])

include("write_newick.jl")
export newick, print_newick

for str in test_strings
    tree = parsenewick(str)
    newick(tree)
end


end # module
