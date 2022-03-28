function pretraverse(f::Function, p::AbstractRNode, x)
    x = f(p, x)
    for c in children(p)
        x = pretraverse(f, c, x)
    end

    return x
end
pretraverse(f::Function, tree::AbstractRTree, x) = pretraverse(f, getroot(tree), x)

function posttraverse(f::Function, p::AbstractRNode, x)
    for c in children(p)
        x = posttraverse(f, c, x)
    end
    x = f(p, x)

    return x
end
posttraverse(f::Function, tree::AbstractRTree, x) = posttraverse(f, getroot(tree), x)

function _set_traversal_index(p, x::NamedTuple{(:V, :i)})
    i = x.i + 1
    setindex!(x.V, p, i)

    return (V = x.V, i = i)
end
function _grow_traversal(p, x::NamedTuple{(:V, :i)})
    i = x.i + 1
    push!(x.V, p)

    return (V = x.V, i = i)
end


"""
    preorder(tree)
    preorder(node)

Return a vector with the nodes of a tree or subtree in preoder.
"""
function preorder(tree::AbstractRTree)
    V = similar(tree.nodes)
    p = getroot(tree)
    V, i = pretraverse(_set_traversal_index, p, (V=V, i=0))
    
    return V
end
preorder(p::T) where T <: AbstractRNode =
    pretraverse(_grow_traversal, p, (V=T[], i=0))[:V]


"""
    postorder(tree)
    postorder(node)

Return a vector with the nodes of a tree or subtree in preoder.
"""
function postorder(tree::AbstractRTree)
    V = similar(tree.nodes)
    p = getroot(tree)
    V, i = posttraverse(_set_traversal_index, p, (V=V, i=0))
    
    return V
end
postorder(p::T) where T <: AbstractRNode =
    posttraverse(_grow_traversal, p, (V=T[], i=0))[:V]


