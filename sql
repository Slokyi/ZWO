SELECT
    ReferencingObjectType = o.type_desc,
    ReferencingObjectSchema = SCHEMA_NAME(o.schema_id),
    ReferencingObjectName = o.name,
    ReferencingObjectTypeCode = o.type
FROM sys.sql_expression_dependencies sed
INNER JOIN sys.objects o ON sed.referencing_id = o.object_id
INNER JOIN sys.columns c ON sed.referenced_id = c.object_id AND sed.referenced_minor_id = c.column_id
WHERE sed.referenced_entity_name = 'YourTableName' -- 替换为你的表名
  AND SCHEMA_NAME(sed.referenced_schema_id) = 'dbo' -- 替换为你的表所在的架构名，通常是dbo
  AND c.name = 'YourColumnName' -- 替换为你的字段名
ORDER BY o.type_desc, o.name;
