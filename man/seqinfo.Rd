\name{seqinfo}

\alias{seqinfo}
\alias{seqinfo<-}
\alias{seqnames}
\alias{seqnames<-}
\alias{seqlevels}
\alias{seqlevels,ANY-method}
\alias{seqlevels<-}
\alias{seqlevels<-,ANY-method}
\alias{sortSeqlevels}
\alias{sortSeqlevels,character-method}
\alias{sortSeqlevels,ANY-method}
\alias{seqlevelsInUse}
\alias{seqlevelsInUse,Vector-method}
\alias{seqlevelsInUse,CompressedList-method}
\alias{seqlevels0}
\alias{seqlengths}
\alias{seqlengths,ANY-method}
\alias{seqlengths<-}
\alias{seqlengths<-,ANY-method}
\alias{isCircular}
\alias{isCircular,ANY-method}
\alias{isCircular<-}
\alias{isCircular<-,ANY-method}
\alias{genome}
\alias{genome,ANY-method}
\alias{genome<-}
\alias{genome<-,ANY-method}


\title{Accessing/modifying sequence information}

\description{
  A set of generic functions for getting/setting/modifying the sequence
  information stored in an object.
}

\usage{
seqinfo(x)
seqinfo(x, new2old=NULL, force=FALSE) <- value

seqnames(x)
seqnames(x) <- value

seqlevels(x)
seqlevels(x, force=FALSE) <- value
sortSeqlevels(x, X.is.sexchrom=NA)
seqlevelsInUse(x)
seqlevels0(x)

seqlengths(x)
seqlengths(x) <- value

isCircular(x)
isCircular(x) <- value

genome(x)
genome(x) <- value
}

\arguments{
  \item{x}{
    The object from/on which to get/set the sequence information.
  }
  \item{new2old}{
    The \code{new2old} argument allows the user to rename, drop, add and/or
    reorder the "sequence levels" in \code{x}.

    \code{new2old} can be \code{NULL} or an integer vector with one element
    per row in \link{Seqinfo} object \code{value} (i.e. \code{new2old} and
    \code{value} must have the same length) describing how the "new" sequence
    levels should be mapped to the "old" sequence levels, that is, how the
    rows in \code{value} should be mapped to the rows in \code{seqinfo(x)}.
    The values in \code{new2old} must be >= 1 and <= \code{length(seqinfo(x))}.
    \code{NA}s are allowed and indicate sequence levels that are being added.
    Old sequence levels that are not represented in \code{new2old} will be
    dropped, but this will fail if those levels are in use (e.g. if \code{x}
    is a \link[GenomicRanges]{GRanges} object with ranges defined on those
    sequence levels) unless \code{force=TRUE} is used (see below).

    If \code{new2old=NULL}, then sequence levels can only be added to the
    existing ones, that is, \code{value} must have at least as many rows
    as \code{seqinfo(x)} (i.e. \code{length(values) >= length(seqinfo(x))})
    and also \code{seqlevels(values)[seq_len(length(seqlevels(x)))]} must be
    identical to \code{seqlevels(x)}.
  }
  \item{force}{
    Force dropping sequence levels currently in use. This is achieved by
    dropping the elements in \code{x} where those levels are used (hence
    typically reducing the length of \code{x}).

    Note that if \code{x} is a list-like object (e.g.
    \link[GenomicRanges]{GRangesList},
    \link[GenomicAlignments]{GAlignmentPairs}, or
    \link[GenomicAlignments]{GAlignmentsList}), then any list element in
    \code{x} where at least one of the sequence levels to drop is used is
    \emph{fully} dropped. In other words, the \code{seqlevels} setter always
    keeps or drops \emph{full list elements} and never tries to change their
    content. This guarantees that the geometry of the list elements is
    preserved, which is a desirable property when they represent compound
    features (e.g. exons grouped by transcript or paired-end reads).
    See below for an example.
  }
  \item{value}{
    Typically a \link{Seqinfo} object for the \code{seqinfo} setter.

    Either a named or unnamed character vector for the \code{seqlevels}
    setter.

    A vector containing the sequence information to store for the other
    setters.
  }
  \item{X.is.sexchrom}{
    A logical indicating whether X refers to the sexual chromosome
    or to chromosome with Roman Numeral X. If \code{NA}, \code{sortSeqlevels}
    does its best to "guess".
  }
}

