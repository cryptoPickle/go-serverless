package schemas

import "github.com/graph-gophers/graphql-go"

var Schema = `
  schema {
		query: Query
	}
	type Person{
		id: ID!
		firstName: String!
		lastName: String
	}
	type Query{
		person(id: ID!): Person
	}
`

type person struct {
  ID graphql.ID
  FirstName string
  LastName string
}

var people = []*person{
  {
    ID:        "1000",
    FirstName: "Halil",
    LastName:  "Irmak",
  },

  {
    ID:        "1001",
    FirstName: "Tan",
    LastName:  "Guven",
  },
}

type personResolver struct {
  p *person
}

func (r *personResolver) ID() graphql.ID {
  return r.p.ID
}

func (r *personResolver) FirstName() string {
  return r.p.FirstName
}

func (r *personResolver) LastName() *string {
  return &r.p.LastName
}

type Resolver struct {}

var peopleData = make(map[graphql.ID]*person)

func (r *Resolver) Person(args struct{graphql.ID}) * personResolver {
  if p := peopleData[args.ID]; p != nil {
    return &personResolver{p}
  }
  return nil
}

var MainSchema *graphql.Schema

func init(){
  for _,p := range people {
    peopleData[p.ID] = p
  }

  MainSchema = graphql.MustParseSchema(Schema, &Resolver{})
}

