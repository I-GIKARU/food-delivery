package services

import (
	"errors"

	"kenyan-food-delivery/internal/config"
	"kenyan-food-delivery/internal/models"

	"gorm.io/gorm"
)

// UserService handles user-related operations
type UserService struct {
	db     *gorm.DB
	config *config.Config
}

// NewUserService creates a new user service
func NewUserService(db *gorm.DB, cfg *config.Config) *UserService {
	return &UserService{
		db:     db,
		config: cfg,
	}
}

// AddressRequest represents address creation/update request
type AddressRequest struct {
	Title        string  `json:"title" binding:"required"`
	Street       string  `json:"street" binding:"required"`
	Building     string  `json:"building"`
	Floor        string  `json:"floor"`
	Apartment    string  `json:"apartment"`
	Landmark     string  `json:"landmark"`
	County       string  `json:"county" binding:"required"`
	SubCounty    string  `json:"sub_county"`
	Ward         string  `json:"ward"`
	PostalCode   string  `json:"postal_code"`
	Latitude     float64 `json:"latitude"`
	Longitude    float64 `json:"longitude"`
	IsDefault    bool    `json:"is_default"`
	Instructions string  `json:"instructions"`
}

// AddAddress adds a new address for a user
func (s *UserService) AddAddress(userID uint, req *AddressRequest) (*models.Address, error) {
	// If this is set as default, unset other default addresses
	if req.IsDefault {
		s.db.Model(&models.Address{}).Where("user_id = ?", userID).Update("is_default", false)
	}

	address := &models.Address{
		UserID:       userID,
		Title:        req.Title,
		Street:       req.Street,
		Building:     req.Building,
		Floor:        req.Floor,
		Apartment:    req.Apartment,
		Landmark:     req.Landmark,
		County:       req.County,
		SubCounty:    req.SubCounty,
		Ward:         req.Ward,
		PostalCode:   req.PostalCode,
		Latitude:     req.Latitude,
		Longitude:    req.Longitude,
		IsDefault:    req.IsDefault,
		Instructions: req.Instructions,
	}

	if err := s.db.Create(address).Error; err != nil {
		return nil, err
	}

	return address, nil
}

// GetUserAddresses gets all addresses for a user
func (s *UserService) GetUserAddresses(userID uint) ([]models.Address, error) {
	var addresses []models.Address
	if err := s.db.Where("user_id = ?", userID).Order("is_default DESC, created_at DESC").Find(&addresses).Error; err != nil {
		return nil, err
	}

	return addresses, nil
}

// UpdateAddress updates an existing address
func (s *UserService) UpdateAddress(userID uint, addressID uint, req *AddressRequest) (*models.Address, error) {
	var address models.Address
	if err := s.db.Where("id = ? AND user_id = ?", addressID, userID).First(&address).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, errors.New("address not found")
		}
		return nil, err
	}

	// If this is set as default, unset other default addresses
	if req.IsDefault && !address.IsDefault {
		s.db.Model(&models.Address{}).Where("user_id = ? AND id != ?", userID, addressID).Update("is_default", false)
	}

	// Update fields
	address.Title = req.Title
	address.Street = req.Street
	address.Building = req.Building
	address.Floor = req.Floor
	address.Apartment = req.Apartment
	address.Landmark = req.Landmark
	address.County = req.County
	address.SubCounty = req.SubCounty
	address.Ward = req.Ward
	address.PostalCode = req.PostalCode
	address.Latitude = req.Latitude
	address.Longitude = req.Longitude
	address.IsDefault = req.IsDefault
	address.Instructions = req.Instructions

	if err := s.db.Save(&address).Error; err != nil {
		return nil, err
	}

	return &address, nil
}

// DeleteAddress deletes an address
func (s *UserService) DeleteAddress(userID uint, addressID uint) error {
	result := s.db.Where("id = ? AND user_id = ?", addressID, userID).Delete(&models.Address{})
	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("address not found")
	}

	return nil
}

// GetUserByID gets a user by ID with relationships
func (s *UserService) GetUserByID(userID uint) (*models.User, error) {
	var user models.User
	if err := s.db.Preload("Addresses").First(&user, userID).Error; err != nil {
		return nil, err
	}

	// Remove password from response
	user.Password = ""
	return &user, nil
}

