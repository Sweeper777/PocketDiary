function highlightSearch() {
    var text = document.getElementById("query").value;
    var query = new RegExp("(\\b" + text + "\\b)", "gim");
    var e = document.getElementById("searchtext").innerHTML;
    var newe = e.replace(query, "<span>$1</span>");
    document.getElementById("searchtext").innerHTML = newe;
}