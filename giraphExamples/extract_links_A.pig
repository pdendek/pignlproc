-- Query incoming link popularity - local mode

set default_parallel 1;

-- Register the project jar to use the custom loaders and UDFs
REGISTER $PIGNLPROC_JAR

-- Parse the wikipedia dump and extract text and links data
parsed =
  LOAD '$INPUT'
  USING pignlproc.storage.ParsingWikipediaLoader('en')
  AS (title, uri, text, redirect, links, headers, paragraphs);

-- Extract the sentence contexts of the links respecting the paragraph
-- boundaries
sentences =
  FOREACH parsed
  GENERATE uri, pignlproc.evaluation.SentencesWithLink(text, links, paragraphs);

-- Flatten the links
flattened =
  FOREACH sentences
  GENERATE uri, flatten($1);

simpleLinks = foreach flattened generate $0 as srcUri, $3 as dstUri;

store simpleLinks into 'simpleLinks';

uris = foreach parsed generate uri;
uris_filtered = filter uris by uri is not null;
uris_distinct = distinct uris_filtered;
uris_ranked = rank uris_distinct by uri;
uris_id = foreach uris_ranked generate $1 as uri, $0 as id;

store uris_id into 'uri_Id';

