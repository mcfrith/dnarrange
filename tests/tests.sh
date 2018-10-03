#! /bin/sh

try () {
    echo TEST "$@"
    eval "$@"
    echo
}

cd $(dirname $0)

PATH=..:$PATH

{
    try rearranged-sequence-clumps --help

    try rearranged-sequence-clumps alns.maf

    try rearranged-sequence-clumps -s4 alns.maf

    try rearranged-sequence-clumps -tCG alns.maf

    try rearranged-sequence-clumps -tG -g1e2 alns.maf

    try rearranged-sequence-clumps -tN -r1e2 alns.maf

    try rearranged-sequence-clumps -s1 mito.maf

    try rearranged-sequence-clumps -n2 -s4 alns.maf mito.maf

    try rearranged-sequence-clumps -tG -g11 -s1 mito.maf

    try rearranged-sequence-clumps -n2 -s3 alns.maf neg.maf

    try rearranged-sequence-clumps -y2 -s3 alns.maf neg.maf
} 2>&1 |
diff -u $(basename $0 .sh).out -
