CREATE EXTERNAL TABLE `fixture_details_half`(
  `get` string COMMENT 'from deserializer', 
  `parameters` struct<fixture:string,half:string> COMMENT 'from deserializer', 
  `errors` array<string> COMMENT 'from deserializer', 
  `results` int COMMENT 'from deserializer', 
  `paging` struct<current:int,total:int> COMMENT 'from deserializer', 
  `response` array<struct<team:struct<id:int,name:string,logo:string>,statistics:array<struct<type:string,value:string>>,statistics_1h:array<struct<type:string,value:string>>,statistics_2h:array<struct<type:string,value:string>>>> COMMENT 'from deserializer')
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat'
LOCATION
  's3://bao-better-bucket/fixture_details_half'
TBLPROPERTIES (
  'transient_lastDdlTime'='1778431693')