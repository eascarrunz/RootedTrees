"""
    link!(p => c, l = brlength(c))

Connect a `Pair` of nodes: From `p`arent to `c`hild with a branch of length `ℓ`.
"""
function link!(pc::Pair{RNode{T},RNode{T}}, l=brlength(pc[2])) where T
    p, c = pc
    freespace = length(p.children) - outdegree(p)
    
    if freespace > 0
        p.outdegree += 1
        p.children[outdegree(p)] = c
    else
        push!(p.children, c)
    end
    c.parent = p
    brlength!(c, l)
    
    return nothing
end


"""
    cut!(c)

Disconnect a node `c` from its parent.
"""
function cut!(c::RNode)
    p = parent(c)
    ic = findfirst(==(c), p.children)
    
    deleteat!(p.children, ic)
        
    c.parent = nothing
    
    return nothing
end


"""
    swap!(c1, c2)

Exchange the parents of nodes `c1` and `c2`
"""
function swap!(c1::RNode, c2::RNode)
    p1 = parent(c1)
    p2 = parent(c2)
    ic1 = findfirst(==(c1), p1.children)
    ic2 = findfirst(==(c2), p2.children)
    
    p1.children[ic1] = c2
    p2.children[ic2] = c1
    
    c1.parent = p2
    c2.parent = p1
    
    return nothing
end


"""
    graft!(x, c, at=0.5)

Insert node `x` between node `c` and its parent.


            graft!(x, c, 0.25)

p --------> c   =========>  p ------> x --> c 
    1.0                        0.75    0.25

"""