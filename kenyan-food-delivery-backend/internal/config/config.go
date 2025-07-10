package config

import (
	"os"
	"strconv"
)

// Config holds all configuration for the application
type Config struct {
	Environment   string
	DatabaseURL   string
	JWTSecret     string
	Port          string
	
	// M-Pesa Configuration
	MpesaConsumerKey    string
	MpesaConsumerSecret string
	MpesaPasskey        string
	MpesaShortcode      string
	MpesaEnvironment    string // sandbox or production
	
	// Email Configuration
	SMTPHost     string
	SMTPPort     int
	SMTPUsername string
	SMTPPassword string
	
	// File Upload Configuration
	MaxFileSize      int64
	AllowedFileTypes []string
	UploadPath       string
	
	// Rate Limiting
	RateLimitRequests int
	RateLimitWindow   int // in minutes
	
	// Delivery Configuration
	DefaultDeliveryFee float64
	MaxDeliveryRadius  float64 // in kilometers
}

// Load loads configuration from environment variables
func Load() *Config {
	return &Config{
		Environment: getEnv("ENVIRONMENT", "development"),
		DatabaseURL: getEnv("DATABASE_URL", "postgres://user:password@localhost/kenyan_food_delivery?sslmode=disable"),
		JWTSecret:   getEnv("JWT_SECRET", "your-super-secret-jwt-key-change-this-in-production"),
		Port:        getEnv("PORT", "8080"),
		
		// M-Pesa Configuration
		MpesaConsumerKey:    getEnv("MPESA_CONSUMER_KEY", ""),
		MpesaConsumerSecret: getEnv("MPESA_CONSUMER_SECRET", ""),
		MpesaPasskey:        getEnv("MPESA_PASSKEY", ""),
		MpesaShortcode:      getEnv("MPESA_SHORTCODE", "174379"),
		MpesaEnvironment:    getEnv("MPESA_ENVIRONMENT", "sandbox"),
		
		// Email Configuration
		SMTPHost:     getEnv("SMTP_HOST", "smtp.gmail.com"),
		SMTPPort:     getEnvAsInt("SMTP_PORT", 587),
		SMTPUsername: getEnv("SMTP_USERNAME", ""),
		SMTPPassword: getEnv("SMTP_PASSWORD", ""),
		
		// File Upload Configuration
		MaxFileSize:      getEnvAsInt64("MAX_FILE_SIZE", 10*1024*1024), // 10MB
		AllowedFileTypes: []string{"image/jpeg", "image/png", "image/gif"},
		UploadPath:       getEnv("UPLOAD_PATH", "./uploads"),
		
		// Rate Limiting
		RateLimitRequests: getEnvAsInt("RATE_LIMIT_REQUESTS", 100),
		RateLimitWindow:   getEnvAsInt("RATE_LIMIT_WINDOW", 15),
		
		// Delivery Configuration
		DefaultDeliveryFee: getEnvAsFloat64("DEFAULT_DELIVERY_FEE", 150.0), // KES 150
		MaxDeliveryRadius:  getEnvAsFloat64("MAX_DELIVERY_RADIUS", 25.0),   // 25km
	}
}

// getEnv gets an environment variable with a fallback value
func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

// getEnvAsInt gets an environment variable as integer with a fallback value
func getEnvAsInt(key string, fallback int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return fallback
}

// getEnvAsInt64 gets an environment variable as int64 with a fallback value
func getEnvAsInt64(key string, fallback int64) int64 {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.ParseInt(value, 10, 64); err == nil {
			return intValue
		}
	}
	return fallback
}

// getEnvAsFloat64 gets an environment variable as float64 with a fallback value
func getEnvAsFloat64(key string, fallback float64) float64 {
	if value := os.Getenv(key); value != "" {
		if floatValue, err := strconv.ParseFloat(value, 64); err == nil {
			return floatValue
		}
	}
	return fallback
}

