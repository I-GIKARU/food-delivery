package services

import (
	"context"
	"kenyan-food-delivery/internal/config"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

// CloudinaryService handles interactions with Cloudinary
type CloudinaryService struct {
	cloudinary *cloudinary.Cloudinary
	folder     string
}

// NewCloudinaryService creates a new Cloudinary service
func NewCloudinaryService(cfg *config.Config) (*CloudinaryService, error) {
	cld, err := cloudinary.NewFromParams(cfg.CloudinaryCloudName, cfg.CloudinaryAPIKey, cfg.CloudinaryAPISecret)
	if err != nil {
		return nil, err
	}

	return &CloudinaryService{
		cloudinary: cld,
		folder:     cfg.CloudinaryFolder,
	}, nil
}

// UploadImage uploads an image to Cloudinary
func (s *CloudinaryService) UploadImage(file string) (string, error) {
	ctx := context.Background()
	resp, err := s.cloudinary.Upload.Upload(ctx, file, uploader.UploadParams{
		Folder: s.folder,
	})
	if err != nil {
		return "", err
	}

	return resp.SecureURL, nil
}

// DeleteImage deletes an image from Cloudinary
func (s *CloudinaryService) DeleteImage(publicID string) error {
	ctx := context.Background()
	_, err := s.cloudinary.Upload.Destroy(ctx, uploader.DestroyParams{PublicID: publicID})
	return err
}