\details{
  The \link{Seqinfo} class plays a central role for the functions described
  in this man page because:

  \itemize{
  \item All these functions (except \code{seqinfo}, \code{seqlevelsInUse},
        and \code{seqlevels0}) work on a \link{Seqinfo} object.

  \item For classes that implement it, the \code{seqinfo} getter should
        return a \link{Seqinfo} object.

  \item Default \code{seqlevels}, \code{seqlengths}, \code{isCircular},
        and \code{genome} getters and setters are provided.
        By default, \code{seqlevels(x)} does \code{seqlevels(seqinfo(x))},
        \code{seqlengths(x)} does \code{seqlengths(seqinfo(x))},
        \code{isCircular(x)} does \code{isCircular(seqinfo(x))},
        and \code{genome(x)} does \code{genome(seqinfo(x))}.
        So any class with a \code{seqinfo} getter will have all the above
        getters work out-of-the-box. If, in addition, the class defines
        a \code{seqinfo} setter, then all the corresponding setters will
        also work out-of-the-box.

        Examples of containers that have a \code{seqinfo} getter and setter:
        the \link[GenomicRanges]{GRanges}, \link[GenomicRanges]{GRangesList},
        and \link[GenomicRanges]{SummarizedExperiment} classes in the
        \pkg{GenomicRanges} package;
        the \link[GenomicAlignments]{GAlignments},
        \link[GenomicAlignments]{GAlignmentPairs},
        and \link[GenomicAlignments]{GAlignmentsList} classes in the
        \pkg{GenomicAlignments} package;
        the \link[GenomicFeatures]{TxDb} class in the
        \pkg{GenomicFeatures} package;
        the \link[BSgenome]{BSgenome} class in the
        \pkg{BSgenome} package; etc...
      }

      The \pkg{GenomicRanges} package defines \code{seqinfo} and
      \code{seqinfo<-} methods for these low-level data types:
      \code{List}, \code{RangesList} and \code{RangedData}. Those
      objects do not have the means to formally store sequence
      information. Thus, the wrappers simply store the \code{Seqinfo}
      object within \code{metadata(x)}. Initially, the metadata
      is empty, so there is some effort to generate a reasonable
      default \code{Seqinfo}. The names of any \code{List} are
      taken as the \code{seqnames}, and the \code{universe} of
      \code{RangesList} or \code{RangedData} is taken as the
      \code{genome}.
}

\note{
  The full list of methods defined for a given generic can
  be seen with e.g. \code{showMethods("seqinfo")} or
  \code{showMethods("seqnames")} (for the getters),
  and \code{showMethods("seqinfo<-")} or \code{showMethods("seqnames<-")}
  (for the setters aka \emph{replacement methods}).
  Please be aware that this shows only methods defined in packages
  that are currently attached.
}

\author{H. Pages}

\seealso{
  \itemize{
    \item The \link{seqlevelsStyle} generic getter and setter.

    \item \link{Seqinfo} objects.

    \item \link[GenomicRanges]{GRanges}, \link[GenomicRanges]{GRangesList},
          and \link[GenomicRanges]{SummarizedExperiment} objects in the
          \pkg{GenomicRanges} package.

    \item \link[GenomicAlignments]{GAlignments},
          \link[GenomicAlignments]{GAlignmentPairs},
          and \link[GenomicAlignments]{GAlignmentsList} objects in the
          \pkg{GenomicAlignments} package.

    \item \link[GenomicFeatures]{TxDb} objects in the
          \pkg{GenomicFeatures} package.

    \item \link[BSgenome]{BSgenome} objects in the \pkg{BSgenome} package.

    \item \link{seqlevels-wrappers} for convenience wrappers to the
          \code{seqlevels} getter and setter.

    \item \code{\link{rankSeqlevels}}, on which \code{sortSeqlevels} is
          based.
  }
}

