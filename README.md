Notes on papers I read. 

To start a new note, run `papernote` from this directory:

```sh
cd PATH_TO_PAPERNOTE
./papernote https://arxiv.org/pdf/2609.36178
```

The title is extracted automatically from the paper's `citation_title` metadata. arXiv PDF and HTML links use the abstract page for this lookup. This requires `curl` and `uv`.

You can still supply a title yourself:

```sh
./papernote "GaLore" https://arxiv.org/pdf/2403.03507
```

The title goes in the header alongside the link and date, which is what the blog reads. The filename is the title lowercased, with anything other than letters and digits collapsed into `_`.

The note opens in Markatui (`mrk`) in the current terminal. Set `EDITOR` to override it.
