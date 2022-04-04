"""
    reroot!(tree, c)

Reroot a `tree` on node `c`.

If the current root has a branch, that branch will be attached to `c` after rerooting.
"""
function reroot!(tree, c)
    c ≡ getroot(tree) && return nothing

    br_root = getroot(tree).branch
    
    prev = nothing
    this = c
    next = parent(this)
    brA = this.branch
    
    while true
        cut!(this)
        if ! isnothing(prev)
            link!(prev => this)
        end
        brB = this.branch
        this.branch = brA
        brA = brB

        prev = this
        p = parent(next)
        isnothing(p) && break
        this = next
        next = p
    end
    @assert next ≡ getroot(tree)
    link!(this => next)
    next.branch = brA
    
    tree.root = c
    tree.root.branch = br_root

    return nothing
end
