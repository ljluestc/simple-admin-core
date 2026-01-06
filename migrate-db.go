package main

import (
	"context"
	"log"

	"github.com/suyuan32/simple-admin-core/rpc/ent"
	"github.com/suyuan32/simple-admin-core/rpc/ent/migrate"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// Create Ent client
	client, err := ent.Open("mysql", "root:@tcp(127.0.0.1:3306)/simple_admin?parseTime=True")
	if err != nil {
		log.Fatalf("failed opening connection to mysql: %v", err)
	}
	defer client.Close()

	// Run migration
	if err := client.Schema.Create(context.Background(), migrate.WithForeignKeys(false)); err != nil {
		log.Fatalf("failed creating schema resources: %v", err)
	}

	log.Println("✅ Database migration completed successfully!")
}
