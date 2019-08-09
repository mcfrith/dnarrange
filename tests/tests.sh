#! /bin/sh

try () {
    echo TEST "$@"
    eval "$@"
    echo
}

cd $(dirname $0)

PATH=..:$PATH

{
    try dnarrange --help

    try dnarrange -c1 alns.maf

    try dnarrange -s4 alns.maf

    try dnarrange -tCG -c1 alns.maf

    try dnarrange -tG -g1e2 alns.maf

    try dnarrange -tN -r1e2 alns.maf

    try dnarrange -s1 mito.maf

    try dnarrange -s4 alns.maf : mito.maf

    try dnarrange -tG -g11 -s1 mito.maf

    try dnarrange -s3 -c1 alns.maf : neg.maf

    try dnarrange -s3 alns.maf neg.maf

    try dnarrange -d200 -s3 -tC alns.maf

    try dnarrange -g11 alns.tab

    try dnarrange --shrink -s1 -r1 -g40 alns.maf

    try dnarrange --shrink -s0 -r1 -g40 alns.maf

    try dnarrange -c1 alns.txt

    try dnarrange-link -g3,6 alns-summary.txt
    try dnarrange-link -m1e9 alns-summary.txt
    try dnarrange-link -v alns-summary.txt
} 2>&1 |
diff -u $(basename $0 .sh).out -
