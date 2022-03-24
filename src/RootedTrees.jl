module RootedTrees

using Requires

const IDInt = UInt16    # Maximum of 65535

#======================#
#         CORE
#======================#

abstract type AbstractTree end
abstract type AbstractRTree <: AbstractTree end
abstract type AbstractNode end

include("RNode.jl")
export
    getid,
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

function __init__()
    @require Makie="ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a" begin
        using Makie

        include("plot.jl")
        export plot, plot!
    end
end

end # module
