# Use of Graphql 
As the UI evolves, graphql will allow more flexibility and separation between client and server.  Serverless technologies like AWS lambda are evolving quickly and Graphql will enable various middleware type serverless technologies to help with caching and various other realtime logic and analysis.

### Next Tasks  
- [ ] Graphlize Routes Panel
  - [ ] Create root queries for
    - [ ] updateFcEventMutation

- [ ] Add Authoriz to graphql queries
- [ ] Add gem, https://github.com/gjtorikian/graphql-docs

- [ ] Install https://www.npmjs.com/package/@playlyfe/gql
- [ ] Install graphql extension for VS Code, above is prerequisite

Reference Links:

[graphql](http://graphql.org/)  
[ref](https://hackernoon.com/graphql-tips-after-a-year-in-production-419341db52e3)  
[ref](https://medium.com/@cjoudrey/life-of-a-graphql-query-lexing-parsing-ca7c5045fad8)

## Auth in Graphgql

https://www.apollographql.com/docs/react/recipes/authentication.html
https://www.youtube.com/watch?v=4_Bcw7BULC8
https://github.com/chenkie/graphql-auth
https://github.com/smooth-code/graphql-directive (more recent directive stuff)
https://www.youtube.com/watch?v=xaorvBjCE7A

### Token Auth
https://github.com/lynndylanhurley/devise_token_auth
https://paweljw.github.io/2017/07/rails-5.1-api-with-vue.js-frontend-part-4-authentication-and-authorization/

Sample graphql query that can be pasted into graphiql to test what's setup so far.  
(needs to be wrapped into proper tests XXX):
http://graphql-ruby.org/schema/testing.html

```json
{
  currentUser {
    first_name
  },
  fcEventSources
  all_routes {
    title
  },
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
  },
  allUsers {
    first_name
  }
}
```
