function SaubereKontaktnamen(s) {
    gsub("[/() ;&\\?:'´`|]", "_", s);
    return s;
}
