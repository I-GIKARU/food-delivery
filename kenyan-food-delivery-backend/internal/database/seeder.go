package database

import (
	"kenyan-food-delivery/internal/models"

	"gorm.io/gorm"
)

// SeedData seeds the database with initial data for Kenyan context
func SeedData(db *gorm.DB) error {
	// Seed Kenyan counties
	if err := seedCounties(db); err != nil {
		return err
	}

	// Seed cuisines
	if err := seedCuisines(db); err != nil {
		return err
	}

	// Seed restaurant categories
	if err := seedRestaurantCategories(db); err != nil {
		return err
	}

	// Seed delivery zones for major cities
	if err := seedDeliveryZones(db); err != nil {
		return err
	}

	return nil
}

// seedCounties seeds Kenyan counties
func seedCounties(db *gorm.DB) error {
	counties := []models.County{
		{Name: "Nairobi", Code: "047", Capital: "Nairobi", Region: "Central"},
		{Name: "Mombasa", Code: "001", Capital: "Mombasa", Region: "Coast"},
		{Name: "Kwale", Code: "002", Capital: "Kwale", Region: "Coast"},
		{Name: "Kilifi", Code: "003", Capital: "Kilifi", Region: "Coast"},
		{Name: "Tana River", Code: "004", Capital: "Hola", Region: "Coast"},
		{Name: "Lamu", Code: "005", Capital: "Lamu", Region: "Coast"},
		{Name: "Taita Taveta", Code: "006", Capital: "Voi", Region: "Coast"},
		{Name: "Garissa", Code: "007", Capital: "Garissa", Region: "North Eastern"},
		{Name: "Wajir", Code: "008", Capital: "Wajir", Region: "North Eastern"},
		{Name: "Mandera", Code: "009", Capital: "Mandera", Region: "North Eastern"},
		{Name: "Marsabit", Code: "010", Capital: "Marsabit", Region: "Eastern"},
		{Name: "Isiolo", Code: "011", Capital: "Isiolo", Region: "Eastern"},
		{Name: "Meru", Code: "012", Capital: "Meru", Region: "Eastern"},
		{Name: "Tharaka Nithi", Code: "013", Capital: "Kathwana", Region: "Eastern"},
		{Name: "Embu", Code: "014", Capital: "Embu", Region: "Eastern"},
		{Name: "Kitui", Code: "015", Capital: "Kitui", Region: "Eastern"},
		{Name: "Machakos", Code: "016", Capital: "Machakos", Region: "Eastern"},
		{Name: "Makueni", Code: "017", Capital: "Wote", Region: "Eastern"},
		{Name: "Nyandarua", Code: "018", Capital: "Ol Kalou", Region: "Central"},
		{Name: "Nyeri", Code: "019", Capital: "Nyeri", Region: "Central"},
		{Name: "Kirinyaga", Code: "020", Capital: "Kerugoya", Region: "Central"},
		{Name: "Murang'a", Code: "021", Capital: "Murang'a", Region: "Central"},
		{Name: "Kiambu", Code: "022", Capital: "Kiambu", Region: "Central"},
		{Name: "Turkana", Code: "023", Capital: "Lodwar", Region: "Rift Valley"},
		{Name: "West Pokot", Code: "024", Capital: "Kapenguria", Region: "Rift Valley"},
		{Name: "Samburu", Code: "025", Capital: "Maralal", Region: "Rift Valley"},
		{Name: "Trans Nzoia", Code: "026", Capital: "Kitale", Region: "Rift Valley"},
		{Name: "Uasin Gishu", Code: "027", Capital: "Eldoret", Region: "Rift Valley"},
		{Name: "Elgeyo Marakwet", Code: "028", Capital: "Iten", Region: "Rift Valley"},
		{Name: "Nandi", Code: "029", Capital: "Kapsabet", Region: "Rift Valley"},
		{Name: "Baringo", Code: "030", Capital: "Kabarnet", Region: "Rift Valley"},
		{Name: "Laikipia", Code: "031", Capital: "Rumuruti", Region: "Rift Valley"},
		{Name: "Nakuru", Code: "032", Capital: "Nakuru", Region: "Rift Valley"},
		{Name: "Narok", Code: "033", Capital: "Narok", Region: "Rift Valley"},
		{Name: "Kajiado", Code: "034", Capital: "Kajiado", Region: "Rift Valley"},
		{Name: "Kericho", Code: "035", Capital: "Kericho", Region: "Rift Valley"},
		{Name: "Bomet", Code: "036", Capital: "Bomet", Region: "Rift Valley"},
		{Name: "Kakamega", Code: "037", Capital: "Kakamega", Region: "Western"},
		{Name: "Vihiga", Code: "038", Capital: "Vihiga", Region: "Western"},
		{Name: "Bungoma", Code: "039", Capital: "Bungoma", Region: "Western"},
		{Name: "Busia", Code: "040", Capital: "Busia", Region: "Western"},
		{Name: "Siaya", Code: "041", Capital: "Siaya", Region: "Nyanza"},
		{Name: "Kisumu", Code: "042", Capital: "Kisumu", Region: "Nyanza"},
		{Name: "Homa Bay", Code: "043", Capital: "Homa Bay", Region: "Nyanza"},
		{Name: "Migori", Code: "044", Capital: "Migori", Region: "Nyanza"},
		{Name: "Kisii", Code: "045", Capital: "Kisii", Region: "Nyanza"},
		{Name: "Nyamira", Code: "046", Capital: "Nyamira", Region: "Nyanza"},
	}

	for _, county := range counties {
		var existingCounty models.County
		if err := db.Where("code = ?", county.Code).First(&existingCounty).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				if err := db.Create(&county).Error; err != nil {
					return err
				}
			} else {
				return err
			}
		}
	}

	return nil
}

