package main

import (
	"database/sql"
	"github.com/rochmanramadhani/go-bank-app/api"
	db "github.com/rochmanramadhani/go-bank-app/db/sqlc"
	"log"

	_ "github.com/lib/pq"
)

const (
	driverName     = "postgres"
	dataSourceName = "postgresql://root:password@localhost:5432/bank_app?sslmode=disable"
	serverAddress  = "0.0.0.0:8080"
)

func main() {
	conn, err := sql.Open(driverName, dataSourceName)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Start(serverAddress)
	if err != nil {
		log.Fatal("cannot start server:", err)
	}
}
