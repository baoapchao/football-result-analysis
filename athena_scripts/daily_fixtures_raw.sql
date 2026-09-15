CREATE EXTERNAL TABLE `daily_fixtures_raw`(
  `get` string COMMENT 'from deserializer', 
  `parameters` struct<date:string> COMMENT 'from deserializer', 
  `errors` array<string> COMMENT 'from deserializer', 
  `results` int COMMENT 'from deserializer', 
  `paging` struct<current_page:int,total_page:int> COMMENT 'from deserializer', 
  `response` array<struct<fixture:struct<id:bigint,referee:string,timezone:string,date:string,timestamp:bigint,periods:struct<first:int,second:int>,venue:struct<id:int,name:string,city:string>,status:struct<long:string,short:string,elapsed:int,extra:int>>,league:struct<id:int,name:string,country:string,logo:string,flag:string,season:int,round:string,standings:boolean>,teams:struct<home:struct<id:int,name:string,logo:string,winner:boolean>,away:struct<id:int,name:string,logo:string,winner:boolean>>,goals:struct<home:int,away:int>,score:struct<halftime:struct<home:int,away:int>,fulltime:struct<home:int,away:int>,extratime:struct<home:int,away:int>,penalty:struct<home:int,away:int>>>> COMMENT 'from deserializer')
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://bao-better-bucket/daily_fixtures'
TBLPROPERTIES (
  'transient_lastDdlTime'='1778269038')