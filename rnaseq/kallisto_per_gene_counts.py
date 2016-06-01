#!/usr/bin/env python

"""Implementing per gene counts for kallisto output"""

__author__ = "Yury Barbitoff"
__copyright__ = "Copyright 2015, Yury Barbitoff"
__license__ = "CC"
__version__ = "1.0"
__email__ = "barbitoff@bk.ru"
__status__ = "Release"


import sys
import getopt


def optRecognize(argv):
    """Processing given command line options"""
    try:
        opts, args = getopt.getopt(argv, "ha:", ["help", "annot="])
    except:
        print('\nInvalid options. To see usage info, type kallisto_pgc -h\n')
        sys.exit()
    annotationfile, quantfiles = None, None
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            print('''\n\nTo turn kallisto output into per-gene counts:
kallisto_pgc -a <file> [arguments]
-a (--annot) <file> - GTF/GFF file containing annotation of the genome
[arguments] - (multiple input files supported) kallisto quantification output in TSV format
=================================
-h (--help) To show the help message again\n''')
            sys.exit()
        elif opt in ("-a", "--annot"):
            annotationfile = arg
    quantfiles = args
    return annotationfile, quantfiles


def transcriptsToGenes(annotationfile):
    """Creating transcript-gene map"""
    tgr = {}    	
    with open(annotationfile, 'r') as annotation:
        for line in annotation:
            content = line.split()
            if len(content) < 15:
                continue
            if content[2] == 'transcript':
                transcript_id = content[11][1:len(content[11])-2]
                gene_id = content[9][1:len(content[9])-2]
                tgr[transcript_id] = gene_id
    return tgr


def writeGeneCounts(quantfiles, tgr):
    """Turning transcript-based counts into gene-based counts"""
    for quantfile in quantfiles:
        outfile = quantfile.replace('.tsv', '_per_gene.tsv')
        gene_counts = {}
        with open(quantfile, 'r') as abundances:
            for line in abundances:
                if line.startswith('target'):
                    continue
                content = line.split()
                gene_id = tgr[content[0]]
                gene_counts[gene_id] = [sum(x) for x in zip(gene_counts.get(gene_id, [0, 0]), [float(y) for y in content[3:5]])]
        with open(outfile, 'w') as out:
            out.write('target_id\test_counts\ttpm\n')
            for gene_id, counts in  gene_counts.items():
                out.write(gene_id + '\t' + str(counts[0]) + '\t' + str(counts[1]) + '\n')
                
                
# Get input options
if __name__ == "__main__":
    annotationfile, quantfiles = optRecognize(sys.argv[1:])

print '\n...patient should you be, young padawan...'
tgr = transcriptsToGenes(annotationfile)
writeGeneCounts(quantfiles, tgr)
print '...done\n'
