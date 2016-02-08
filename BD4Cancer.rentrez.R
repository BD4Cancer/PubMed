#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Script File: BD4Cancer.rentrez.R  
# Date of creation: 12 Dec 2015
# Date of last modification: 7 Feb 2016
# Author: Seraya Maouche <seraya.maouche@iscb.org>
# Project: Epidemium BD4Cancer (http://www.epidemium.cc)
# Short Description: This script provides a general introduction and tutorial to 
#                    the rentrez R package. 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

################ Install required packages
setRepositories()
install.packages("XML")       # Functions for Parsing and Generating XML Within R and S-Plus
install.packages("httr")      # Functions for Working with URLs and HTTP
install.packages("jsonlite")  # A Robust, High Performance JSON Parser and Generator for R


################ Install rentrez package
#Download rentrez: "https://cran.r-project.org/web/packages/rentrez/index.html
install.packages("rentrez")

################ Load required packages
packages <- c("XML","httr","jsonlite","rentrez")
lapply(packages, require, character.only=TRUE)

################ Getting Help 
help.start()          # General help
help(rentrez)         # Help about the function entrez_dbs
?entrez_dbs           # Same thing
apropos("entrez")     # List all functions containing string entrez
example(entrez_dbs)   # Show an example of function entrez_dbs


################ Explore NCBI databases
# 1- Retrieves the names of all databases available through the EUtils API
entrez_dbs()

# 2- Retrieve summary information about a given NCBI database
db <- "pubmed"
entrez_db_summary(db, id = NULL, config = NULL, web_history = NULL, version = c("2.0","1.0"))
# This function returns a character vector with the name of database, brief 
# description of the database, number of records contained in the database, name
# in web-interface to EUtils, a unique ID for current build of database,
# and date of last update of the database.
          
# 3- For a given database, fetch a list of other databases that contain 
# cross-referenced records. 
entrez_db_searchable("gene")
gene_searchable_fields[["GENE"]]
geneId <- entrez_search(db="gene", term="BRCA1")$ids
geneId
gene_links <- entrez_db_links("gene")
as.data.frame(gene_links )

# For the Sequence Read Archive (SRA) database, fetch list of databases that contain 
# cross-referenced records 
sra_links <- entrez_db_links("sra")
as.data.frame(sra_links)


# 4- Searching databases using entrez_search()
gene_searchable_fields <- entrez_db_searchable("gene")
gene_searchable_fields
gene_searchable_fields[["GENE"]]
# You can make use of several fields by combining them via the boolean operators AND, OR
# and NOT.
query <- "Homo[ORGN] AND BRCA1[GENE]"
r_search <- entrez_search(db="gene", query, use_history=FALSE)
r_search


# 5- Searching Pubmed
pubmed_searchable_fields <- entrez_db_searchable("pubmed")
pubmed_searchable_fields
pubmed_searchable_fields[["PDAT"]]
# Searching pubmed using a keyword
r_search <- entrez_search(db="pubmed", term="cancer", retmax=100)
names(r_search)
r_search$count
r_search$ids

# Searching pubmed by combining multiple paramerts via the boolean operators AND, OR and NOT. 
term <- "cancer"
year <- "2015"
query <- paste(term, "AND (", year, "[PDAT])")
search.res <- entrez_search(db="pubmed", query)
search.res$count


# To exclude review articles, the id [PTYP] can be used
term <- "cancer"
year <- "2015"
query <- paste(term, "AND (", year, "[PDAT])")
queryReviewExcluded <- paste(query, "NOT(", "Review","[PTYP])")
search.res <- entrez_search(db="pubmed", queryReviewExcluded)
search.res$count

# 6-  Evolution of publication in pubmed
searchByYear <- function(year, term){
    query <- paste(term, "AND (", year, "[PDAT])")
    entrez_search(db="pubmed", term=query, retmax=0)$count
}

year <- 1996:2015
papers <- sapply(year, searchByYear, term="Breast Cancer", USE.NAMES=FALSE)
plot(year, papers, type='b', col="darkblue", main="Breast Cancer Publications in Pubmed (1996-2015)",
     xlab="Year of Publication", ylab="Number of Publications")


