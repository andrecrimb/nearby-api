
import PostgresStORM

func setupDBCredentials() -> PostgresConnector.Type{
    let connection = PostgresConnector.self
    
    connection.host = "localhost"
    connection.username = ""
    connection.password = ""
    connection.database = "nearby"
    connection.port = 5432
    
    return connection
}
