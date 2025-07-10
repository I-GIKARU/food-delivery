package location

import (
	"math"
)

// County represents a Kenyan county
type County struct {
	ID      int    `json:"id"`
	Name    string `json:"name"`
	Code    string `json:"code"`
	Capital string `json:"capital"`
	Region  string `json:"region"`
}

// KenyanCounties contains all 47 Kenyan counties
var KenyanCounties = []County{
	{1, "Mombasa", "001", "Mombasa", "Coast"},
	{2, "Kwale", "002", "Kwale", "Coast"},
	{3, "Kilifi", "003", "Kilifi", "Coast"},
	{4, "Tana River", "004", "Hola", "Coast"},
	{5, "Lamu", "005", "Lamu", "Coast"},
	{6, "Taita Taveta", "006", "Voi", "Coast"},
	{7, "Garissa", "007", "Garissa", "North Eastern"},
	{8, "Wajir", "008", "Wajir", "North Eastern"},
	{9, "Mandera", "009", "Mandera", "North Eastern"},
	{10, "Marsabit", "010", "Marsabit", "Eastern"},
	{11, "Isiolo", "011", "Isiolo", "Eastern"},
	{12, "Meru", "012", "Meru", "Eastern"},
	{13, "Tharaka Nithi", "013", "Kathwana", "Eastern"},
	{14, "Embu", "014", "Embu", "Eastern"},
	{15, "Kitui", "015", "Kitui", "Eastern"},
	{16, "Machakos", "016", "Machakos", "Eastern"},
	{17, "Makueni", "017", "Wote", "Eastern"},
	{18, "Nyandarua", "018", "Ol Kalou", "Central"},
	{19, "Nyeri", "019", "Nyeri", "Central"},
	{20, "Kirinyaga", "020", "Kerugoya", "Central"},
	{21, "Murang'a", "021", "Murang'a", "Central"},
	{22, "Kiambu", "022", "Kiambu", "Central"},
	{23, "Turkana", "023", "Lodwar", "Rift Valley"},
	{24, "West Pokot", "024", "Kapenguria", "Rift Valley"},
	{25, "Samburu", "025", "Maralal", "Rift Valley"},
	{26, "Trans Nzoia", "026", "Kitale", "Rift Valley"},
	{27, "Uasin Gishu", "027", "Eldoret", "Rift Valley"},
	{28, "Elgeyo Marakwet", "028", "Iten", "Rift Valley"},
	{29, "Nandi", "029", "Kapsabet", "Rift Valley"},
	{30, "Baringo", "030", "Kabarnet", "Rift Valley"},
	{31, "Laikipia", "031", "Rumuruti", "Rift Valley"},
	{32, "Nakuru", "032", "Nakuru", "Rift Valley"},
	{33, "Narok", "033", "Narok", "Rift Valley"},
	{34, "Kajiado", "034", "Kajiado", "Rift Valley"},
	{35, "Kericho", "035", "Kericho", "Rift Valley"},
	{36, "Bomet", "036", "Bomet", "Rift Valley"},
	{37, "Kakamega", "037", "Kakamega", "Western"},
	{38, "Vihiga", "038", "Vihiga", "Western"},
	{39, "Bungoma", "039", "Bungoma", "Western"},
	{40, "Busia", "040", "Busia", "Western"},
	{41, "Siaya", "041", "Siaya", "Nyanza"},
	{42, "Kisumu", "042", "Kisumu", "Nyanza"},
	{43, "Homa Bay", "043", "Homa Bay", "Nyanza"},
	{44, "Migori", "044", "Migori", "Nyanza"},
	{45, "Kisii", "045", "Kisii", "Nyanza"},
	{46, "Nyamira", "046", "Nyamira", "Nyanza"},
	{47, "Nairobi", "047", "Nairobi", "Central"},
}

// DeliveryZone represents a delivery zone within a county
type DeliveryZone struct {
	ID              int     `json:"id"`
	CountyCode      string  `json:"county_code"`
	Name            string  `json:"name"`
	Description     string  `json:"description"`
	DeliveryFee     float64 `json:"delivery_fee"`
	MinOrderAmount  float64 `json:"min_order_amount"`
	MaxDeliveryTime int     `json:"max_delivery_time"` // in minutes
	IsActive        bool    `json:"is_active"`
}

// NairobiDeliveryZones contains delivery zones for Nairobi
var NairobiDeliveryZones = []DeliveryZone{
	{1, "047", "CBD", "Central Business District", 100, 500, 30, true},
	{2, "047", "Westlands", "Westlands area", 150, 600, 45, true},
	{3, "047", "Karen", "Karen and surrounding areas", 200, 800, 60, true},
	{4, "047", "Eastlands", "Eastlands areas", 120, 500, 45, true},
	{5, "047", "Kileleshwa", "Kileleshwa and nearby areas", 150, 600, 40, true},
	{6, "047", "Kilimani", "Kilimani area", 150, 600, 35, true},
	{7, "047", "Lavington", "Lavington area", 180, 700, 50, true},
	{8, "047", "Parklands", "Parklands area", 140, 550, 40, true},
	{9, "047", "South B", "South B area", 130, 550, 35, true},
	{10, "047", "South C", "South C area", 140, 600, 40, true},
	{11, "047", "Langata", "Langata area", 170, 650, 50, true},
	{12, "047", "Kasarani", "Kasarani area", 160, 600, 55, true},
	{13, "047", "Embakasi", "Embakasi area", 140, 550, 50, true},
	{14, "047", "Dagoretti", "Dagoretti area", 150, 600, 45, true},
	{15, "047", "Kibera", "Kibera area", 120, 500, 40, true},
}

