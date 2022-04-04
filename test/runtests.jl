using Test
using RootedTrees

@testset "Create tree manually" begin
    #==== Test topology:

                c1
               /
        *p ―⟶ x ―⟶ c2
        |      \
        s      c3


    * `p` is the root.

    Or as a Newick string:
    ((c1,c2,c3)x,s)p;
    ====================#
    tree = createtree(6)

    setlabel!.(getnodes(tree), ("p", "x", "c1", "c2", "c3", "s"))

    p, x, c1, c2, c3, s = getnodes(tree)

    link!(p => x)
    link!(p => s)
    link!(x => c1)
    link!(x => c2)
    link!(x => c3)

    tree.root = p

    @test newick(tree) == "((c1,c2,c3)x,s)p;"

end

@testset "Read Newick" begin
    # Example strings from Wikipedia
    test_strings = [
        "(,,(,));",                              ## no nodes are named
        "(A,B,(C,D));",                          ## leaf nodes are named
        "(A,B,(C,D)E)F;",                        ## all nodes are named
        "(:0.1,:0.2,(:0.3,:0.4):0.5);",         ## all but root node have a distance to parent
        "(:0.1,:0.2,(:0.3,:0.4):0.5):0.0;" ,     ## all have a distance to parent
        "(A:0.1,B:0.2,(C:0.3,D:0.4):0.5);",      ## distances and leaf names (popular)
        "(A:0.1, 
        B:0.2 , (C:0.3,D:0.4) : 0.5 ) ;",      ## same as above, with whitespace
        "(A:0.1,B:0.2,(C:0.3,D:0.4)E:0.5)F;",    ## distances and all names
        "((B:0.2,(C:0.3,D:0.4)E:0.5)F:0.1)A;"   ## a tree rooted on a leaf node (rare)
        ]
        
    for nwkstr in test_strings
        tree = parsenewick(nwkstr)
        @test newick(tree) == filter(! isspace, nwkstr)
    end
    
    test_string =
    "((\"B\":0.2,(\"C\":0.3,\"D\":0.4)\"E\":0.5)\"F\":0.1)A;"   ## with quote marks
    
    tree = parsenewick(test_string)
    @test newick(tree) == "((B:0.2,(C:0.3,D:0.4)E:0.5)F:0.1)A;"

end

@testset "Traversals" begin
    tree = createtree(6)

    setlabel!.(getnodes(tree), ("p", "x", "c1", "c2", "c3", "s"))
    
    p, x, c1, c2, c3, s = getnodes(tree)
    
    tree.root = p
    
    link!(p => x)
    link!(p => s)
    link!(x => c1)
    link!(x => c2)
    link!(x => c3)
    
    @test preorder(tree) == preorder(p) == [p, x, c1, c2, c3, s]
    @test preorder(x) == [x, c1, c2, c3]
    @test postorder(tree) == postorder(p) == [c1, c2, c3, x, s, p]
    @test postorder(x) == [c1, c2, c3, x]
end

@testset "Reroot" begin
    tree = createtree(6)

    setlabel!.(getnodes(tree), ("p", "x", "c1", "c2", "c3", "s"))

    p, x, c1, c2, c3, s = getnodes(tree)

    link!(p => x)
    link!(p => s)
    link!(x => c1)
    link!(x => c2)
    link!(x => c3)

    tree.root = p

    reroot!(tree, x)
    @test isnothing(parent(x))
    @test parent(p) ≡ x
    @test p ∈ children(x)
    @test c1 ∈ children(x)
    @test c2 ∈ children(x)
    @test s ∈ children(p)
end


function findnode(tree; label, which = :first)
    if which == :first
        ids = findfirst(x -> getlabel(x) == label, getnodes(tree))
    elseif which == :all
        ids = findall(x -> getlabel(x) == label, getnodes(tree))
    else
        throw(ArgumentError("invalid `which` argument"))
    end

    return isnothing(ids) ? nothing : getnode(tree, ids)
end


@testset "Reroot" begin
    tree = parsenewick("((A:4.0,B:4.0)F:2.0,(C:4.0,(D:8.0,E:8.0)G:4.0)H:2.0)I:1.0;")
    #=
    RNode{Dict}: #1 — "I"
    RNode{Dict}: #2 — "F"
    RNode{Dict}: #3 — "A"
    RNode{Dict}: #4 — "B"
    RNode{Dict}: #5 — "H"
    RNode{Dict}: #6 — "C"
    RNode{Dict}: #7 — "G"
    RNode{Dict}: #8 — "D"
    RNode{Dict}: #9 — "E"
    =#
    c = tree.nodes[6]
    d = tree.nodes[8]
    e = tree.nodes[9]
    f = tree.nodes[2]
    g = tree.nodes[7]
    h = tree.nodes[5]
    i = tree.nodes[1]

    reroot!(tree, g)

    @test Set(collect(children(g))) == Set([d, e, h])
    @test Set(collect(children(h))) == Set([i, c])
    @test Set(collect(children(i))) == Set([f])
    @test isnothing(parent(g))
    @test parent(h) ≡ g
    @test parent(i) ≡ h

    @test brlength(g) == 1.0
    @test brlength(h) == 4.0
    @test brlength(i) == 2.0
    @test brlength(f) == 2.0
end


@testset "Ancestors" begin
    #=
    Make sure that node IDs are in preorder
    =#
    tree16 = symmetric_tree(Nothing, Nothing, 16)

    @testset "path_to_root" begin
        c = getnode(tree16, 12)
        E = path_to_root(c)
        
        @test length(E) == 4
        @test all(getid.(E) .== [11, 10, 2, 1])
    end

    @testset "findmrca" begin
        #TODO: Add test for auto method selection
        #TODO: Fix method 2!
        @test 1 == findmrca(tree16, [5, 31], method = 1)
        @test 1 == findmrca(tree16, [5, 31], method = 2)
        @test 2 == findmrca(tree16, [5, 16], method = 1)
        @test_broken 2 == findmrca(tree16, [5, 16], method = 2)
        @test 25 == findmrca(tree16, [27, 31], method = 1)
        @test_broken 25 == findmrca(tree16, [27, 31], method = 2)
        @test 10 == findmrca(tree16, [12, 16], method = 1)
        @test_broken 10 == findmrca(tree16, [12, 16], method = 2)
        @test 19 == findmrca(tree16, [20, 21], method = 1)
        @test_broken 19 == findmrca(tree16, [20, 21], method = 2)

        # More than 2 targets
        @test 17 == findmrca(tree16, [20, 21, 31], method = 1)
        @test_broken 17 == findmrca(tree16, [20, 21, 31], method = 2)
        
        # Inner nodes
        @test 17 == findmrca(tree16, [19, 25, 29], method = 1)
        @test_broken 17 == findmrca(tree16, [19, 25, 29], method = 2)

    #     #=
    #     Need to decide on the behaviour of findmrca when one of the nodes is an ancestor
    #     of another (including the root!).
    #     Also: can a node be its own ancestor ?
    #     =#
    #     # Any node with the root
    #     @test_skip 0 == findmrca(tree16, [1, 25], method = 1)
    #     @test_skip 0 == findmrca(tree16, [1, 25], method = 2)
    end
    
    #! Need to define findmrca behaviour for all combinations of nodes
    # @testset "mrca_matrix" begin
    #     A = mrca_matrix(tree16)

    #     for i in 2:31
    #         for j in 1:(i-1)
    #             @test_skip A[j, i] == findmrca(tree16, [i, j])
    #         end
    #     end
    # end
end
