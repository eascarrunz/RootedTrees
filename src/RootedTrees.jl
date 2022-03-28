module RootedTrees

const IDInt = UInt16    # Maximum of 65535

#======================#
#         CORE
#======================#

abstract type AbstractTree end
abstract type AbstractRTree <: AbstractTree end
abstract type AbstractNode end
abstract type AbstractRNode <: AbstractNode end

export AbstractTree
export AbstractRTree
export AbstractNode
export AbstractRNode

include("RNode.jl")
export
    RNode,
    getid,
    brlength, brlength!,
    getlabel, setlabel!,
    parent, children,
    indegree, outdegree,
    isouter, isinner

include("RTree.jl")
export
    RTree,
    getroot,
    getnode, getnodes,
    nnode, ninner, nouter,
    createtree

include("link.jl")
export link!, cut!, swap!

#------end of CORE------#

include("tree_builders.jl")
export symmetric_tree

include("traverse.jl")
export
    pretraverse, posttraverse,
    preorder, postorder

include("reroot.jl")
export reroot!

include("ancestors.jl")
export
    path_to_root,
    findmrca,
    mrca_matrix

include("read_newick.jl")
export parsenewick

include("write_newick.jl")
export newick, print_newick

include("preplot.jl")

include("plot_recipe.jl")
export plot, plot!

end # module