// MombasaDeliveryZones contains delivery zones for Mombasa
var MombasaDeliveryZones = []DeliveryZone{
	{16, "001", "Mombasa Island", "Mombasa Island", 120, 500, 35, true},
	{17, "001", "Nyali", "Nyali area", 150, 600, 45, true},
	{18, "001", "Bamburi", "Bamburi area", 180, 700, 50, true},
	{19, "001", "Likoni", "Likoni area", 140, 550, 40, true},
	{20, "001", "Changamwe", "Changamwe area", 160, 600, 45, true},
	{21, "001", "Jomba", "Jomba area", 170, 650, 50, true},
}

// KisumuDeliveryZones contains delivery zones for Kisumu
var KisumuDeliveryZones = []DeliveryZone{
	{22, "042", "Kisumu Central", "Kisumu city center", 100, 400, 30, true},
	{23, "042", "Milimani", "Milimani area", 120, 500, 40, true},
	{24, "042", "Kondele", "Kondele area", 110, 450, 35, true},
	{25, "042", "Mamboleo", "Mamboleo area", 130, 550, 45, true},
}

// GetCountyByCode returns county information by code
func GetCountyByCode(code string) *County {
	for _, county := range KenyanCounties {
		if county.Code == code {
			return &county
		}
	}
	return nil
}

// GetCountyByName returns county information by name
func GetCountyByName(name string) *County {
	for _, county := range KenyanCounties {
		if county.Name == name {
			return &county
		}
	}
	return nil
}

// GetCountiesByRegion returns counties in a specific region
func GetCountiesByRegion(region string) []County {
	var counties []County
	for _, county := range KenyanCounties {
		if county.Region == region {
			counties = append(counties, county)
		}
	}
	return counties
}

// GetDeliveryZonesByCounty returns delivery zones for a county
func GetDeliveryZonesByCounty(countyCode string) []DeliveryZone {
	var zones []DeliveryZone
	
	switch countyCode {
	case "047": // Nairobi
		zones = append(zones, NairobiDeliveryZones...)
	case "001": // Mombasa
		zones = append(zones, MombasaDeliveryZones...)
	case "042": // Kisumu
		zones = append(zones, KisumuDeliveryZones...)
	}
	
	return zones
}

// CalculateDistance calculates distance between two coordinates using Haversine formula
func CalculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const R = 6371 // Earth's radius in kilometers

	dLat := (lat2 - lat1) * math.Pi / 180
	dLon := (lon2 - lon1) * math.Pi / 180

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1*math.Pi/180)*math.Cos(lat2*math.Pi/180)*
			math.Sin(dLon/2)*math.Sin(dLon/2)

	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	distance := R * c

	return distance
}

// CalculateDeliveryFee calculates delivery fee based on distance and zone
func CalculateDeliveryFee(distance float64, baseZone *DeliveryZone) float64 {
	if baseZone == nil {
		return 200.0 // Default fee
	}

	baseFee := baseZone.DeliveryFee
	
	// Add extra fee for distances over 5km
	if distance > 5.0 {
		extraDistance := distance - 5.0
		extraFee := extraDistance * 20.0 // KES 20 per extra km
		return baseFee + extraFee
	}
	
	return baseFee
}

// IsWithinDeliveryRadius checks if location is within delivery radius
func IsWithinDeliveryRadius(restaurantLat, restaurantLon, customerLat, customerLon float64, maxRadius float64) bool {
	distance := CalculateDistance(restaurantLat, restaurantLon, customerLat, customerLon)
	return distance <= maxRadius
}

// PopularKenyanCuisines contains popular Kenyan cuisine types
var PopularKenyanCuisines = []string{
	"Kenyan Traditional",
	"Swahili",
	"Indian",
	"Chinese",
	"Italian",
	"American",
	"Ethiopian",
	"Lebanese",
	"Continental",
	"Vegetarian",
	"Seafood",
	"BBQ & Grills",
}

// PopularKenyanDishes contains popular Kenyan dishes
var PopularKenyanDishes = map[string][]string{
	"Kenyan Traditional": {
		"Ugali", "Nyama Choma", "Sukuma Wiki", "Githeri", "Mukimo",
		"Irio", "Chapati", "Mandazi", "Samosa", "Pilau",
	},
	"Swahili": {
		"Biryani", "Coconut Rice", "Fish Curry", "Samaki wa Nazi",
		"Kachumbari", "Mahamri", "Urojo", "Mishkaki",
	},
	"Indian": {
		"Chicken Tikka", "Butter Chicken", "Naan", "Biryani",
		"Dosa", "Idli", "Sambar", "Rasam",
	},
}

