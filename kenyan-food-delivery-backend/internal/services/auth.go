package services

import (
	"errors"
	"time"

	"kenyan-food-delivery/internal/auth"
	"kenyan-food-delivery/internal/config"
	"kenyan-food-delivery/internal/models"

	"gorm.io/gorm"
)

// AuthService handles authentication operations
type AuthService struct {
	db     *gorm.DB
	config *config.Config
}

// NewAuthService creates a new auth service
func NewAuthService(db *gorm.DB, cfg *config.Config) *AuthService {
	return &AuthService{
		db:     db,
		config: cfg,
	}
}

// RegisterRequest represents user registration request
type RegisterRequest struct {
	Email           string           `json:"email" binding:"required,email"`
	PhoneNumber     string           `json:"phone_number" binding:"required"`
	Password        string           `json:"password" binding:"required,min=6"`
	FirstName       string           `json:"first_name" binding:"required"`
	LastName        string           `json:"last_name" binding:"required"`
	Role            models.UserRole  `json:"role"`
	PreferredLanguage string         `json:"preferred_language"`
}

// LoginRequest represents user login request
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse represents authentication response
type AuthResponse struct {
	User         *models.User `json:"user"`
	AccessToken  string       `json:"access_token"`
	RefreshToken string       `json:"refresh_token"`
	ExpiresIn    int64        `json:"expires_in"`
}

// Register creates a new user account
func (s *AuthService) Register(req *RegisterRequest) (*AuthResponse, error) {
	// Check if user already exists
	var existingUser models.User
	if err := s.db.Where("email = ? OR phone_number = ?", req.Email, req.PhoneNumber).First(&existingUser).Error; err == nil {
		return nil, errors.New("user with this email or phone number already exists")
	}

	// Hash password
	hashedPassword, err := auth.HashPassword(req.Password)
	if err != nil {
		return nil, err
	}

	// Set default role if not provided
	role := req.Role
	if role == "" {
		role = models.RoleCustomer
	}

	// Set default language if not provided
	language := req.PreferredLanguage
	if language == "" {
		language = "en"
	}

	// Create user
	user := &models.User{
		Email:             req.Email,
		PhoneNumber:       req.PhoneNumber,
		Password:          hashedPassword,
		FirstName:         req.FirstName,
		LastName:          req.LastName,
		Role:              role,
		Status:            models.StatusActive,
		PreferredLanguage: language,
	}

	if err := s.db.Create(user).Error; err != nil {
		return nil, err
	}

	// Generate tokens
	accessToken, err := auth.GenerateToken(user)
	if err != nil {
		return nil, err
	}

	refreshToken, err := auth.GenerateRefreshToken(user)
	if err != nil {
		return nil, err
	}

	// Remove password from response
	user.Password = ""

	return &AuthResponse{
		User:         user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    24 * 60 * 60, // 24 hours in seconds
	}, nil
}

// Login authenticates a user
func (s *AuthService) Login(req *LoginRequest) (*AuthResponse, error) {
	// Find user by email
	var user models.User
	if err := s.db.Where("email = ?", req.Email).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, errors.New("invalid email or password")
		}
		return nil, err
	}

	// Check if user is active
	if user.Status != models.StatusActive {
		return nil, errors.New("account is not active")
	}

	// Check password
	if err := auth.CheckPassword(req.Password, user.Password); err != nil {
		return nil, errors.New("invalid email or password")
	}

	// Update last login time
	now := time.Now()
	user.LastLoginAt = &now
	s.db.Save(&user)

	// Generate tokens
	accessToken, err := auth.GenerateToken(&user)
	if err != nil {
		return nil, err
	}

	refreshToken, err := auth.GenerateRefreshToken(&user)
	if err != nil {
		return nil, err
	}

	// Remove password from response
	user.Password = ""

	return &AuthResponse{
		User:         &user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    24 * 60 * 60, // 24 hours in seconds
	}, nil
}

// RefreshToken generates new access token using refresh token
func (s *AuthService) RefreshToken(refreshToken string) (*AuthResponse, error) {
	// Validate refresh token
	claims, err := auth.ValidateRefreshToken(refreshToken)
	if err != nil {
		return nil, errors.New("invalid refresh token")
	}

	// Get user
	var user models.User
	if err := s.db.First(&user, claims.UserID).Error; err != nil {
		return nil, errors.New("user not found")
	}

	// Check if user is still active
	if user.Status != models.StatusActive {
		return nil, errors.New("account is not active")
	}

	// Generate new tokens
	accessToken, err := auth.GenerateToken(&user)
	if err != nil {
		return nil, err
	}

	newRefreshToken, err := auth.GenerateRefreshToken(&user)
	if err != nil {
		return nil, err
	}

	// Remove password from response
	user.Password = ""

	return &AuthResponse{
		User:         &user,
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		ExpiresIn:    24 * 60 * 60, // 24 hours in seconds
	}, nil
}

// GetUserByID gets user by ID
func (s *AuthService) GetUserByID(userID uint) (*models.User, error) {
	var user models.User
	if err := s.db.First(&user, userID).Error; err != nil {
		return nil, err
	}

	// Remove password from response
	user.Password = ""
	return &user, nil
}

