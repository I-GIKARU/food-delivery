package models

import (
	"time"

	"gorm.io/gorm"
)

// OrderStatus represents the status of an order
type OrderStatus string

const (
	OrderStatusPending    OrderStatus = "pending"
	OrderStatusConfirmed  OrderStatus = "confirmed"
	OrderStatusPreparing  OrderStatus = "preparing"
	OrderStatusReady      OrderStatus = "ready"
	OrderStatusPickedUp   OrderStatus = "picked_up"
	OrderStatusDelivering OrderStatus = "delivering"
	OrderStatusDelivered  OrderStatus = "delivered"
	OrderStatusCancelled  OrderStatus = "cancelled"
	OrderStatusRefunded   OrderStatus = "refunded"
)

// Order represents a customer order
type Order struct {
	ID                uint        `json:"id" gorm:"primaryKey"`
	UserID            uint        `json:"user_id" gorm:"not null"`
	RestaurantID      uint        `json:"restaurant_id" gorm:"not null"`
	AddressID         uint        `json:"address_id" gorm:"not null"`
	OrderNumber       string      `json:"order_number" gorm:"uniqueIndex;not null"`
	Status            OrderStatus `json:"status" gorm:"default:'pending'"`
	SubTotal          float64     `json:"sub_total" gorm:"not null"`
	DeliveryFee       float64     `json:"delivery_fee" gorm:"not null"`
	ServiceFee        float64     `json:"service_fee" gorm:"default:0"`
	Tax               float64     `json:"tax" gorm:"default:0"`
	DiscountAmount    float64     `json:"discount_amount" gorm:"default:0"`
	TotalAmount       float64     `json:"total_amount" gorm:"not null"`
	PaymentStatus     string      `json:"payment_status" gorm:"default:'pending'"` // pending, paid, failed, refunded
	PaymentMethod     string      `json:"payment_method"` // mpesa, card, cash
	SpecialInstructions string    `json:"special_instructions"`
	EstimatedDeliveryTime *time.Time `json:"estimated_delivery_time"`
	ActualDeliveryTime    *time.Time `json:"actual_delivery_time"`
	PrepTime          int         `json:"prep_time"` // in minutes
	DeliveryTime      int         `json:"delivery_time"` // in minutes
	CancelReason      string      `json:"cancel_reason"`
	CancelledAt       *time.Time  `json:"cancelled_at"`
	CancelledBy       *uint       `json:"cancelled_by"` // User ID who cancelled
	CreatedAt         time.Time   `json:"created_at"`
	UpdatedAt         time.Time   `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	User       User        `json:"user,omitempty"`
	Restaurant Restaurant  `json:"restaurant,omitempty"`
	Address    Address     `json:"address,omitempty"`
	OrderItems []OrderItem `json:"order_items,omitempty"`
	Payments   []Payment   `json:"payments,omitempty"`
	Delivery   *Delivery   `json:"delivery,omitempty"`
	Reviews    []Review    `json:"reviews,omitempty"`
}

// OrderItem represents individual items in an order
type OrderItem struct {
	ID             uint    `json:"id" gorm:"primaryKey"`
	OrderID        uint    `json:"order_id" gorm:"not null"`
	MenuItemID     uint    `json:"menu_item_id" gorm:"not null"`
	Quantity       int     `json:"quantity" gorm:"not null"`
	UnitPrice      float64 `json:"unit_price" gorm:"not null"`
	TotalPrice     float64 `json:"total_price" gorm:"not null"`
	SpecialRequest string  `json:"special_request"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`

	// Relationships
	Order    Order    `json:"order,omitempty"`
	MenuItem MenuItem `json:"menu_item,omitempty"`
}

// PaymentStatus represents the status of a payment
type PaymentStatus string

const (
	PaymentStatusPending   PaymentStatus = "pending"
	PaymentStatusCompleted PaymentStatus = "completed"
	PaymentStatusFailed    PaymentStatus = "failed"
	PaymentStatusCancelled PaymentStatus = "cancelled"
	PaymentStatusRefunded  PaymentStatus = "refunded"
)

// PaymentMethod represents different payment methods
type PaymentMethod string

const (
	PaymentMethodMpesa PaymentMethod = "mpesa"
	PaymentMethodCard  PaymentMethod = "card"
	PaymentMethodCash  PaymentMethod = "cash"
	PaymentMethodBank  PaymentMethod = "bank_transfer"
)

// Payment represents payment transactions
type Payment struct {
	ID                  uint          `json:"id" gorm:"primaryKey"`
	OrderID             uint          `json:"order_id" gorm:"not null"`
	UserID              uint          `json:"user_id" gorm:"not null"`
	Amount              float64       `json:"amount" gorm:"not null"`
	Method              PaymentMethod `json:"method" gorm:"not null"`
	Status              PaymentStatus `json:"status" gorm:"default:'pending'"`
	TransactionID       string        `json:"transaction_id"` // External transaction ID
	ReferenceNumber     string        `json:"reference_number"` // Internal reference
	PhoneNumber         string        `json:"phone_number"` // For M-Pesa
	MpesaReceiptNumber  string        `json:"mpesa_receipt_number"`
	MpesaTransactionID  string        `json:"mpesa_transaction_id"`
	MpesaCheckoutRequestID string     `json:"mpesa_checkout_request_id"`
	Currency            string        `json:"currency" gorm:"default:'KES'"`
	ExchangeRate        float64       `json:"exchange_rate" gorm:"default:1"`
	ProcessorResponse   string        `json:"processor_response"` // JSON response from payment processor
	FailureReason       string        `json:"failure_reason"`
	ProcessedAt         *time.Time    `json:"processed_at"`
	RefundedAt          *time.Time    `json:"refunded_at"`
	RefundAmount        float64       `json:"refund_amount" gorm:"default:0"`
	RefundReason        string        `json:"refund_reason"`
	CreatedAt           time.Time     `json:"created_at"`
	UpdatedAt           time.Time     `json:"updated_at"`

	// Relationships
	Order Order `json:"order,omitempty"`
	User  User  `json:"user,omitempty"`
}

// DeliveryStatus represents the status of a delivery
type DeliveryStatus string

const (
	DeliveryStatusAssigned   DeliveryStatus = "assigned"
	DeliveryStatusPickedUp   DeliveryStatus = "picked_up"
	DeliveryStatusInTransit  DeliveryStatus = "in_transit"
	DeliveryStatusDelivered  DeliveryStatus = "delivered"
	DeliveryStatusFailed     DeliveryStatus = "failed"
	DeliveryStatusCancelled  DeliveryStatus = "cancelled"
)

// Delivery represents delivery information
type Delivery struct {
	ID                uint           `json:"id" gorm:"primaryKey"`
	OrderID           uint           `json:"order_id" gorm:"not null"`
	DriverID          *uint          `json:"driver_id"`
	Status            DeliveryStatus `json:"status" gorm:"default:'assigned'"`
	PickupTime        *time.Time     `json:"pickup_time"`
	DeliveryTime      *time.Time     `json:"delivery_time"`
	EstimatedTime     *time.Time     `json:"estimated_time"`
	ActualDistance    float64        `json:"actual_distance"` // in kilometers
	EstimatedDistance float64        `json:"estimated_distance"` // in kilometers
	DeliveryFee       float64        `json:"delivery_fee" gorm:"not null"`
	DriverTip         float64        `json:"driver_tip" gorm:"default:0"`
	DeliveryNotes     string         `json:"delivery_notes"`
	ProofOfDelivery   string         `json:"proof_of_delivery"` // Image URL
	CustomerSignature string         `json:"customer_signature"` // Digital signature
	FailureReason     string         `json:"failure_reason"`
	TrackingCode      string         `json:"tracking_code" gorm:"uniqueIndex"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	Order  Order `json:"order,omitempty"`
	Driver *User `json:"driver,omitempty"`
}

