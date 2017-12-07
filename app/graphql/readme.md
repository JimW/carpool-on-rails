# Use of Graphql 
As the UI evolves, graphql will allow more flexibility and separation between client and server.  Serverless technologies like AWS lambda are evolving quickly and Graphql will enable various middleware type serverless technologies to help with caching and various other realtime logic and analysis.

Reference Links:

[graphql](http://graphql.org/)  
[ref](https://hackernoon.com/graphql-tips-after-a-year-in-production-419341db52e3)  
[ref](https://medium.com/@cjoudrey/life-of-a-graphql-query-lexing-parsing-ca7c5045fad8)

TODO:
1. Create a query that pulls in the has_one events of routes.
1. Move the Route.get_events logic out to the graphql layer.  used for fullcalendar
1. Add Apollo client with basic React implementation of some basic carpool feature, https://github.com/apollographql/apollo-client
1. Add gem, https://github.com/gjtorikian/graphql-docs

Sample graphql query that can be pasted into graphiql to test what's setup so far.  
(needs to be wrapped into proper tests XXX):
http://graphql-ruby.org/schema/testing.html

```json
{
  drivers {
    first_name
  },
  fc_events(cat_type: "special") {},
  user(id:1) {
    first_name
  },
  me: viewer {
  	email
    organizations {
      title
    }
    carpools {
      title
      id
      passengers {
        first_name
      }
      drivers {
        first_name
      }
      routes {
        title
        locations {
          title
        }
        updated_at
        drivers {
          first_name
        }
        passengers {
          first_name
        }
        carpool {
          title
        }
      }
    }
	}
}
```
