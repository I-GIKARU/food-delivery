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
	Email      *EmailService
	Cloudinary *CloudinaryService
	Upload     *UploadService
}

// New creates a new services instance
func New(db *gorm.DB, cfg *config.Config) *Services {
	cloudinaryService, _ := NewCloudinaryService(cfg) // Handle error in real application
	uploadService, _ := NewUploadService(cfg) // Handle error in real application

	return &Services{
		User:       NewUserService(db, cfg),
		Restaurant: NewRestaurantService(db, cfg),
		Order:      NewOrderService(db, cfg),
		Payment:    NewPaymentService(db, cfg),
		Delivery:   NewDeliveryService(db, cfg),
		Auth:       NewAuthService(db, cfg),
		Email:      NewEmailService(cfg),
		Cloudinary: cloudinaryService,
		Upload:     uploadService,
	}
}

