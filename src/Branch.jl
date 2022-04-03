mutable struct Branch{BD}
    id::IDInt
    length::Union{Nothing,Float64}
    data::Union{Nothing,BD}

    Branch{BD}(id, len=nothing) where BD = new{BD}(id, len)
end

brlength(br::Branch) = br.length

function brlength!(br::Branch, x::Union{Nothing,Float64})
    br.length = x
end

function Base.show(io::IO, br::Branch{BD}) where BD
    brl = brlength(br)
    brlstring = isnothing(brl) ? "no length" : "length" * string(round(brl, digits=3))
    print(io, "Branch{$(BD)}:", brlstring)
end
