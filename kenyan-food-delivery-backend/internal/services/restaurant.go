package services

import (
	"kenyan-food-delivery/internal/config"
	"kenyan-food-delivery/internal/models"

	"gorm.io/gorm"
)

// RestaurantService handles restaurant-related operations
type RestaurantService struct {
	db     *gorm.DB
	config *config.Config
}

// NewRestaurantService creates a new restaurant service
func NewRestaurantService(db *gorm.DB, cfg *config.Config) *RestaurantService {
	return &RestaurantService{
		db:     db,
		config: cfg,
	}
}

// GetRestaurants gets all active restaurants with pagination
func (s *RestaurantService) GetRestaurants(page, limit int, county string) ([]models.Restaurant, int64, error) {
	var restaurants []models.Restaurant
	var total int64

	query := s.db.Model(&models.Restaurant{}).Where("status = ?", models.RestaurantStatusApproved)
	
	if county != "" {
		query = query.Where("county = ?", county)
	}

	// Get total count
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	offset := (page - 1) * limit
	if err := query.Preload("Categories").Preload("Cuisines").
		Offset(offset).Limit(limit).
		Order("rating DESC, total_orders DESC").
		Find(&restaurants).Error; err != nil {
		return nil, 0, err
	}

	return restaurants, total, nil
}

// GetRestaurantByID gets a restaurant by ID with menu
func (s *RestaurantService) GetRestaurantByID(id uint) (*models.Restaurant, error) {
	var restaurant models.Restaurant
	if err := s.db.Preload("Categories").Preload("Cuisines").
		Preload("MenuItems.Category").Preload("MenuItems.Cuisine").
		First(&restaurant, id).Error; err != nil {
		return nil, err
	}

	return &restaurant, nil
}

// SearchRestaurants searches restaurants by name or cuisine
func (s *RestaurantService) SearchRestaurants(query string, page, limit int) ([]models.Restaurant, int64, error) {
	var restaurants []models.Restaurant
	var total int64

	dbQuery := s.db.Model(&models.Restaurant{}).
		Where("status = ? AND (name ILIKE ? OR description ILIKE ?)", 
			models.RestaurantStatusApproved, "%"+query+"%", "%"+query+"%")

	// Get total count
	if err := dbQuery.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	offset := (page - 1) * limit
	if err := dbQuery.Preload("Categories").Preload("Cuisines").
		Offset(offset).Limit(limit).
		Order("rating DESC").
		Find(&restaurants).Error; err != nil {
		return nil, 0, err
	}

	return restaurants, total, nil
}

// GetRestaurantsByCuisine gets restaurants by cuisine type
func (s *RestaurantService) GetRestaurantsByCuisine(cuisine string, page, limit int) ([]models.Restaurant, int64, error) {
	var restaurants []models.Restaurant
	var total int64

	// Join with cuisines table
	query := s.db.Model(&models.Restaurant{}).
		Joins("JOIN restaurant_cuisine_mappings rcm ON restaurants.id = rcm.restaurant_id").
		Joins("JOIN cuisines c ON rcm.cuisine_id = c.id").
		Where("restaurants.status = ? AND c.name = ?", models.RestaurantStatusApproved, cuisine)

	// Get total count
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	offset := (page - 1) * limit
	if err := query.Preload("Categories").Preload("Cuisines").
		Offset(offset).Limit(limit).
		Order("restaurants.rating DESC").
		Find(&restaurants).Error; err != nil {
		return nil, 0, err
	}

	return restaurants, total, nil
}

