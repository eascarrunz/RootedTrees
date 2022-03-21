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
end


