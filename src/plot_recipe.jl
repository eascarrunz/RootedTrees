using RecipesBase

@recipe function f(tree::RTree; usebrl = true, showlabels = true, shownodes = false)

    A = RootedTrees._preplot_tree(tree, usebrl)

    grid --> false
    legend --> false
    yaxis := false
    yticks := false
    xaxis --> false
    xticks --> false

    @series begin
        label := "Branches"
        linecolor --> :black
        seriestype := :path
        x = A.xbranch
        y = A.ybranch

        x, y
    end

    if shownodes
        @series begin
            label := "Nodes"
            seriestype := :scatter
            x = A.xnode
            y = A.ynode
    
            x, y
        end
    end

    if showlabels
        treelabels = getlabel.(getnodes(tree))

        # Find suitable label offset `dx`
        dx = extrema(A.xnode)
        dx = 0.025 * (dx[2] - dx[1])

        @series begin
            markersize := 0
            series_annotations := [(lab, 10, :left) for lab in treelabels] 
            textcolor --> :black
            seriestype := :scatter
            x = A.xnode .+ dx
            y = A.ynode
    
            x, y
        end
    end

    ()
end
