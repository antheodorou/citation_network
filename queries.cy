 //Q1
 MATCH (x:Author) - [w:WRITES] -> (n:Article) <- [c:CITES] - (a:Article)
 RETURN x.name AS author, COUNT(c) AS citations
 ORDER BY citations DESC
 LIMIT 5

//Q2
MATCH (a1:Author)-[r1:WRITES]-> (ar:Article) <- [r2:WRITES] - (a2:Author)
WHERE a1.name <> a2.name 
RETURN a1.name AS author_name, count(distinct(a2.name)) AS counter 
ORDER BY counter desc 
LIMIT 5

//Q3
MATCH (author:Author) - [w:WRITES] -> (article:Article)
OPTIONAL MATCH (collaborator:Author) - [w1:WRITES] -> (article:Article)
WITH author, COUNT(article) AS articles_count, COUNT(DISTINCT collaborator)  AS    collaborators_count
WHERE collaborators_count = 1
RETURN author.name, articles_count
ORDER BY articles_count DESC
LIMIT 1

 //Q4
MATCH (a:Author) - [r:WRITES] -> (a1:Article) - [r1:PUBLISHED] -> (j:Journal) 
WHERE a1.year = 2001
RETURN a.name as author, count(*) as paper_published 
ORDER BY paper_published DESC
LIMIT 1

//Q5
//fulltext index
call db.index.fulltext.createNodeIndex("articleTitle", ["Article"], ["title"])

//create query 
CALL db.index.fulltext.queryNodes("articleTitle", "gravity")
YIELD node AS article
MATCH (author:Author) - [w:WRITES] -> (article:Article)- [p:PUBLISHED]-> (j:Journal)
WHERE article.year = 1998
RETURN j.jrn as title, COUNT(article) AS papers
ORDER BY papers DESC
LIMIT 1

//Q6
MATCH ()-[r:CITES]->(a:Article) 
RETURN a.title AS title, count(a) AS counter
ORDER BY counter DESC 
LIMIT 5

//Q7
//create fulltext index 
CALL db.index.fulltext.createNodeIndex("articleAbstract", ["Article"], [ "abstract"])

//create query 
CALL db.index.fulltext.queryNodes("articleAbstract", "holography AND anti de sitter")
YIELD node AS article
MATCH (author:Author) - [w:WRITES] -> (article:Article)
RETURN article.title as title, author.name as authors

//Q8
MATCH (a:Author{name:'C.N. Pope'}), (b:Author{name:'M. Schweda'}), p = shortestPath((a)-[*]-(b)) 
WHERE a <> b 
RETURN a.name as From_Node, [n in nodes(p) | labels(n)] AS ShortestPath_Nodes, b.name AS To_Node, length(p) as Length 
ORDER BY Length ASC 

//Q9
MATCH (a:Author{name:'C.N. Pope'}), (b:Author{name:'M. Schweda'}), p = shortestPath((a)-[*]-(b)) 
WHERE a <> b AND NONE(n in nodes(p) WHERE n : Journal) 
RETURN a.name as From_Node, [n in nodes(p) | labels(n)] AS ShortestPath_Nodes, b.name AS To_Node, length(p) as Length 
ORDER BY Length ASC

//Q10
//V1
MATCH p = ShortestPath((c:Author{name:'Edward Witten'})-[*]-(f:Author))
Where f<>c AND length(p) > 25 AND NONE(n in nodes(p) WHERE n : Journal)
RETURN f.name as author ,length(p) as length, [n in nodes(p) where n.title is not null | n.title] as title LIMIT 10

//V2
MATCH p = ShortestPath((c:Author{name:'Edward Witten'})-[*]-(f:Author))
Where f<>c AND length(p) > 15 AND NONE(n in nodes(p) WHERE n : Journal)
RETURN f.name as author ,length(p) as length, [n in nodes(p) where n.title is not null | n.title] as title LIMIT 10

//V3
MATCH (f:Author), p = ShortestPath((c:Author{name:'Edward Witten'})-[:AUTHOR*]-(f:Author))
Where f<>c
WITH c.name as fromNode,
f.name as toNode,[n in nodes(p) | n.title] AS SortestPath,
length(p) as Length
WHERE Length >25
RETURN fromNode, toNode,Length, SortestPath
ORDER BY Length DESC