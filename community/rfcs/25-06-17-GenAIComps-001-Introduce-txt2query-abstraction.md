# Intriduce "txt2query" microservice with vendor integration to replace individual txt2cypher, txt2sql microservices

Txt2query is a microservice abstraction for all different query languages. It follows same design philosophy as current dataprep, retriever and OPEAStore microservices.  

## Author(s)

Rita Brugarolas Brufau  |  Intel Corporation  |  @rbrugaro

Antony Mahanna  |  Arango DB  |  @aMahanna 

## Status

`Under Review`

## Objective

List what problem will this solve? What are the goals and non-goals of this RFC?

Currently there are [txt2cypher](https://github.com/opea-project/GenAIComps/tree/main/comps/text2cypher) and [txt2sql](https://github.com/opea-project/GenAIComps/tree/main/comps/text2sql) and any new vendor needs to contribute a new microservice. 
What this RFC proposes is that all the txt2query language vendor integrations inherit from a base class definition modeling the same OPEA design philosophy in dataprep, retriever, OPEAStore.  


## Motivation

List why this problem is valuable to solve? Whether some related work exists?

    - Offer same design philosophy for developers across OPEA microservices. Enabling switching between database vendor integrations without code changes other than the vendor selection setting.
    - Reduce code duplication and maintenance across microservices

## Design Proposal

Folder structure to follow same as dataprep and retriever

```
# ❯ tree .
# .
# ├── Dockerfile
# ├── README.md
# ├── __init__.py
# ├── integrations
# │   ├── aql.py # <-----------
# │   ├── cypher.py
# │   └── sql.py
# ├── opea_text2query_microservice.py
# └── requirements.txt
```

Define a Txt2QueryInput base clase with the required arguments, in this case, the `input_text` we want to convert into a query, and an `execte_query` to indicate if that resulting query needs to be executed against the database or just the query string returned.

For vendor integration (SQL, Cypher, AQL…) may chose to add custom arguments like connection string, prompt template, graph schema, etc…

```
# TODO: Move this to GenAIComps/comps/cores/proto/api_protocol.py
class Text2QueryInput(BaseModel):
    input_text: str
    execute_query: bool = True
class Text2QueryInputSQL(Text2QueryInput):
    conn_str: Optional[PostgresConnection] = None
class Text2QueryInputCypher(Text2QueryInput):
    conn_str: Optional[Neo4jConnection] = None
class Text2QueryInputAQL(BaseModel):
    custom_propmt_template: str | None = None
    custom_schema: Dict[str, Any] | None = None
    # TODO: ....
    pass   
```

Below an example of `aql.py` registration
```
from comps import CustomLogger, OpeaComponent, OpeaComponentRegistry, ServiceType

@OpeaComponentRegistry.register("OPEA_TEXT2QUERY_AQL")
class OpeaText2AQL(OpeaComponent):
    pass
```
Each of the implementations in the integrations folder should implement those OpeaComponent methods: check_health, invoke..

## Alternatives Considered

Continue with vendor specific microservices txt2sql, txt2cypher, txt2aql….

## Compatibility

Pursuing this refactoring abstraction would require deprecating existing `txt2sql` and `txt2cypher` microservice and refactoring those GenAI examples that leverage them.

## Miscellaneous

Few other items for consideration:

    1. Current txt2cypher microservice includes gaudi native and gaudi utils scripts within the microservice folder. I don't know yet the reason why that is there. If we pursue this abstraction those should be relocated to llm or a more appropriate microservice. Need to check w @jeanyu-habana

    2. In the comps/agents/src/integrations/strategy/sqlagent there is an sql agent. We could see this sql2query as one of the building blocks for such agent solution that is more robust and offers query validation and retry mechanism for failing queries. 

    3. Regarding engineering resourcing: ArangoDB is interested to contribute their vendor integration but still need to identify resources to introduce the txt2query class and following refactoring. 
    
List other information user and developer may care about, such as:

- Performance Impact, such as speed, memory, accuracy.
- Engineering Impact, such as binary size, startup time, build time, test times.
- Security Impact, such as code vulnerability.
- TODO List or staging plan.
