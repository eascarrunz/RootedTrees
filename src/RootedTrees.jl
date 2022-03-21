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

include("write_newick.jl")
export newick, print_newick


end # module
