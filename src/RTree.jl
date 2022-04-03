mutable struct RTree{ND,BD} <: AbstractRTree
    nodes::Vector{RNode{ND}}
    branches::Vector{Branch{BD}}

    root::RNode{ND}

    RTree(
        nodes::Vector{RNode{ND}}, 
        branches::Vector{Branch{BD}}
        ) where {ND,BD} =
            new{ND,BD}(nodes, branches)
end


getroot(tree::RTree) = tree.root


"""
    getnodes(tree)

Return an iterable collection with the nodes in a `tree`
"""
getnodes(tree::RTree) = tree.nodes


getnode(tree::RTree, id) = tree.nodes[id]


nnode(tree::RTree) = length(tree.nodes)


ninner(tree::RTree) = mapreduce(isinner, +, getnodes(tree))


nouter(tree::RTree) = mapreduce(isouter, +, getnodes(tree))


Base.show(io::IO, tree::T) where {T<:AbstractTree} =
    print(io, T, ": ", nnode(tree), " nodes")


#-----------------------------------------------------#


"""
    createtree([ND, BD,]n)

Create a tree with `n` nodes of data type `ND` and branches of data type `BD`.

`ND` and `BD` are `Dict` by default.
"""
function createtree(::Type{ND}, ::Type{BD}, n) where {ND, BD}
    nodes = [RNode{ND}(i) for i in 1:n]
    branches = [Branch{BD}(i) for i in 1:n]
    for c in nodes, br in branches
        c.branch = br
    end

    return RTree(nodes, branches)
end
createtree(n::Int) = createtree(Dict, Dict, n)


"""
    addnode!(tree, n=1)

Add `n` nodes to a `tree`. Return the first new node.
"""
function addnode!(tree::RTree{ND,BD}, n=1) where {ND, BD}
    i = nnode(tree)
    push!(tree.nodes, (RNode{ND}(j) for j in (i+1):(i+n))...)
    push!(tree.branches, (Branch{BD}(j) for j in (i+1):(i+n))...)
    for c in tree.nodes[i+1:i+n], br in tree.branches[i+1:i+n]
        c.branch = br
    end

    return getnode(tree, i+1)
end

