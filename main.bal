import ballerina/graphql;
import ballerina/http;

# A shared HTTP listener used by both the GraphQL service and the REST service
listener http:Listener sharedListener = new (8090);

# A service representing a network-accessible GraphQL API
service / on new graphql:Listener(sharedListener) {

    # A resource for generating greetings
    # Example query:
    #   query GreetWorld{ 
    #     greeting(name: "World") 
    #   }
    # Curl command: 
    #   curl -X POST -H "Content-Type: application/json" -d '{"query": "query GreetWorld{ greeting(name:\"World\") }"}' http://localhost:8090
    # 
    # + name - the input string name
    # + return - string name with greeting message or error
    resource function get greeting(string name) returns string|error {
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }

    remote function createUser(string name) returns string|error {
        if name is "" {
            return error("name should not be empty!");
        }
        return "User created with name: " + name;
    }
}

# A REST API exposed on the same port as the GraphQL service
service /api on sharedListener {

    # A resource for generating greetings
    # Curl command:
    #   curl http://localhost:8090/api/greeting?name=World
    #
    # + name - the input string name
    # + return - string name with greeting message or an error payload
    resource function get greeting(string name) returns string|http:BadRequest {
        if name == "" {
            return {body: "name should not be empty!"};
        }
        return "Hello, " + name;
    }

    # A resource for creating a user
    # Curl command:
    #   curl -X POST -H "Content-Type: text/plain" -d 'World' http://localhost:8090/api/users
    #
    # + name - the input string name
    # + return - confirmation message or an error payload
    resource function post users(@http:Payload string name) returns string|http:BadRequest {
        if name == "" {
            return {body: "name should not be empty!"};
        }
        return "User created with name: " + name;
    }
}

# A service representing a network-accessible HTTP API that greets users
service /greeting on new http:Listener(8091) {

    # A resource for generating greetings
    #
    # + name - the input string name
    # + return - string name with greeting message or error
    resource function get greet(string name) returns string|http:BadRequest {
        if name == "" {
            return {body: "name should not be empty!"};
        }
        return "Hello, " + name;
    }
}

// import ballerina/mcp;

// listener mcp:StreamableHttpListener mcpListener = new (8080);

// @mcp:StreamableHttpServiceConfig {info: {name: "Greeting MCP Service", version: "1.0.0"}}
// service mcp:StreamableHttpService /mcp on mcpListener {
//     # Get a static greeting message
//     remote function getGreeting() returns string {
//         return "Hello! Welcome to the Greeting MCP Service.";
//     }
// }