// seedCuisines seeds cuisine types with Kenyan context
func seedCuisines(db *gorm.DB) error {
	cuisines := []models.Cuisine{
		{Name: "Kenyan Traditional", NameSwahili: "Chakula cha Kikenyeji", Description: "Traditional Kenyan dishes", IsPopular: true},
		{Name: "Swahili", NameSwahili: "Chakula cha Kiswahili", Description: "Coastal Swahili cuisine", IsPopular: true},
		{Name: "Indian", NameSwahili: "Chakula cha Kihindi", Description: "Indian cuisine popular in Kenya", IsPopular: true},
		{Name: "Chinese", NameSwahili: "Chakula cha Kichina", Description: "Chinese cuisine", IsPopular: false},
		{Name: "Italian", NameSwahili: "Chakula cha Kiitaliano", Description: "Italian cuisine including pizza and pasta", IsPopular: true},
		{Name: "American", NameSwahili: "Chakula cha Kimarekani", Description: "American fast food", IsPopular: true},
		{Name: "Ethiopian", NameSwahili: "Chakula cha Kiethiopia", Description: "Ethiopian cuisine", IsPopular: false},
		{Name: "Lebanese", NameSwahili: "Chakula cha Kilebanoni", Description: "Lebanese and Middle Eastern cuisine", IsPopular: false},
		{Name: "Continental", NameSwahili: "Chakula cha Ulaya", Description: "European continental cuisine", IsPopular: false},
		{Name: "Vegetarian", NameSwahili: "Chakula cha Mboga", Description: "Vegetarian dishes", IsPopular: false},
		{Name: "Seafood", NameSwahili: "Chakula cha Baharini", Description: "Fresh seafood dishes", IsPopular: true},
		{Name: "BBQ & Grills", NameSwahili: "Nyama ya Kuchoma", Description: "Barbecue and grilled meats", IsPopular: true},
	}

	for _, cuisine := range cuisines {
		var existingCuisine models.Cuisine
		if err := db.Where("name = ?", cuisine.Name).First(&existingCuisine).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				if err := db.Create(&cuisine).Error; err != nil {
					return err
				}
			} else {
				return err
			}
		}
	}

	return nil
}

