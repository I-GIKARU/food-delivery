package services

import (
	"kenyan-food-delivery/internal/config"

	"gorm.io/gorm"
)

// OrderService handles order-related operations
type OrderService struct {
	db     *gorm.DB
	config *config.Config
}

// NewOrderService creates a new order service
func NewOrderService(db *gorm.DB, cfg *config.Config) *OrderService {
	return &OrderService{
		db:     db,
		config: cfg,
	}
}

// PaymentService handles payment-related operations
type PaymentService struct {
	db     *gorm.DB
	config *config.Config
}

// NewPaymentService creates a new payment service
func NewPaymentService(db *gorm.DB, cfg *config.Config) *PaymentService {
	return &PaymentService{
		db:     db,
		config: cfg,
	}
}

// DeliveryService handles delivery-related operations
type DeliveryService struct {
	db     *gorm.DB
	config *config.Config
}

// NewDeliveryService creates a new delivery service
func NewDeliveryService(db *gorm.DB, cfg *config.Config) *DeliveryService {
	return &DeliveryService{
		db:     db,
		config: cfg,
	}
}

