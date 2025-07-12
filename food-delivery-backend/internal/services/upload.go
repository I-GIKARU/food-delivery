package services

import (
	"context"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"kenyan-food-delivery/internal/config"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

// UploadService handles file uploads
type UploadService struct {
	cloudinary *cloudinary.Cloudinary
	config     *config.Config
}

// UploadResponse represents the response after uploading a file
type UploadResponse struct {
	URL      string `json:"url"`
	PublicID string `json:"public_id"`
	Width    int    `json:"width"`
	Height   int    `json:"height"`
	Size     int    `json:"size"`
	Format   string `json:"format"`
}

// NewUploadService creates a new upload service
func NewUploadService(cfg *config.Config) (*UploadService, error) {
	cld, err := cloudinary.NewFromParams(cfg.CloudinaryCloudName, cfg.CloudinaryAPIKey, cfg.CloudinaryAPISecret)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize Cloudinary: %v", err)
	}

	return &UploadService{
		cloudinary: cld,
		config:     cfg,
	}, nil
}

// UploadImage uploads an image file to Cloudinary
func (s *UploadService) UploadImage(file multipart.File, header *multipart.FileHeader, folder string) (*UploadResponse, error) {
	// Validate file size
	if header.Size > s.config.MaxFileSize {
		return nil, fmt.Errorf("file size %d bytes exceeds maximum allowed size %d bytes", header.Size, s.config.MaxFileSize)
	}

	// Validate file type
	if !s.isAllowedImageType(header) {
		return nil, fmt.Errorf("file type not allowed. Allowed types: %v", s.config.AllowedFileTypes)
	}

	// Create a unique filename
	filename := s.generateUniqueFilename(header.Filename)
	
	// Set folder path
	folderPath := fmt.Sprintf("%s/%s", s.config.CloudinaryFolder, folder)

	// Upload to Cloudinary
	ctx := context.Background()
	resp, err := s.cloudinary.Upload.Upload(ctx, file, uploader.UploadParams{
		PublicID:         filename,
		Folder:          folderPath,
		ResourceType:    "image",
		Transformation:  "q_auto,f_auto", // Auto quality and format
		AllowedFormats:  []string{"jpg", "png", "gif", "webp"},
	})
	if err != nil {
		return nil, fmt.Errorf("failed to upload to Cloudinary: %v", err)
	}

	return &UploadResponse{
		URL:      resp.SecureURL,
		PublicID: resp.PublicID,
		Width:    resp.Width,
		Height:   resp.Height,
		Size:     resp.Bytes,
		Format:   resp.Format,
	}, nil
}

// UploadProfilePicture uploads a user profile picture
func (s *UploadService) UploadProfilePicture(file multipart.File, header *multipart.FileHeader, userID uint) (*UploadResponse, error) {
	folder := fmt.Sprintf("users/%d/profile", userID)
	return s.UploadImage(file, header, folder)
}

// UploadRestaurantImage uploads a restaurant image (logo or cover)
func (s *UploadService) UploadRestaurantImage(file multipart.File, header *multipart.FileHeader, restaurantID uint, imageType string) (*UploadResponse, error) {
	folder := fmt.Sprintf("restaurants/%d/%s", restaurantID, imageType)
	return s.UploadImage(file, header, folder)
}

// UploadMenuItemImage uploads a menu item image
func (s *UploadService) UploadMenuItemImage(file multipart.File, header *multipart.FileHeader, restaurantID uint, menuItemID uint) (*UploadResponse, error) {
	folder := fmt.Sprintf("restaurants/%d/menu/%d", restaurantID, menuItemID)
	return s.UploadImage(file, header, folder)
}

// DeleteImage deletes an image from Cloudinary
func (s *UploadService) DeleteImage(publicID string) error {
	ctx := context.Background()
	_, err := s.cloudinary.Upload.Destroy(ctx, uploader.DestroyParams{
		PublicID: publicID,
	})
	if err != nil {
		return fmt.Errorf("failed to delete image from Cloudinary: %v", err)
	}
	return nil
}

// isAllowedImageType checks if the uploaded file is an allowed image type
func (s *UploadService) isAllowedImageType(header *multipart.FileHeader) bool {
	// Check by MIME type from header
	contentType := header.Header.Get("Content-Type")
	for _, allowedType := range s.config.AllowedFileTypes {
		if contentType == allowedType {
			return true
		}
	}

	// Also check by file extension as fallback
	ext := strings.ToLower(filepath.Ext(header.Filename))
	allowedExtensions := []string{".jpg", ".jpeg", ".png", ".gif", ".webp"}
	for _, allowedExt := range allowedExtensions {
		if ext == allowedExt {
			return true
		}
	}

	return false
}

// generateUniqueFilename generates a unique filename for uploads
func (s *UploadService) generateUniqueFilename(originalFilename string) string {
	ext := filepath.Ext(originalFilename)
	name := strings.TrimSuffix(originalFilename, ext)
	
	// Clean the filename
	name = strings.ReplaceAll(name, " ", "_")
	name = strings.ToLower(name)
	
	// Add timestamp for uniqueness
	timestamp := time.Now().Unix()
	
	return fmt.Sprintf("%s_%d%s", name, timestamp, ext)
}

// ValidateImageFile validates an uploaded image file
func (s *UploadService) ValidateImageFile(file multipart.File, header *multipart.FileHeader) error {
	// Check file size
	if header.Size > s.config.MaxFileSize {
		return fmt.Errorf("file too large: %d bytes (max: %d bytes)", header.Size, s.config.MaxFileSize)
	}

	// Check file type
	if !s.isAllowedImageType(header) {
		return fmt.Errorf("unsupported file type: %s", header.Header.Get("Content-Type"))
	}

	// Read first 512 bytes to detect actual file type
	buffer := make([]byte, 512)
	_, err := file.Read(buffer)
	if err != nil && err != io.EOF {
		return fmt.Errorf("failed to read file: %v", err)
	}

	// Reset file pointer
	if seeker, ok := file.(io.Seeker); ok {
		seeker.Seek(0, io.SeekStart)
	}

	// Detect content type from file content
	contentType := http.DetectContentType(buffer)
	if !strings.HasPrefix(contentType, "image/") {
		return fmt.Errorf("file is not a valid image: detected type %s", contentType)
	}

	return nil
}
