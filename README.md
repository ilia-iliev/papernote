Notes on papers I read. 

To start a new note, run `papernote` from this directory:

```sh
cd PATH_TO_PAPERNOTE
./papernote Gpipe
```

This searches arXiv titles and fills in the link from the most relevant result. The note keeps the name you typed: `TITLE: Gpipe`, saved as `gpipe.md`. Quote names containing spaces; colons are supported:

```sh
./papernote "Gpipe: Efficient training"
```

You can also supply just a link to look up the full title:

```sh
./papernote https://arxiv.org/pdf/2609.36178
```

arXiv links use the arXiv API to look up the title by paper ID. Other links use the page's `citation_title` metadata. Lookup requires `curl` and `uv`. If a search has no results or lookup fails, no note is created.

To choose a specific paper or skip lookup, supply both a title and link:

```sh
./papernote "GaLore" https://arxiv.org/pdf/2403.03507
```

The title goes in the header alongside the link and date, which is what the blog reads. The filename is the title lowercased, with anything other than letters and digits collapsed into `_`.

The note opens in Markatui (`mrk`) in the current terminal. Set `EDITOR` to override it.
