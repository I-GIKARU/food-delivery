package handlers

import (
	"kenyan-food-delivery/internal/config"
	"kenyan-food-delivery/internal/services"

	"gorm.io/gorm"
)

// Handler holds all the handlers and their dependencies
type Handler struct {
	db       *gorm.DB
	config   *config.Config
	services *services.Services
}

// New creates a new handler instance
func New(db *gorm.DB, cfg *config.Config) *Handler {
	services := services.New(db, cfg)
	
	return &Handler{
		db:       db,
		config:   cfg,
		services: services,
	}
}

