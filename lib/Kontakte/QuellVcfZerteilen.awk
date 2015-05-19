# Benoetigt SaubereKontaktnamen.awk!

BEGIN {
    RS = "BEGIN:VCARD\n";
    FS = "\n";
}
{
    f = substr($2, 4);
    if ( f == "" ) next;
    if ( substr(f, 1, 1) == ";" ) next;
    if ( substr(f, 1, 1) == "-" ) next;
    f = SaubereKontaktnamen(f);
    system("mkdir -p \""f"\"");
    print "BEGIN:VCARD" > f"/"f".vcf";
    print $0 > f"/"f".vcf";
}
