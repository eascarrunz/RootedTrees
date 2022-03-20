using Test

# @testset "Create tree manually" begin
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

# end