// seedRestaurantCategories seeds restaurant categories
func seedRestaurantCategories(db *gorm.DB) error {
	categories := []models.RestaurantCategory{
		{Name: "Fast Food", NameSwahili: "Chakula cha Haraka", Description: "Quick service restaurants", IsActive: true, SortOrder: 1},
		{Name: "Fine Dining", NameSwahili: "Chakula cha Hali ya Juu", Description: "Upscale dining restaurants", IsActive: true, SortOrder: 2},
		{Name: "Casual Dining", NameSwahili: "Chakula cha Kawaida", Description: "Casual dining restaurants", IsActive: true, SortOrder: 3},
		{Name: "Coffee & Tea", NameSwahili: "Kahawa na Chai", Description: "Coffee shops and tea houses", IsActive: true, SortOrder: 4},
		{Name: "Bakery", NameSwahili: "Duka la Mkate", Description: "Bakeries and pastry shops", IsActive: true, SortOrder: 5},
		{Name: "Street Food", NameSwahili: "Chakula cha Mitaani", Description: "Street food vendors", IsActive: true, SortOrder: 6},
		{Name: "Juice Bar", NameSwahili: "Duka la Juisi", Description: "Fresh juice and smoothie bars", IsActive: true, SortOrder: 7},
		{Name: "Ice Cream", NameSwahili: "Aiskrimu", Description: "Ice cream and dessert shops", IsActive: true, SortOrder: 8},
		{Name: "Healthy Food", NameSwahili: "Chakula cha Afya", Description: "Health-focused restaurants", IsActive: true, SortOrder: 9},
		{Name: "Local Joints", NameSwahili: "Vibanda vya Mtaani", Description: "Local neighborhood eateries", IsActive: true, SortOrder: 10},
	}

	for _, category := range categories {
		var existingCategory models.RestaurantCategory
		if err := db.Where("name = ?", category.Name).First(&existingCategory).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				if err := db.Create(&category).Error; err != nil {
					return err
				}
			} else {
				return err
			}
		}
	}

	return nil
}

// seedDeliveryZones seeds delivery zones for major Kenyan cities
func seedDeliveryZones(db *gorm.DB) error {
	// Get Nairobi county
	var nairobiCounty models.County
	if err := db.Where("name = ?", "Nairobi").First(&nairobiCounty).Error; err != nil {
		return err
	}

	// Get Mombasa county
	var mombasaCounty models.County
	if err := db.Where("name = ?", "Mombasa").First(&mombasaCounty).Error; err != nil {
		return err
	}

	// Get Kisumu county
	var kisumuCounty models.County
	if err := db.Where("name = ?", "Kisumu").First(&kisumuCounty).Error; err != nil {
		return err
	}

	deliveryZones := []models.DeliveryZone{
		// Nairobi zones
		{CountyID: nairobiCounty.ID, Name: "CBD", Description: "Central Business District", DeliveryFee: 100, MinOrderAmount: 500, MaxDeliveryTime: 30, IsActive: true},
		{CountyID: nairobiCounty.ID, Name: "Westlands", Description: "Westlands area", DeliveryFee: 150, MinOrderAmount: 600, MaxDeliveryTime: 45, IsActive: true},
		{CountyID: nairobiCounty.ID, Name: "Karen", Description: "Karen and surrounding areas", DeliveryFee: 200, MinOrderAmount: 800, MaxDeliveryTime: 60, IsActive: true},
		{CountyID: nairobiCounty.ID, Name: "Eastlands", Description: "Eastlands areas", DeliveryFee: 120, MinOrderAmount: 500, MaxDeliveryTime: 45, IsActive: true},
		{CountyID: nairobiCounty.ID, Name: "Kileleshwa", Description: "Kileleshwa and nearby areas", DeliveryFee: 150, MinOrderAmount: 600, MaxDeliveryTime: 40, IsActive: true},

		// Mombasa zones
		{CountyID: mombasaCounty.ID, Name: "Mombasa Island", Description: "Mombasa Island", DeliveryFee: 120, MinOrderAmount: 500, MaxDeliveryTime: 35, IsActive: true},
		{CountyID: mombasaCounty.ID, Name: "Nyali", Description: "Nyali area", DeliveryFee: 150, MinOrderAmount: 600, MaxDeliveryTime: 45, IsActive: true},
		{CountyID: mombasaCounty.ID, Name: "Bamburi", Description: "Bamburi area", DeliveryFee: 180, MinOrderAmount: 700, MaxDeliveryTime: 50, IsActive: true},

		// Kisumu zones
		{CountyID: kisumuCounty.ID, Name: "Kisumu Central", Description: "Kisumu city center", DeliveryFee: 100, MinOrderAmount: 400, MaxDeliveryTime: 30, IsActive: true},
		{CountyID: kisumuCounty.ID, Name: "Milimani", Description: "Milimani area", DeliveryFee: 120, MinOrderAmount: 500, MaxDeliveryTime: 40, IsActive: true},
	}

	for _, zone := range deliveryZones {
		var existingZone models.DeliveryZone
		if err := db.Where("county_id = ? AND name = ?", zone.CountyID, zone.Name).First(&existingZone).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				if err := db.Create(&zone).Error; err != nil {
					return err
				}
			} else {
				return err
			}
		}
	}

	return nil
}

