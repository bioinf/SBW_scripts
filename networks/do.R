library(GAM)
library(igraph)
# Reading differential expression table for genes
gene.de <- read.csv("/data/SBW2016/networks/M0_vs_M1.gene.tsv", header=T, sep="\t", stringsAsFactors=F)
head(gene.de)

# Reading differential expression table for metabolites
met.de <- read.csv("/data/SBW2016/networks/M0_vs_M1.met.tsv", header=T, sep="\t", stringsAsFactors=F)
head(met.de)


# Building the reaction network

# Our nodes are metabolites
nodes <- read.csv("/data/SBW2016/networks/nodes.tsv", header=T, quote="", sep="\t", stringsAsFactors=F)
head(nodes)

# Our edges are substrate-product pairs
edges <- read.csv("/data/SBW2016/networks/edges.tsv", header=T, quote="", sep="\t", stringsAsFactors=F)
head(edges)

# Annotating nodes with metabolic data
# Absence of a metabolite siganal does not mean absence of the metabolite -> all.x=T
nodes <- merge(nodes, met.de, by.x="met", by.y="ID", all.x = T)
head(nodes)

# To annotate edges we first need reaction to gene mapping
rxn2gene <- read.csv("/data/SBW2016/networks/rxn2gene.tsv", header=T, sep="\t", stringsAsFactors=F)
head(rxn2gene)

# Annotating reactions
rxn.de <- merge(rxn2gene, gene.de, by.x="gene",  by.y="ID")
head(rxn.de)

# Finally annotating edges
edges <- merge(edges, rxn.de, by.x="rxn", by.y="rxn")

# Fixing multiple genes per edge by selecting only one with the smallest p-value
edges <- edges[order(edges$pval), ]
edges <- edges[!duplicated(edges[, c("met.x", "met.y")]), ]
head(edges)

net <- GAM:::graph.from.tables(node.table = nodes, 
                               edge.table = edges, edge.cols = c("met.x", "met.y"),
                               directed = F)


saveModuleToXgmml(net, file = "M0_vs_M1.net.xgmml", name="M0_vs_M1")


solver <- gmwcs.solver(gmwcs = "gmwcs", nthreads = 4)
V(net)$score <- -V(net)$logPval - 10
V(net)[is.na(score)]$score <- -10

E(net)$score <- -E(net)$logPval - 20

module <- solver(net)
saveModuleToXgmml(module, file = "M0_vs_M1.module.xgmml", name="M0_vs_M1.module")
