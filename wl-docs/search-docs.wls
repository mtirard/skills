#!/usr/bin/env wolframscript
(* Search WL documentation using the internal DocumentationSearch index.
   Usage: wolframscript -file search-docs.wls "query" [limit]
   limit defaults to 10 *)

args = $ScriptCommandLine;

If[Length[args] < 2,
  Print["Usage: wolframscript -file search-docs.wls \"query\" [limit]"];
  Exit[1]
];

query = args[[2]];
limit = If[Length[args] >= 3, ToExpression[args[[3]]], 10];

Needs["DocumentationSearch`"];
r = DocumentationSearch`SearchDocumentation[query, "Limit" -> limit];

Print[ExportString[<|
  "query"         -> ("ParsedQuery" /. r),
  "totalMatches"  -> ("TotalMatches" /. r),
  "results"       -> Map[<|
    "title"   -> #[[1]],
    "type"    -> #[[2]],
    "snippet" -> #[[3]],
    "uri"     -> #[[4]]
  |> &, ("Matches" /. r)]
|>, "JSON"]];