\examples{
## ---------------------------------------------------------------------
## A. MODIFY THE SEQLEVELS OF AN OBJECT
## ---------------------------------------------------------------------
## Overlap and matching operations between objects require matching
## seqlevels. Often the seqlevels in one must be modified to match 
## the other. The seqlevels() function can rename, drop, add and reorder 
## seqlevels of an object. Examples below are shown on TxDb 
## and GRanges but the approach is the same for all objects that have
## a 'Seqinfo' class.

library(TxDb.Dmelanogaster.UCSC.dm3.ensGene)
txdb <- TxDb.Dmelanogaster.UCSC.dm3.ensGene
seqlevels(txdb)

## Rename:
seqlevels(txdb) <- sub("chr", "", seqlevels(txdb))
seqlevels(txdb)

seqlevels(txdb) <- paste0("CH", seqlevels(txdb))
seqlevels(txdb)

seqlevels(txdb)[seqlevels(txdb) == "CHM"] <- "M"
seqlevels(txdb)

gr <- GRanges(rep(c("chr2", "chr3", "chrM"), 2), IRanges(1:6, 10))

## Add:
seqlevels(gr) <- c("chr1", seqlevels(gr), "chr4")
seqlevels(gr)
seqlevelsInUse(gr)

## Reorder:
seqlevels(gr) <- rev(seqlevels(gr))
seqlevels(gr)

## Drop all unused seqlevels:
seqlevels(gr) <- seqlevelsInUse(gr)

## Drop some seqlevels in use:
seqlevels(gr, force=TRUE) <- setdiff(seqlevels(gr), "chr3")
gr

## Rename/Add/Reorder:
seqlevels(gr) <- c("chr1", chr2="chr2", chrM="Mitochondrion")
seqlevels(gr)

## ---------------------------------------------------------------------
## B. DROP SEQLEVELS OF A LIST-LIKE OBJECT
## ---------------------------------------------------------------------

grl0 <- GRangesList(GRanges("chr2", IRanges(3:2, 5)),
                    GRanges("chr5", IRanges(11, 18)),
                    GRanges(c("chr4", "chr2"), IRanges(7:6, 15)))
grl0

grl1 <- grl0
seqlevels(grl1, force=TRUE) <- c("chr2", "chr5")
grl1  # grl0[[3]] was fully dropped!

## If what is desired is to drop the first range in grl0[[3]] only, or,
## more generally speaking, to drop the ranges within each list element
## that are located on one of the seqlevels to drop, then do:
grl2 <- grl0[seqnames(grl0) \%in\% c("chr2", "chr5")]
grl2

## Note that the above subsetting doesn't drop any seqlevel:
seqlevels(grl2)

## To drop them (no need to use 'force=TRUE' anymore):
seqlevels(grl2) <- c("chr2", "chr5")
seqlevels(grl2)

## ---------------------------------------------------------------------
## C. SORT SEQLEVELS IN "NATURAL" ORDER
## ---------------------------------------------------------------------

sortSeqlevels(c("11", "Y", "1", "10", "9", "M", "2"))

seqlevels <- c("chrXI", "chrY", "chrI", "chrX", "chrIX", "chrM", "chrII")
sortSeqlevels(seqlevels)
sortSeqlevels(seqlevels, X.is.sexchrom=TRUE)
sortSeqlevels(seqlevels, X.is.sexchrom=FALSE)

seqlevels <- c("chr2RHet", "chr4", "chrUextra", "chrYHet",
               "chrM", "chrXHet", "chr2LHet", "chrU",
               "chr3L", "chr3R", "chr2R", "chrX")
sortSeqlevels(seqlevels)

gr <- GRanges()
seqlevels(gr) <- seqlevels
sortSeqlevels(gr)

## ---------------------------------------------------------------------
## D. SUBSET OBJECTS BY SEQLEVELS
## ---------------------------------------------------------------------

tx <- transcripts(txdb)
seqlevels(tx)

## Drop 'M', keep all others.
seqlevels(tx, force=TRUE) <- seqlevels(tx)[seqlevels(tx) != "M"]
seqlevels(tx)

## Drop all except 'ch3L' and 'ch3R'.
seqlevels(tx, force=TRUE) <- c("ch3L", "ch3R")
seqlevels(tx)

## ---------------------------------------------------------------------
## E. RESTORE ORIGINAL SEQLEVELS OF A TxDb OBJECT
## ---------------------------------------------------------------------

## Applicable to TxDb objects only.
\dontrun{
seqlevels(txdb) <- seqlevels0(txdb)
seqlevels(txdb)
}

## ---------------------------------------------------------------------
## F. FINDING METHODS
## ---------------------------------------------------------------------

showMethods("seqinfo")
showMethods("seqinfo<-")

showMethods("seqnames")
showMethods("seqnames<-")

showMethods("seqlevels")
showMethods("seqlevels<-")

if (interactive()) {
  library(GenomicRanges)
  ?`GRanges-class`
}
}

\keyword{methods}
