package main

import (
	"database/sql"
	"github.com/rochmanramadhani/go-bank-app/api"
	db "github.com/rochmanramadhani/go-bank-app/db/sqlc"
	"github.com/rochmanramadhani/go-bank-app/util"
	"log"

	_ "github.com/lib/pq"
)

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	conn, err := sql.Open(config.DBDriver, config.DBSourceName)
	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Start(config.ServerAddress)
	if err != nil {
		log.Fatal("cannot start server:", err)
	}
}
