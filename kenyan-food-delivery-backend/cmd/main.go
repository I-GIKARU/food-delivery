package main

import (
	"log"
	"net/http"
	"os"

	"kenyan-food-delivery/internal/config"
	"kenyan-food-delivery/internal/database"
	"kenyan-food-delivery/internal/handlers"
	"kenyan-food-delivery/internal/middleware"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Load configuration
	cfg := config.Load()

	// Initialize database
	db, err := database.Initialize(cfg.DatabaseURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Run migrations
	if err := database.Migrate(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Initialize Gin router
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	// Add middleware
	router.Use(middleware.CORS())
	router.Use(middleware.Logger())
	router.Use(middleware.ErrorHandler())

	// Initialize handlers
	h := handlers.New(db, cfg)

	// Setup routes
	setupRoutes(router, h)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe("0.0.0.0:"+port, router))
}

func setupRoutes(router *gin.Engine, h *handlers.Handler) {
	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "healthy",
			"service": "Kenyan Food Delivery API",
			"version": "1.0.0",
		})
	})

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Authentication routes
		auth := v1.Group("/auth")
		{
			auth.POST("/register", h.Register)
			auth.POST("/login", h.Login)
			auth.POST("/refresh", h.RefreshToken)
			auth.POST("/logout", middleware.AuthRequired(), h.Logout)
		}

		// User routes
		users := v1.Group("/users")
		users.Use(middleware.AuthRequired())
		{
			users.GET("/profile", h.GetProfile)
			users.PUT("/profile", h.UpdateProfile)
			users.POST("/address", h.AddAddress)
			users.GET("/addresses", h.GetAddresses)
			users.PUT("/addresses/:id", h.UpdateAddress)
			users.DELETE("/addresses/:id", h.DeleteAddress)
		}

		// Restaurant routes
		restaurants := v1.Group("/restaurants")
		{
			restaurants.GET("", h.GetRestaurants)
			restaurants.GET("/:id", h.GetRestaurant)
			restaurants.GET("/:id/menu", h.GetRestaurantMenu)
			restaurants.GET("/search", h.SearchRestaurants)
			restaurants.GET("/cuisine/:cuisine", h.GetRestaurantsByCuisine)
			restaurants.GET("/location/:county", h.GetRestaurantsByLocation)
		}

		// Restaurant owner routes
		restaurantOwner := v1.Group("/restaurant-owner")
		restaurantOwner.Use(middleware.AuthRequired(), middleware.RestaurantOwnerRequired())
		{
			restaurantOwner.POST("/restaurant", h.CreateRestaurant)
			restaurantOwner.PUT("/restaurant/:id", h.UpdateRestaurant)
			restaurantOwner.GET("/restaurant/:id/orders", h.GetRestaurantOrders)
			restaurantOwner.PUT("/orders/:id/status", h.UpdateOrderStatus)
			
			// Menu management
			restaurantOwner.POST("/restaurant/:id/menu", h.AddMenuItem)
			restaurantOwner.PUT("/menu/:id", h.UpdateMenuItem)
			restaurantOwner.DELETE("/menu/:id", h.DeleteMenuItem)
		}

		// Order routes
		orders := v1.Group("/orders")
		orders.Use(middleware.AuthRequired())
		{
			orders.POST("", h.CreateOrder)
			orders.GET("", h.GetUserOrders)
			orders.GET("/:id", h.GetOrder)
			orders.PUT("/:id/cancel", h.CancelOrder)
			orders.GET("/:id/track", h.TrackOrder)
		}

		// Payment routes
		payments := v1.Group("/payments")
		payments.Use(middleware.AuthRequired())
		{
			payments.POST("/mpesa/stk-push", h.InitiateMpesaPayment)
			payments.POST("/mpesa/callback", h.MpesaCallback)
			payments.GET("/methods", h.GetPaymentMethods)
		}

		// Delivery routes
		delivery := v1.Group("/delivery")
		delivery.Use(middleware.AuthRequired())
		{
			delivery.GET("/zones", h.GetDeliveryZones)
			delivery.GET("/fee", h.CalculateDeliveryFee)
		}

		// Driver routes
		driver := v1.Group("/driver")
		driver.Use(middleware.AuthRequired(), middleware.DriverRequired())
		{
			driver.GET("/orders/available", h.GetAvailableDeliveries)
			driver.POST("/orders/:id/accept", h.AcceptDelivery)
			driver.PUT("/orders/:id/status", h.UpdateDeliveryStatus)
			driver.POST("/location", h.UpdateDriverLocation)
		}

		// Admin routes
		admin := v1.Group("/admin")
		admin.Use(middleware.AuthRequired(), middleware.AdminRequired())
		{
			admin.GET("/stats", h.GetAdminStats)
			admin.GET("/users", h.GetAllUsers)
			admin.GET("/restaurants", h.GetAllRestaurants)
			admin.GET("/orders", h.GetAllOrders)
			admin.PUT("/restaurants/:id/approve", h.ApproveRestaurant)
			admin.PUT("/users/:id/status", h.UpdateUserStatus)
		}
	}
}

