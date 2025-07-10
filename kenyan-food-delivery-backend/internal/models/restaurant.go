package models

import (
	"time"

	"gorm.io/gorm"
)

// RestaurantStatus represents the status of a restaurant
type RestaurantStatus string

const (
	RestaurantStatusPending  RestaurantStatus = "pending"
	RestaurantStatusApproved RestaurantStatus = "approved"
	RestaurantStatusSuspended RestaurantStatus = "suspended"
	RestaurantStatusClosed   RestaurantStatus = "closed"
)

// Restaurant represents a restaurant in the system
type Restaurant struct {
	ID              uint             `json:"id" gorm:"primaryKey"`
	OwnerID         uint             `json:"owner_id" gorm:"not null"`
	Name            string           `json:"name" gorm:"not null"`
	Description     string           `json:"description"`
	PhoneNumber     string           `json:"phone_number" gorm:"not null"`
	Email           string           `json:"email"`
	Address         string           `json:"address" gorm:"not null"`
	County          string           `json:"county" gorm:"not null"`
	SubCounty       string           `json:"sub_county"`
	Ward            string           `json:"ward"`
	Latitude        float64          `json:"latitude"`
	Longitude       float64          `json:"longitude"`
	CoverImage      string           `json:"cover_image"`
	Logo            string           `json:"logo"`
	Status          RestaurantStatus `json:"status" gorm:"default:'pending'"`
	IsOpen          bool             `json:"is_open" gorm:"default:true"`
	OpeningTime     string           `json:"opening_time"` // e.g., "08:00"
	ClosingTime     string           `json:"closing_time"` // e.g., "22:00"
	DeliveryTime    int              `json:"delivery_time"` // Average delivery time in minutes
	MinOrderAmount  float64          `json:"min_order_amount"`
	DeliveryFee     float64          `json:"delivery_fee"`
	Rating          float64          `json:"rating" gorm:"default:0"`
	TotalReviews    int              `json:"total_reviews" gorm:"default:0"`
	TotalOrders     int              `json:"total_orders" gorm:"default:0"`
	BusinessLicense string           `json:"business_license"` // License number
	TaxPin          string           `json:"tax_pin"` // KRA PIN
	BankAccount     string           `json:"bank_account"` // For payments
	BankName        string           `json:"bank_name"`
	CreatedAt       time.Time        `json:"created_at"`
	UpdatedAt       time.Time        `json:"updated_at"`
	DeletedAt       gorm.DeletedAt   `json:"-" gorm:"index"`

	// Relationships
	Owner      User                   `json:"owner,omitempty"`
	MenuItems  []MenuItem             `json:"menu_items,omitempty"`
	Orders     []Order                `json:"orders,omitempty"`
	Reviews    []Review               `json:"reviews,omitempty"`
	Categories []RestaurantCategory   `json:"categories,omitempty" gorm:"many2many:restaurant_category_mappings;"`
	Cuisines   []Cuisine              `json:"cuisines,omitempty" gorm:"many2many:restaurant_cuisine_mappings;"`
}

// Cuisine represents different types of cuisine (Kenyan context)
type Cuisine struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	Name        string    `json:"name" gorm:"uniqueIndex;not null"`
	NameSwahili string    `json:"name_swahili"` // Swahili translation
	Description string    `json:"description"`
	Image       string    `json:"image"`
	IsPopular   bool      `json:"is_popular" gorm:"default:false"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// Relationships
	Restaurants []Restaurant `json:"restaurants,omitempty" gorm:"many2many:restaurant_cuisine_mappings;"`
	MenuItems   []MenuItem   `json:"menu_items,omitempty"`
}

// RestaurantCategory represents categories for restaurants
type RestaurantCategory struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	Name        string    `json:"name" gorm:"uniqueIndex;not null"`
	NameSwahili string    `json:"name_swahili"` // Swahili translation
	Description string    `json:"description"`
	Icon        string    `json:"icon"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	SortOrder   int       `json:"sort_order" gorm:"default:0"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// Relationships
	Restaurants []Restaurant `json:"restaurants,omitempty" gorm:"many2many:restaurant_category_mappings;"`
}

// Category represents menu item categories
type Category struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	RestaurantID uint     `json:"restaurant_id" gorm:"not null"`
	Name        string    `json:"name" gorm:"not null"`
	NameSwahili string    `json:"name_swahili"` // Swahili translation
	Description string    `json:"description"`
	Image       string    `json:"image"`
	IsActive    bool      `json:"is_active" gorm:"default:true"`
	SortOrder   int       `json:"sort_order" gorm:"default:0"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// Relationships
	Restaurant Restaurant `json:"restaurant,omitempty"`
	MenuItems  []MenuItem `json:"menu_items,omitempty"`
}

