#!/usr/bin/gawk -f
# vim: set ts=4 sw=4 tw=0 et :
#----------------------------------------------------------------------
#File     : @(#) sqlmarkers.awk
#Author   : Roland van Veen
#License  : MIT
#Purpose  : Add Markers to a (T)-sql batch file using go batch markers
#           plus add  missing trailing go.
#           The markers are a great way to add printing execution progress to large TSQL batches.
#           and detect any uncaught batch failures.
#Usage    : ./sqlmarkers.awk  <myfile.sql> [<file2.sql>..]
#  The Marker count will continue with the next value when you pass multiple files.
#  If you want to restart with number 1 just process files individually.
#  Assumes Unix style  newline.
#
#
#Arguments:  $1 [,$2..]: sql filename  shown in usage.
#History  :
#----------------------------------------------------------------------
#..<removed>
#20180219 : Created
#----------------------------------------------------------------------

BEGIN {
    CNTMARKS=1;
    IGNORECASE=1;
    $1="";
    endbatch="go"; #Can be changed to ; for example.
}
{
    OFS="";
    ORS="\n";
    if (tolower($1)==endbatch) {
        cmark=sprintf("%06d",CNTMARKS)
        print "\n", "PRINT 'GOSQLMarker ",  cmark, "[" basename(ARGV[1]), "]'\n" , $0;
        CNTMARKS+=1;
        next;
    }
    #Skip existing marker.
    if (($0 !~ /GOSQLMarker/)) {
        if (tolower($0) !~ /^endbatch$/) {print;}
    }
}
END {
    if (tolower($1) != endbatch) print "\n",endbatch,"\n";
}


function basename(pn) {
    sub(/^.*\\/, "", pn);
    return pn
}
