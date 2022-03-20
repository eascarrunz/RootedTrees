mutable struct RTree{ND} <: AbstractRTree
    nodes::Vector{RNode{ND}}

    root::RNode{ND}

    RTree(nodes::Vector{RNode{ND}}) where {ND} = new{ND}(nodes)
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
    createtree([ND, ]n)

Create a tree with `n` nodes of data type `ND`.
"""
function createtree(::Type{ND}, n) where ND
    nodes = [RNode{ND}(i) for i in 1:n]

    return RTree(nodes)
end
createtree(n::Int) = createtree(Dict, n)


"""
    addnode!(tree, n=1)

Add `n` nodes to a `tree`. Return the ID of the first new node.
"""
function addnode!(tree::RTree{D}, n=1) where D
    i = nnode(tree)
    push!(tree.nodes, (RNode{D}(j) for j in (i+1):(i+n))...)

    return i+1
end

