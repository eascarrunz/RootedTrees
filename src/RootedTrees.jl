module RootedTrees

const IDInt = UInt16    # Maximum of 65535

#======================#
         CORE
#======================#

abstract type AbstractTree end
abstract type AbstractRTree <: AbstractTree end

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

include("newick.jl")
export newick, print_newick


end # module
