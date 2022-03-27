import LinearAlgebra.Symmetric

"""
    path_to_root(tree, id)
    path_to_root(node)

Return the series of ancestors from a `node` to the root of the tree.
"""
function path_to_root(c::RNode)
    E = RNode[]
    while indegree(c) > 0
        p = parent(c)
        push!(E, p)
        c = p
    end
    
    return E
end
# path_to_root(tree, id) = get_id.(path_to_root(get_node(tree, id)))


"""
    anydifferent(coll, n = length(coll))

Check if at least one element in a `coll`ection is different from the others.

The length `n` of the collection can be given if it is known.
"""
function anydifferent(coll, n = length(coll))
    if n < 2
        msg = "cannot check equality with fewer than 2 elements in the collection"
        throw(ErrorException(msg))
    end
    n == 2 && return coll[1] ≠ coll[2]

    a = first(coll)
    @inbounds for i in 2:n
         a ≠ coll[i] && return true
         a = coll[i]
    end

    return false
end


function _findmrca_method1(tree, V)
    n = length(V)    # Will throw exception in `anydifferent` if n < 2
    E = path_to_root.(V)

    # anc = nothing    # Will return `nothing` if the nodes do not belong to the same tree
    anc = getroot(tree)    # Will return `nothing` if the nodes do not belong to the same tree
    for e in zip(Iterators.reverse.(E)...)
        anydifferent(e, n) && break
        anc = first(e)
    end

    # if anc ∈ V
    #     msg ="one of the nodes is the most recent common ancestor of the others"
    #     throw(ErrorException(msg))
    # end

    return anc
end


function _findmrca_method2(p, anc, list, nf, nt)   # nf = number of targets found, nt = number of targets
    nf += p ∈ list ? 1 : 0
    nfc = 0   # Number of targets found under child c
    for c in children(p)
        anc, list, nfc, nt = _findmrca_method2(c, anc, list, 0, nt)
        nf += nfc
        if nf == nt
            anc = isnothing(anc) ? p : anc   #! No longer needed depending on intended behaviour
            break
        end
    end

    return (anc, list, nf, nt)
end


"""
    findmrca(tree, list)

Return the most recent common ancestor of a `list` of nodes in a `tree`.
If a list of node IDs is given, the ID of the most recent common ancestor node is returned.
Return nothing if there is no common ancestor of all the nodes, i.e. when all the nodes do not belong to the same tree.

Warning: Having nodes repeated in the list can produce nonsensical results.
"""
function findmrca(tree, list::Vector{<:AbstractRNode}; method = :auto) where T
    #! mrca of a node and its parent is the parent of the paren!
    #TODO: Decide behaviour for cases where there are nodes in the list that are ancestral to others.
    #TODO: Run more benchmar to find a better threshold for using method 2
    n = length(list)

    if method == :auto
        if n < 64
            # Faster for small n, deep MRCA
            _findmrca_method1(tree, list)
        else
            # Faster for large n, shallow MRCA
            _findmrca_method2(getroot(tree), getroot(tree), list, 0, n)[1]
        end
    elseif method == 1
        return _findmrca_method1(tree, list)
    elseif method == 2
        return _findmrca_method2(getroot(tree), getroot(tree), list, 0, n)[1]
    else
        throw(ErrorException("invalid method \"$(method)\""))
    end
end


function findmrca(tree, list::Vector{<:Real}; method = :auto)
    anc = findmrca(tree, tree.nodes[list], method = method)

    return isnothing(anc) ? 0 : getid(anc)
end


function _fill_mrca_matrix!(p, m, n)
    foundp = falses(n)   # Descendants found under this node (start with none)

    #= The following line means that the MRCA of `p` and any of its children is `p`. Moving the 
    line under the next loop makes it so the MRCA of `p` and any of its children is `nothing`.
    This behaviour must be consistent with get_mrca. =#
    @inbounds foundp[getid(p)] = true  # Set node `p` as found

    @inbounds for c in children(p)
        foundc = _fill_mrca_matrix!(c, m, n)
        m[foundp, foundc] .= getid(p)
        foundp .|= foundc
    end

    return foundp
end

"""
    mrca_matrix(tree)

Return a symmetric square matrix where each cell [i, j] contains the ID of the most recent common ancestor of node #`i` and node#`j`.
The diagonal of the matrix contains zeros.
"""
function mrca_matrix(tree)
    #TODO: Determine how to deal with the root
    n = nnode(tree)
    m = zeros(Int, n, n)
    _fill_mrca_matrix!(getroot(tree), m, n)

    return Symmetric(m, :U)
end

function _node_depths(p, D)
    d = 0
    for c in children(p)
        dc = _node_depths(c, D)
        d = max(d, dc)
    end

    D[get_id(p)] = d

    return d + 1
end

"""
    node_depths(tree)

Return a vector with the depth of all the nodes in a `tree`. The depth of a node is the length of the longest path between it and an outer node. The depth of outer nodes is zero. The root of the tree should have the greatest depth.
"""
function node_depths(tree)
    D = zeros(Int, nnode(tree))
    _node_depths(getroot(tree), D)

    return D
end
