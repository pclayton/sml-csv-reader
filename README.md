# SML CSV Reader

SML CSV Reader is a small Standard ML library for reading CSV files.


## CSV format

The CSV format is based on RFC 4180 but relaxed to remove the restriction to
printable ASCII (which rules out UTF-8 content in fields) and to allow records
to be separated by `LF` as well as `CRLF`.  Specifically:
 1. `TEXTDATA` is not restricted to printable ASCII but is any octet
    that is not `LF`, `CR`, `DQUOTE` nor `COMMA`.
 2. An unescaped `LF` without a preceding `CR` starts the next record.

These changes allow a superset of the CSV files allowed by RFC 4180.


## API

A CSV reader implements the signature `CSV_READER`.  The CSV source is abstract
in the SML interface, represented as a character reader.  This uses the
[reader](https://smlfamily.github.io/Basis/string-cvt.html#SIG:STRING_CVT.reader:TY)
abstraction from the SML Basis Library.

The functor `CsvReader` constructs a CSV reader given an implementation of the
signature `CSV_READER_OPS`, which determines the datatype that represents the
CSV records and performs any validation of the content.  The MLB file
`csv-reader.mlb` provides these modules.  

The structure `ListCsvReader` provides a CSV reader that represents the file as
a `string list list`, as defined in the structure `ListCsvTypes`, performing
no validation of the content.  This shows how the functor `CsvReader` can be
used.  The MLB file `list-csv-reader.mlb` provides these modules.


## Usage

The Basis Library provides many ways to construct character readers from various
sources.  For example, to read a file using `ListCsvReader`, a character reader
is obtained for the file using the `TextIO.StreamIO` layer as follows:
```sml
val istream = TextIO.openIn fileName
val data =
  ListCsvReader.readFile TextIO.StreamIO.input1 (TextIO.getInstream istream)
    handle e => (TextIO.closeIn istream; raise e)
val () = TextIO.closeIn istream
```
