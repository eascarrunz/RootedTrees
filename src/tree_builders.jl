"""
Attach `k` pre-allocated children to node `p` and repeat on its descendants up to `t` times.
`k` is increased by Δk at every forking time.
"""
function kfurcate_symmetric!(p::AbstractNode, k, i, t, tree, Δk=0)
    if t > 0
        for _ in 1:k
            i += 1
            c = tree.nodes[i]
            setlabel!(c, string(i))
            link!(p => c)
            i = kfurcate_symmetric!(c, k + Δk, i, t - 1, tree, Δk)
        end
    end

    return i
end


"""
    symmetric_tree([Type{<:AbstractTree}], n, k = 2)
    symmetric_tree([Type{<:AbstractTree}]; depth, k = 2)

Create a symmetric tree with forks of `k` degree (`k` = 2 for a dichotomic tree).

The size of the tree can be set either by the number `n` of desired outer nodes, or by the
desired `depth` d of the tree (number of nodes from the root to an outer node). The relation 
between the three parameters is

    k^d = n
    k, d, n ∈ ℕ

# Examples
```jldoctest
julia>symmetric_tree(Any, 9, k = 3)
RTree{Any}: 13 nodes
```
"""
function symmetric_tree(::Type{ND}, ::Type{BD}; depth, k=2) where {ND,BD}
    N = sum(k .^ (depth:-1:1)) + 1
    tree = createtree(ND, BD, N)
    tree.root = tree.nodes[1]
    setlabel!(tree.root, "1")
    kfurcate_symmetric!(getroot(tree), k, 1, depth, tree, 0)

    return tree
end

function symmetric_tree(::Type{ND}, ::Type{BD}, n; k = 2) where {ND,BD}
    d = log(k, n)    ## Number of times to fork terminal nodes
    isinteger(d) ||
        @error "`n` is not a natural number power of `k`"

    return symmetric_tree(ND, BD; depth = Int(d), k = k)
end

symmetric_tree(n, k=2) = symmetric_tree(Dict, Dict, n, k = k)
