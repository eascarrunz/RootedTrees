"""
Get X coords of all the nodes, and Y coords of the outer nodes.
"""
function _tree_coords_pass1(p, A, x, y, usebrl)
    id = getid(p)

    x += usebrl ? brlength(p) : 1.0
    A.x[id] = x

    if isouter(p)
        A.y[id] = y
        y -= 1-0
    end
    for c in children(p)
        y = _tree_coords_pass1(c, A, x, y, usebrl)
    end

    return y
end


function _elbow_brach_coords(A, B, idp, idc)
    xp, yp = A.x[idp], A.y[idp]
    xc, yc = A.x[idc], A.y[idc]
    push!(B.x, xp, xp, xc, NaN)
    push!(B.y, yp, yc, yc, NaN)

    return nothing
end


function _straight_brach_coords(A, B, idp, idc)
    xp = A.x[idp]
    xc, yc = A.x[idc], A.y[idc]
    push!(B.x, xp, xc, NaN)
    push!(B.y, yc, yc, NaN)

    return nothing
end


function _tree_coords_pass2(p, A, B, y)
    ychildrensum = 0.0
    for c in children(p)
        y = isinner(c) ? _tree_coords_pass2(c, A, B, y) : A.y[getid(c)]
        ychildrensum += y
    end

    id = getid(p)
    nc = outdegree(p)
    y = ychildrensum / nc
    A.y[id] = y
    
    if nc > 1
        for (i, c) in enumerate(children(p))
            idc = getid(c)
            if ((i == 1) || (i == nc))    # Draw elbow
                _elbow_brach_coords(A, B, id, idc)
            else                          # Draw straight branch
                _straight_brach_coords(A, B, id, idc)
            end
        end
    else
        idc = getid(first(children(p)))
        _straight_brach_coords(A, B, id, idc)
    end

    
    return y
end

function _tree_coords(tree, usebrl)
    # ni = number of inner nodes, no = number of outer nodes
    ni, no = mapreduce(x -> isinner(x) ? (1, 0) : (0, 1), .+, getnodes(tree))
    y = Float64(no)    # Start with a height (`y`) of `no`
    A = (x = zeros(Float64, ni + no), y = zeros(Float64, ni + no))    # Node coordinates
    B = (x = Float64[], y = Float64[])                                  # Branch coordinates
    sizehint!(B.x, 4 * (ni + no))    # Guess that all branches are elbows = 3 coords and NaN
    sizehint!(B.y, 4 * (ni + no))    # Guess that all branches are elbows = 3 coords and NaN

    for c in children(getroot(tree))
        y =_tree_coords_pass1(c, A, 0.0, y, usebrl)
    end
    A.x[getid(getroot(tree))] = 0.0

    _tree_coords_pass2(getroot(tree), A, B, NaN)

    return A, B
end

tree_theme = Makie.Theme(
                Lines = (
                    color = :red,
                ),
                Axis = (
                    leftspinevisible = false,
                    rightspinevisible = false,
                    bottomspinevisible = false,
                    topspinevisible = false,
                    xticksvisible = false,
                    yticksvisible = false,
                    xlabelsvisible = false,
                    ylabelsvisible = false,
                    gridvisible = false,
                )
            )

@Makie.recipe(TreePlot, tree) do scene
    # default = tree_theme
    Makie.Attributes(;
        color = :black,
        labels = :all,
        labeloffset = 0,
        branchwidth = 1,
        usebrlength = true,
    )
end

Makie.plottype(::RTree) = TreePlot


function Makie.plot!(plt::TreePlot)
    tree = plt[:tree][]

    A, B = _tree_coords(tree, plt[:usebrlength][])

    x, y = A
    xline, yline = B

    branchwidth = plt[:branchwidth][]
    Makie.lines!(plt, xline, yline, linewidth=branchwidth, color = plt[:color][])
    labelmode = plt[:labels][]
    labeloffset = plt[:labeloffset][]
    if labelmode == :all
        pltlabels = getlabel.(tree.nodes)
        Makie.text!(plt, pltlabels, position = Point.(x, y), align = (:left, :center), space=:screen)
    end
    # hidedecorations!(plt[Axis])

    return plt
end

