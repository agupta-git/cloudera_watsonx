DROP TABLE IF EXISTS default.model_response;
CREATE EXTERNAL TABLE IF NOT EXISTS default.model_response (
  model_id string,
  created_at string,
  filename string,
  generated_text string,
  generated_token_count string,
  inputs string,
  input_token_count string
)
ROW FORMAT SERDE
    'org.apache.hive.hcatalog.data.JsonSerDe'
LOCATION 's3a://iceberg-presto/data/watsonx_response/'
;

SELECT * FROM default.model_response;
