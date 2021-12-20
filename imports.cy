//IMPORTS
//constraints
CREATE CONSTRAINT ON (a:Article) ASSERT a.id IS UNIQUE;
CREATE CONSTRAINT ON (j:Journal) ASSERT j.jrn IS UNIQUE;
CREATE CONSTRAINT ON (au:Author) ASSERT au.name IS UNIQUE;

//loads and relationships
LOAD CSV
FROM "file:///ArticleNodes.csv" AS line
CREATE (n:Article {id: toInteger(line[0]), title: line[1], year: toInteger(line[2]), abstract: line[4]})

LOAD CSV
FROM "file:///ArticleNodes.csv" AS line
WITH line
WHERE line[3] IS NOT NULL
MERGE (n:Journal {jrn: line[3]})
ON MATCH SET n.id = toInteger(line[0])

LOAD CSV
FROM "file:///ArticleNodes.csv" AS line
MATCH (a:Article), (j:Journal)
WHERE a.id = toInteger(line[0]) AND j.jrn = line[3]
CREATE (a) - [r:PUBLISHED] -> (j)

LOAD CSV
FROM "file:///AuthorNodes.csv" AS line
WITH line
WHERE line[1] IS NOT NULL
MERGE (n:Author {name: line[1]})
ON MATCH SET n.id = toInteger(line[0])

LOAD CSV
FROM "file:///AuthorNodes.csv" AS line
MATCH (a1:Author), (a2:Article)
WHERE a1.name = line[1] AND a2.id = toInteger(line[0]) 
CREATE (a1) -[r:WRITES] -> (a2)

LOAD CSV
FROM "file:///Citations.csv" AS line
FIELDTERMINATOR '\t'
MATCH (a1:Article), (a2:Article)
WHERE a1.id = toInteger(line[0]) AND a2.id = toInteger(line[1])
CREATE (a1) - [r:CITES] -> (a2)
 
//Graph Schema
call db.schema.visualization 