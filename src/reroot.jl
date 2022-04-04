"""
    reroot!(tree, c)

Reroot a `tree` on node `c`.
"""
function reroot!(tree, c)
    #TODO: Handle branches
    c ≡ getroot(tree) && return nothing
    
    prev = nothing
    this = c
    brA = this.branch
    next = parent(this)
    brB = next.branch

    while true
        cut!(this)
        isnothing(prev) || link!(prev => this)
        
        prev = this
        p = parent(next)
        isnothing(p) && break
        this = next
        next = p
    end
    @assert next ≡ getroot(tree)
    link!(this => next)
    
    tree.root = c

    return nothing
end
