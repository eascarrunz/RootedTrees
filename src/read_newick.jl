const NEWICK_DELIM = ('(', ')', ',', ':', ';')
const COMMENT_DELIM = ('[', ']')
const ALL_DELIMS = union(NEWICK_DELIM, COMMENT_DELIM)

"""
Count the number of nodes in a Newick stream
"""
function _countnodes(io)

    #TODO: Use this function for pre-allocating the node vector of the tree
    #? Could use a `getfreenode` function that returns an unlinked node in the node vector
    #? or a new node created with `addnode!`

    #* The logic below could be simplified using `skipchars`

    i = 0
    chr = peek(io, Char)
    while chr ≠ ';'
        i += ((chr == '(') | (chr == ',')) ? 1 : 0
        chr = read(io, Char)
    end

    return i
end


"""
Read IO until any character in a collection of delimiters is found.
"""
function _readuntilany(io, delimset)

    #TODO: Re-implement this method using `skipchars`

    s = ""
    chr = peek(io, Char)
    while chr ∉ delimset
        s *= read(io, Char)
        chr = peek(io, Char)
    end

    return s
end


"""
Check that `query` is the current character in a IOStram, and read it. Raise exception if 
it isn't. 
"""
function _readconfirm(io, query)
    chr = read(io, Char)
    if chr != query
        throw(ErrorException("expected \'$(query)\' but got \'$(chr)\'"))
    end

    return nothing
end


function _parsetext(io)
    _whiteslurp(io)
    chr = peek(io, Char)
    if chr == '\"'
        read(io, Char)            # Read opening quote mark
        s = readuntil(io, '\"')   # Read string
    elseif chr == '\''
        read(io, Char)
        s = readuntil(io, '\'')
    else
        s = _readuntilany(io, ALL_DELIMS)
    end
    
    return s
end

function _parsebranch(io)
    #TODO: Check for a comment here
    _readconfirm(io, ':')
    s = _readuntilany(io, ALL_DELIMS)

    return isempty(s) ? nothing : parse(Float64, s)
end

function _parseouter(io::IO, tree)

    #? All this could just be included in `_parsechild`

    labelstr = _parsetext(io)
    _whiteslurp(io)
    chr = peek(io, Char)
    #TODO: Check for a comment here
    if chr == ':'
        brlen =  _parsebranch(io)
    else
        brlen = nothing
    end

    c = addnode!(tree, 1)
    setlabel!(c, labelstr)
    brlength!(c, brlen)
    
    return c
end

function _parsechild(io, tree)
    chr = peek(io, Char)
    if chr == '('
        c = _parseinner(io, tree)
    else
        c = _parseouter(io, tree)
    end
    #TODO: Check for a comment here
    
    return c
end

function _parseinner(io::IO, tree)
    _readconfirm(io, '(')
    _whiteslurp(io)
    
    p = addnode!(tree, 1)
    
    chr = peek(io, Char)   #? Not necessary
    c = _parsechild(io, tree)
    link!(p => c)
    _whiteslurp(io)
    chr = peek(io, Char)
    
    while chr == ','
        _readconfirm(io, ',')    # Eat the comma
        _whiteslurp(io)
        c = _parsechild(io, tree)
        link!(p => c)
        _whiteslurp(io)
        chr = peek(io, Char)
    end
    
    _readconfirm(io, ')')
    
    labelstr = _parsetext(io)
    chr = peek(io, Char)
    brlen = chr == ':' ? _parsebranch(io) : nothing
    
    setlabel!(p, labelstr)
    brlength!(p, brlen)
    
    return p
end

_whiteslurp(io) = skipchars(isspace, io)

function parsenewick(io::IO)
    tree = createtree(0)

    _whiteslurp(io)
    tree.root = _parseinner(io, tree)
    _whiteslurp(io)

    #TODO: Check for a comment here
    
    _readconfirm(io, ';')

    return tree
end

parsenewick(s::String) = parsenewick(IOBuffer(s))

