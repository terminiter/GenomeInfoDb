### =========================================================================
### Convenience wrappers to the seqlevels() getter and setter
### -------------------------------------------------------------------------

keepSeqlevels <- function(x, value)
{
    value <- unname(value)
    if (any(nomatch <- !value %in% seqlevels(x)))
        warning("invalid seqlevels", 
                paste(sQuote(value[nomatch]), collapse=", "), "were ignored")
    if (is(x, "BSgenome"))
        stop("seqlevels cannot be dropped from a BSgenome object")
    force <- is(x, "Seqinfo")
    seqlevels(x, force=!force) <- value[!nomatch]
    x
}

dropSeqlevels <- function(x, value)
{
    value <- unname(value)
    if (any(nomatch <- !value %in% seqlevels(x)))
        warning("invalid seqlevels", 
                paste(sQuote(value[nomatch]), collapse=", "), "were ignored")
    if (is(x, "BSgenome"))
        stop("seqlevels cannot be dropped from a BSgenome object")
    force <- is(x, "Seqinfo")
    seqlevels(x, force=!force) <- seqlevels(x)[!seqlevels(x) %in% value]
    x
}

renameSeqlevels <- function(x, value)
{
    nms <- names(value)
    ## unnamed
    if (is.null(nms)) {
        if (length(value) != length(seqlevels(x)))
            stop("unnamed 'value' must be the same length as seqlevels(x)")
        names(value) <- seqlevels(x)
    ## named
    } else {
        if (any(nomatch <- !nms %in% seqlevels(x)))
            warning("invalid seqlevels ", 
                    paste(sQuote(nms[nomatch]), collapse=", "), " ignored")
        if (length(value) != length(seqlevels(x))) {
            level <- seqlevels(x)
            idx <- match(level, nms)
            level[!is.na(idx)] <- value[na.omit(idx)]
            value <- level
        } 
    } 
    seqlevels(x) <- value 
    x 
}

## Currently applies to TxDb only.
restoreSeqlevels <- function(x)
{
    seqlevels(x) <- seqlevels0(x) 
    x
}

keepStandardChromosomes <- function(x, species=NULL)
{
    ori_seqlevels <- seqlevels(x)
    
    if(length(ori_seqlevels)==0)
        return(x)
    
    ans <- .guessSpeciesStyle(ori_seqlevels)
    
    if(length(ans)==1){
        if(is.na(ans)){
            ## Interanally the seqlevels did not match any organism's style - so
            ## drop all levels and return an empty object
            return(dropSeqlevels(x, seqlevels(x)))
        }
    }
    
    style <- unique(ans$style)
    standard_chromosomes <- character(0)
    
    if(missing(species))
    {
        ## 1- find compatible species based on style of Seqinfo object
        ## 2- extract seqlevels for all compatible species. 
        ## 3- intersect, find how many species have some seqlevels as original?
        allspecies <- names(genomeStyles())
        
        compatibility_idx <- sapply(genomeStyles(),
                                    function(y) style %in% colnames(y))
        compatible_species <- names(compatibility_idx)[compatibility_idx]
        allseqlevels <- lapply(compatible_species,
                               function(y) extractSeqlevels(y, style)) 
                
        mres <- sapply(allseqlevels, function(y) intersect(y, ori_seqlevels))
        
        standard_chromosomes <- unique(unlist(mres))
        standard_chromosomes <- 
            ori_seqlevels[which(ori_seqlevels %in% standard_chromosomes)]
        
        if(length(standard_chromosomes) == 0 )
            stop("Cannot determine standard chromosomes, Specify species arg")
        
    }else{
        standard_chromosomes <- extractSeqlevels(species, style)
        standard_chromosomes <- intersect(ori_seqlevels,standard_chromosomes)
    }
    
    #x <- keepSeqlevels(x,standard_chromosomes)
    seqlevels(x,force=TRUE) <- standard_chromosomes 
    return(x)
    
}

