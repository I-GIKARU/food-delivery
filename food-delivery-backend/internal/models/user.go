package models

import (
	"time"

	"gorm.io/gorm"
)

// UserRole represents different types of users in the system
type UserRole string

const (
	RoleCustomer         UserRole = "customer"
	RoleRestaurantOwner  UserRole = "restaurant_owner"
	RoleDeliveryDriver   UserRole = "delivery_driver"
	RoleAdmin            UserRole = "admin"
)

// UserStatus represents the status of a user account
type UserStatus string

const (
	StatusActive    UserStatus = "active"
	StatusInactive  UserStatus = "inactive"
	StatusSuspended UserStatus = "suspended"
	StatusPending   UserStatus = "pending"
)

// User represents a user in the system
type User struct {
	ID                uint           `json:"id" gorm:"primaryKey"`
	Email             string         `json:"email" gorm:"uniqueIndex;not null"`
	PhoneNumber       string         `json:"phone_number" gorm:"uniqueIndex;not null"`
	Password          string         `json:"-" gorm:"not null"`
	FirstName         string         `json:"first_name" gorm:"not null"`
	LastName          string         `json:"last_name" gorm:"not null"`
	Role              UserRole       `json:"role" gorm:"not null;default:'customer'"`
	Status            UserStatus     `json:"status" gorm:"not null;default:'active'"`
	ProfilePicture    string         `json:"profile_picture"`
	DateOfBirth       *time.Time     `json:"date_of_birth"`
	Gender            string         `json:"gender"`
	PreferredLanguage string         `json:"preferred_language" gorm:"default:'en'"` // en, sw (Swahili)
	IsVerified        bool           `json:"is_verified" gorm:"default:false"`
	EmailVerifiedAt   *time.Time     `json:"email_verified_at"`
	PhoneVerifiedAt   *time.Time     `json:"phone_verified_at"`
	LastLoginAt       *time.Time     `json:"last_login_at"`
	EmailVerificationToken string    `json:"-"` // Token for email verification
	PasswordResetToken     string    `json:"-"` // Token for password reset
	PasswordResetExpires   *time.Time `json:"-"` // When password reset token expires
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	Addresses         []Address         `json:"addresses,omitempty"`
	Orders            []Order           `json:"orders,omitempty"`
	Reviews           []Review          `json:"reviews,omitempty"`
	Restaurants       []Restaurant      `json:"restaurants,omitempty" gorm:"foreignKey:OwnerID"` // For restaurant owners
	DriverLocations   []DriverLocation  `json:"driver_locations,omitempty"` // For drivers
	Notifications     []Notification    `json:"notifications,omitempty"`
}

// Address represents a user's delivery address
type Address struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	UserID       uint           `json:"user_id" gorm:"not null"`
	Title        string         `json:"title" gorm:"not null"` // e.g., "Home", "Office"
	Street       string         `json:"street" gorm:"not null"`
	Building     string         `json:"building"`
	Floor        string         `json:"floor"`
	Apartment    string         `json:"apartment"`
	Landmark     string         `json:"landmark"`
	County       string         `json:"county" gorm:"not null"` // Kenyan county
	SubCounty    string         `json:"sub_county"`
	Ward         string         `json:"ward"`
	PostalCode   string         `json:"postal_code"`
	Latitude     float64        `json:"latitude"`
	Longitude    float64        `json:"longitude"`
	IsDefault    bool           `json:"is_default" gorm:"default:false"`
	Instructions string         `json:"instructions"` // Delivery instructions
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	User   User    `json:"user,omitempty"`
	Orders []Order `json:"orders,omitempty"`
}

// County represents Kenyan counties for location-based services
type County struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Name      string    `json:"name" gorm:"uniqueIndex;not null"`
	Code      string    `json:"code" gorm:"uniqueIndex;not null"` // County code
	Capital   string    `json:"capital"`
	Region    string    `json:"region"` // e.g., "Central", "Coast", "Eastern"
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relationships
	DeliveryZones []DeliveryZone `json:"delivery_zones,omitempty"`
	Restaurants   []Restaurant   `json:"restaurants,omitempty" gorm:"foreignKey:County;references:Name"`
}

// DeliveryZone represents areas where delivery is available
type DeliveryZone struct {
	ID           uint    `json:"id" gorm:"primaryKey"`
	CountyID     uint    `json:"county_id" gorm:"not null"`
	Name         string  `json:"name" gorm:"not null"`
	Description  string  `json:"description"`
	DeliveryFee  float64 `json:"delivery_fee" gorm:"not null"`
	MinOrderAmount float64 `json:"min_order_amount"`
	MaxDeliveryTime int   `json:"max_delivery_time"` // in minutes
	IsActive     bool    `json:"is_active" gorm:"default:true"`
	Boundaries   string  `json:"boundaries"` // JSON string of polygon coordinates
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`

	// Relationships
	County County `json:"county,omitempty"`
}

// DriverLocation represents real-time location of delivery drivers
type DriverLocation struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"not null"` // Driver's user ID
	Latitude  float64   `json:"latitude" gorm:"not null"`
	Longitude float64   `json:"longitude" gorm:"not null"`
	Accuracy  float64   `json:"accuracy"` // GPS accuracy in meters
	Speed     float64   `json:"speed"`    // Speed in km/h
	Heading   float64   `json:"heading"`  // Direction in degrees
	IsOnline  bool      `json:"is_online" gorm:"default:false"`
	CreatedAt time.Time `json:"created_at"`

	// Relationships
	User User `json:"user,omitempty"`
}

// Notification represents user notifications
type Notification struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	UserID    uint           `json:"user_id" gorm:"not null"`
	Title     string         `json:"title" gorm:"not null"`
	Message   string         `json:"message" gorm:"not null"`
	Type      string         `json:"type" gorm:"not null"` // order, payment, promotion, system
	Data      string         `json:"data"` // JSON data for additional context
	IsRead    bool           `json:"is_read" gorm:"default:false"`
	ReadAt    *time.Time     `json:"read_at"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	User User `json:"user,omitempty"`
}

