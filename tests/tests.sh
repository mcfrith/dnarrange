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
} 2>&1 |
diff -u $(basename $0 .sh).out -
