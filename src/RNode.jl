mutable struct RNode{ND} <: AbstractRNode
    id::IDInt
    label::String
    brlength::Union{Nothing,Float64}
    parent::Union{Nothing,RNode{ND}}
    children::Vector{RNode{ND}}
    data::Union{Nothing,ND}

    RNode{T}(id = 0, label="", brlength=nothing) where T =
        new{T}(id, label, brlength, nothing, RNode{T}[], nothing)
end


"""
    getid(p)

Return the ID of a node `p`.
"""
getid(p::RNode) = p.id


brlength(c::RNode) = c.brlength
function brlength!(c::RNode, l)
    c.brlength = l
end


"""
    getlabel(c)

Get or set the label string of node `c`.
"""
getlabel(c::RNode) = c.label


"""
    setlabel!(c, label)

Set the label of node `c`.
"""
function setlabel!(c::RNode, s)
    c.label = s
end


"""
    parent(c)

Return the parent of node `c`.
"""
Base.parent(c::RNode) = c.parent    #! Hacky importing from Base


"""
    children(p)

Return an iterator of the children of node `p`.
"""
children(p::RNode) = p.children


indegree(c::RNode) = isnothing(c.parent) ? 0 : 1


outdegree(p::RNode) = length(p.children)


isouter(c::RNode) = isempty(c.children)


isinner(p::RNode) = ! isempty(p.children)


function Base.show(io::IO, p::T) where {T<:RNode}
    labelstr = isempty(p.label) ? "" : " — \"" * p.label * '\"'
    print(io, T, ": #", p.id, labelstr)
end