# External links
#Using the argument "cmd", it will be possible to get, for example, 
# the full text of papers in PubMed
paperExtlinks <- entrez_link(dbfrom="pubmed", id=26455714, cmd="llinks")
paperExtlinks
paperExtlinks$linkouts
# The function  linkout_urls() can be used to extract the external links
linkout_urls(paperExtlinks)

# Summarize an XML record from pubmed
hox_paper <- entrez_search(db="pubmed", term="10.1038/nature08789[doi]")
hox_rel <- entrez_link(db="pubmed", dbfrom="pubmed", id=hox_paper$ids)
recs <- entrez_fetch(db="pubmed",
id=hox_rel$links$pubmed_pubmed[1:3],
rettype="xml")
parse_pubmed_xml(recs)

#Post IDs to Eutils for later use using the function entrez_post()
so_many_snails <- entrez_search(db="nuccore",
"Gastropoda[Organism] AND COI[Gene]", retmax=200)
upload <- entrez_post(db="nuccore", id=so_many_snails$ids)
first <- entrez_fetch(db="nuccore", rettype="fasta", web_history=upload,
retmax=10)
second <- entrez_fetch(db="nuccore", file_format="fasta", web_history=upload,
retstart=10, retmax=10)

# Download data from NCBI databases using entrez_fetch()
katipo <- "Latrodectus katipo[Organism]"
katipo_search <- entrez_search(db="nuccore", term=katipo)
kaitpo_seqs <- entrez_fetch(db="nuccore", id=katipo_search$ids, rettype="fasta")

#
Tt <- entrez_search(db="pubme", term="cancer")
tax_rec <- entrez_fetch(db="taxonomy", id=Tt$ids, rettype="xml", parsed=TRUE)
class(tax_rec

# Using NCBI’s Web History features
# When you are dealing with very large queries it can be time consuming to pass long vectors of unique IDs to
# and from the NCBI. To avoid this problem, the NCBI provides a feature called “web history” which allows users
# to store IDs on the NCBI servers then refer to them in future calls (source: package documentation).
upload <- entrez_post(db="omim", id=600807)
upload
entrez_search(db="nuccore", term="COI[Gene] AND Gastropoda[ORGN]")
snail_coi <- entrez_search(db="nuccore", term="COI[Gene] AND Gastropoda[ORGN]", use_history=TRUE)
snail_coi
snail_coi$web_history

#The functions entrez_fetch() entrez_summary() and entrez_link() can all use web_history objects in exactly the
# same way they use IDs.
asthma_snps <- entrez_link(dbfrom="omim", db="snp", cmd="neighbor_history", web_history=upload)
asthma_snps
# then summarize each linked SNP using entrez_summary()
snp_summ <- entrez_summary(db="snp", web_history=asthma_snps$web_histories$omim_snp)
knitr::kable(extract_from_esummary(snp_summ, c("chr", "fxn_class", "global_maf")))


# Example of using web_history
for( seq_start in seq(1,200,50)){
    recs <- entrez_fetch(db="nuccore", web_history=snail_coi$web_history,
                         rettype="fasta", retmax=50, retstart=seq_start)
    cat(recs, file="snail_coi.fasta", append=TRUE)
    cat(seq_start+49, "sequences downloaded\r")
}


papers_by_year <- function(years, search_term){
    return(sapply(years, function(y) entrez_search(db="pubmed",term=search_term, mindate=y, maxdate=y, retmax=0)$count))
}

# Plot number of publications by year and by cancer type.
years <- 1996:2015
total_papers <- papers_by_year(years, "")
Cancers <- c("Cancer", "Breast Cancer", "Prostate Cancer", "Lung Cancer", "Bladder cancer", 
            "Leukemia","Pancreatic Cancer","Non-Hodgkin Lymphoma","Colon Cancer","Rectal Cancer",
             "Melanoma","Thyroid Cancer","Kidney Cancer","Endometrial Cancer")
trend_data <- sapply(Cancers, function(t) papers_by_year(years, t))
trend_props <- trend_data/total_papers

library(reshape)
library(ggplot2)
trend_df <- melt(data.frame(years, trend_data), id.vars="years")
names(trend_df) <- c("Year_of_Publication","Type_of_Cancer","value")
p <- ggplot(trend_df, aes(Year_of_Publication, value, colour=Type_of_Cancer))
p + geom_line(size=1) + scale_y_log10("number of papers")
