# This is designed to be called with Rscript with several arguments
# arg1: alignment 1 path
# arg2: alignment 2 path
# arg3: output alignment path

# This script concatenates two nexus alignments and outputs the concatenated
# alignment

# Get arguments
args = commandArgs(trailingOnly=TRUE)

if (!length(args) == 3) {
  stop("This script requires 2 arguments")
}

# Function for merging
mergeAlignments <- function(regular, epistatic, output) {
  # Get both alignments
  reg <- scan(regular,what=character(),sep="\n")
  epi <- scan(epistatic,what=character(),sep="\n")

  # recover()

  # Turn Rev's "standard" datatype into doublets
  epi_aln_start <- grep("Matrix",epi)+1
  epi_aln_end <- grep(";",epi)
  epi_aln_end <- min(epi_aln_end[epi_aln_end > epi_aln_start]) - 1
  epi_aln_lines <- epi_aln_start:epi_aln_end

  for (i in epi_aln_lines) {
    tmp <- strsplit(epi[i]," ")[[1]]
    nspaces <- length(grep("^$",tmp)) + 1 # We split on space, so between two spaces is a blank
    taxon <- tmp[1]
    doublets <- strsplit(tmp[4],"")[[1]]
    for (j in 1:length(doublets)) {
      if ( doublets[j] == "0" ) {
        doublets[j] <- "AA"
      } else if ( doublets[j] == "1" ) {
        doublets[j] <- "AC"
      } else if ( doublets[j] == "2" ) {
        doublets[j] <- "AG"
      } else if ( doublets[j] == "3" ) {
        doublets[j] <- "AT"
      } else if ( doublets[j] == "4" ) {
        doublets[j] <- "CA"
      } else if ( doublets[j] == "5" ) {
        doublets[j] <- "CC"
      } else if ( doublets[j] == "6" ) {
        doublets[j] <- "CG"
      } else if ( doublets[j] == "7" ) {
        doublets[j] <- "CT"
      } else if ( doublets[j] == "8" ) {
        doublets[j] <- "GA"
      } else if ( doublets[j] == "9" ) {
        doublets[j] <- "GC"
      } else if ( doublets[j] == "A" ) {
        doublets[j] <- "GG"
      } else if ( doublets[j] == "B" ) {
        doublets[j] <- "GT"
      } else if ( doublets[j] == "C" ) {
        doublets[j] <- "TA"
      } else if ( doublets[j] == "D" ) {
        doublets[j] <- "TC"
      } else if ( doublets[j] == "E" ) {
        doublets[j] <- "TG"
      } else if ( doublets[j] == "F" ) {
        doublets[j] <- "TT"
      }
    }
    epi[i] <- paste0(taxon,paste0(rep(" ",nspaces),collapse=""),paste0(doublets,collapse=""))
  }

  # Put them together (shove epistasis alignment lines after regular ones), amend number of characters
  # Turn Rev's "standard" datatype into doublets
  reg_aln_start <- grep("Matrix",reg)+1
  reg_aln_end <- grep(";",reg)
  reg_aln_end <- min(reg_aln_end[reg_aln_end > reg_aln_start]) - 1
  reg_last_lines <- reg[(reg_aln_end + 1):length(reg)]
  reg <- reg[1:reg_aln_end]
  reg <- c(reg,epi[epi_aln_lines],reg_last_lines)

  reg_char_line <- grep("nchar",reg)
  reg_nchar <- reg[reg_char_line]
  reg_nchar <- strsplit(reg_nchar,"nchar=")[[1]]
  total_nchar <- as.numeric(gsub(";","",reg_nchar[2])) + 2 * length(doublets)
  total_nchar <- paste0(reg_nchar[1],"nchar=",total_nchar,";")
  reg[reg_char_line] <- total_nchar

  reg <- gsub("Format ","Format interleave=yes ",reg)

  cat(reg, file=output, sep="\n")

}

# Call merge function
mergeAlignments(args[1], args[2], args[3])