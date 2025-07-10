package database

import (
	"kenyan-food-delivery/internal/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// Initialize creates a new database connection
func Initialize(databaseURL string) (*gorm.DB, error) {
	db, err := gorm.Open(postgres.Open(databaseURL), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return nil, err
	}

	return db, nil
}

// Migrate runs database migrations
func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&models.User{},
		&models.Address{},
		&models.Restaurant{},
		&models.Category{},
		&models.MenuItem{},
		&models.Order{},
		&models.OrderItem{},
		&models.Payment{},
		&models.Delivery{},
		&models.Review{},
		&models.DeliveryZone{},
		&models.County{},
		&models.Cuisine{},
		&models.RestaurantCategory{},
		&models.DriverLocation{},
		&models.Notification{},
	)
}

