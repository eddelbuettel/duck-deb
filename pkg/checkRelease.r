#!/usr/bin/env Rscript

url <- "https://api.github.com/repos/duckdb/duckdb/releases"
res <- jsonlite::fromJSON(url)

releases <- gsub("^v", "", res$tag_name)    # as tag_name is "v1.1.2" etc

chnglg <- readLines("debian/changelog")
chnglg <- chnglg[grepl("^duckdb \\(.*\\).*", chnglg)]
pkgs <- gsub(".*\\((.*)\\).*", "\\1", chnglg)

if (releases[1] == pkgs[1])
    q(ask="no")

tab <- res$assets[[1]]
files <- tab$browser_download_url
zipfile <- files[grepl("cli-linux-amd64.zip$", files)]
tgt <- basename(zipfile)
if !file.exists(tgt) {
    download.file(zipfile, tgt, quiet=TRUE)
    cat("Downloaded", tgt, "\n")
}


## this worked
##   EMAIL=edd@debian.org dch --package duckdb --newversion 1.2.2  --distribution noble --changelog debian/test_changelog 'New version'
Sys.setenv(EMAIL="edd@debian.org")
cmd <- sprintf("dch --package duckdb --newversion %s --distribution noble 'New version'", releases[1])
system(cmd)

cmd <- "dpkg-buildpackage -us -uc -rfakeroot -tc"
system(cmd)

unlink(zipfile)
