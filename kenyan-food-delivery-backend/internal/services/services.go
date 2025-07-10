package services

import (
	"kenyan-food-delivery/internal/config"

	"gorm.io/gorm"
)

// Services holds all service instances
type Services struct {
	User       *UserService
	Restaurant *RestaurantService
	Order      *OrderService
	Payment    *PaymentService
	Delivery   *DeliveryService
	Auth       *AuthService
}

// New creates a new services instance
func New(db *gorm.DB, cfg *config.Config) *Services {
	return &Services{
		User:       NewUserService(db, cfg),
		Restaurant: NewRestaurantService(db, cfg),
		Order:      NewOrderService(db, cfg),
		Payment:    NewPaymentService(db, cfg),
		Delivery:   NewDeliveryService(db, cfg),
		Auth:       NewAuthService(db, cfg),
	}
}

