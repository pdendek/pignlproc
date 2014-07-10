set default_parallel 1;

simpleLinks = load 'simpleLinks' as (srcUri:chararray,dstUri:chararray));
uris_id = load 'uri_Id' as (uri:chararray,id:long);

links_id_src = join simpleLinks by srcUri, uris_id by uri;

links_id_src_clean = foreach links_id_src generate 
  srcUri as srcUri, id as srcId, dstUri as dstUri;

links_id_dst = join links_id_src_clean by dstUri, uris_id by uri;
links_id_dst_clean = foreach links_id_dst generate
  srcId as srcId, srcUri as srcUri, id as dstId, 1;

giraphInput_A = group links_id_dst_clean by (srcId,srcUri);
giraphInput_B = foreach giraphInput_A generate FLATTEN(group) as (srcId,srcUri), links_id_dst_clean.($2,$3);

STORE giraphInput_B INTO '$OUTPUT' USING PigStorage();

