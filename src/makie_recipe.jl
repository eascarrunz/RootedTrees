using Makie

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