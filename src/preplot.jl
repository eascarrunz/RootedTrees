struct PreplottedTree
    xnode::Vector{Float64}
    ynode::Vector{Float64}
    xbranch::Vector{Float64}
    ybranch::Vector{Float64}
    labelnode::Vector{String}
    #=
    TODO: Add fields for branch ID data, colour, width
    =#
end

"""
Get X coords of all the nodes, and Y coords of the outer nodes.
"""
function _tree_coords_pass1(p, A, x, y, usebrl)
    id = getid(p)

    if usebrl
        brlen = brlength(p)
        brlen = isnothing(brlen) ? 1.0 : brlen
        x += brlen
    else
        x += 1.0
    end
    A.xnode[id] = x

    if isouter(p)
        A.ynode[id] = y
        y -= 1-0
    end
    for c in children(p)
        y = _tree_coords_pass1(c, A, x, y, usebrl)
    end

    return y
end


function _elbow_brach_coords(A, idp, idc)
    xp, yp = A.xnode[idp], A.ynode[idp]
    xc, yc = A.xnode[idc], A.ynode[idc]
    push!(A.xbranch, xp, xp, xc, NaN)
    push!(A.ybranch, yp, yc, yc, NaN)

    return nothing
end


function _straight_brach_coords(A, idp, idc)
    xp = A.xnode[idp]
    xc, yc = A.xnode[idc], A.ynode[idc]
    push!(A.xbranch, xp, xc, NaN)
    push!(A.ybranch, yc, yc, NaN)

    return nothing
end


function _tree_coords_pass2(p, A, y)
    ychildrensum = 0.0
    for c in children(p)
        y = isinner(c) ? _tree_coords_pass2(c, A, y) : A.ynode[getid(c)]
        ychildrensum += y
    end

    id = getid(p)
    nc = outdegree(p)
    y = ychildrensum / nc
    A.ynode[id] = y
    
    if nc > 1
        for (i, c) in enumerate(children(p))
            idc = getid(c)
            if ((i == 1) || (i == nc))    # Draw elbow
                _elbow_brach_coords(A, id, idc)
            else                          # Draw straight branch
                _straight_brach_coords(A, id, idc)
            end
        end
    else
        idc = getid(first(children(p)))
        _straight_brach_coords(A, id, idc)
    end

    
    return y
end

function _preplot_tree(tree, usebrl)
    # ni = number of inner nodes, no = number of outer nodes
    ni, no = mapreduce(x -> isinner(x) ? (1, 0) : (0, 1), .+, getnodes(tree))
    n = ni + no

    xnode = zeros(Float64, n)
    ynode = zeros(Float64, n)
    xbranch = Float64[]
    ybranch = Float64[]
    labelnode = getlabel.(getnodes(tree))

    # Preallocate guessing that all branches are elbows: 3 coords and NaN
    sizehint!(xbranch, 4 * n)    
    sizehint!(ybranch, 4 * n)
    
    A = PreplottedTree(xnode, ynode, xbranch, ybranch, labelnode)

    y = Float64(no)    # Start with a height (`y`) of `no`

    for c in children(getroot(tree))
        y =_tree_coords_pass1(c, A, 0.0, y, usebrl)
    end
    A.xnode[getid(getroot(tree))] = 0.0

    _tree_coords_pass2(getroot(tree), A, NaN)

    return A
end