// MenuItemStatus represents the status of a menu item
type MenuItemStatus string

const (
	MenuItemStatusAvailable   MenuItemStatus = "available"
	MenuItemStatusUnavailable MenuItemStatus = "unavailable"
	MenuItemStatusOutOfStock  MenuItemStatus = "out_of_stock"
)

// MenuItem represents a food item in a restaurant's menu
type MenuItem struct {
	ID              uint           `json:"id" gorm:"primaryKey"`
	RestaurantID    uint           `json:"restaurant_id" gorm:"not null"`
	CategoryID      uint           `json:"category_id" gorm:"not null"`
	CuisineID       *uint          `json:"cuisine_id"`
	Name            string         `json:"name" gorm:"not null"`
	NameSwahili     string         `json:"name_swahili"` // Swahili translation
	Description     string         `json:"description"`
	DescriptionSwahili string      `json:"description_swahili"` // Swahili translation
	Price           float64        `json:"price" gorm:"not null"`
	DiscountPrice   *float64       `json:"discount_price"`
	Image           string         `json:"image"`
	Images          string         `json:"images"` // JSON array of image URLs
	Status          MenuItemStatus `json:"status" gorm:"default:'available'"`
	IsVegetarian    bool           `json:"is_vegetarian" gorm:"default:false"`
	IsVegan         bool           `json:"is_vegan" gorm:"default:false"`
	IsHalal         bool           `json:"is_halal" gorm:"default:false"`
	IsSpicy         bool           `json:"is_spicy" gorm:"default:false"`
	SpiceLevel      int            `json:"spice_level" gorm:"default:0"` // 0-5 scale
	PrepTime        int            `json:"prep_time"` // Preparation time in minutes
	Calories        *int           `json:"calories"`
	Ingredients     string         `json:"ingredients"` // JSON array of ingredients
	Allergens       string         `json:"allergens"`   // JSON array of allergens
	Nutritional     string         `json:"nutritional"` // JSON object with nutritional info
	IsPopular       bool           `json:"is_popular" gorm:"default:false"`
	SortOrder       int            `json:"sort_order" gorm:"default:0"`
	TotalOrders     int            `json:"total_orders" gorm:"default:0"`
	Rating          float64        `json:"rating" gorm:"default:0"`
	TotalReviews    int            `json:"total_reviews" gorm:"default:0"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	Restaurant Restaurant `json:"restaurant,omitempty"`
	Category   Category   `json:"category,omitempty"`
	Cuisine    *Cuisine   `json:"cuisine,omitempty"`
	OrderItems []OrderItem `json:"order_items,omitempty"`
	Reviews    []Review   `json:"reviews,omitempty"`
}

// Review represents customer reviews for restaurants and menu items
type Review struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	UserID       uint           `json:"user_id" gorm:"not null"`
	RestaurantID *uint          `json:"restaurant_id"`
	MenuItemID   *uint          `json:"menu_item_id"`
	OrderID      *uint          `json:"order_id"`
	Rating       int            `json:"rating" gorm:"not null;check:rating >= 1 AND rating <= 5"`
	Comment      string         `json:"comment"`
	Images       string         `json:"images"` // JSON array of image URLs
	IsVerified   bool           `json:"is_verified" gorm:"default:false"`
	IsHelpful    int            `json:"is_helpful" gorm:"default:0"` // Helpful votes count
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`

	// Relationships
	User       User       `json:"user,omitempty"`
	Restaurant *Restaurant `json:"restaurant,omitempty"`
	MenuItem   *MenuItem  `json:"menu_item,omitempty"`
	Order      *Order     `json:"order,omitempty"`
}

