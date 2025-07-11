package services

import (
	"fmt"
	"net/smtp"

	"kenyan-food-delivery/internal/config"
)

// EmailService handles email operations
type EmailService struct {
	config *config.Config
}

// NewEmailService creates a new email service
func NewEmailService(cfg *config.Config) *EmailService {
	return &EmailService{
		config: cfg,
	}
}

// SendEmail sends an email
func (s *EmailService) SendEmail(to, subject, body string) error {
	if s.config.SMTPUsername == "" || s.config.SMTPPassword == "" {
		return fmt.Errorf("email configuration is missing")
	}

	from := s.config.EmailFrom
	if from == "" {
		from = s.config.SMTPUsername
	}

	auth := smtp.PlainAuth("", s.config.SMTPUsername, s.config.SMTPPassword, s.config.SMTPHost)

	msg := []byte(fmt.Sprintf("To: %s\r\n"+
		"From: %s\r\n"+
		"Subject: %s\r\n"+
		"Content-Type: text/html; charset=\"UTF-8\"\r\n"+
		"\r\n"+
		"%s\r\n", to, from, subject, body))

	addr := fmt.Sprintf("%s:%d", s.config.SMTPHost, s.config.SMTPPort)
	return smtp.SendMail(addr, auth, from, []string{to}, msg)
}

// SendEmailVerification sends email verification email
func (s *EmailService) SendEmailVerification(email, firstName, token string) error {
	subject := "Verify Your Email - Kenyan Food Delivery"
	
	// Create verification URL using backend URL
	verifyURL := fmt.Sprintf("%s/api/v1/auth/verify-email?token=%s", s.config.BackendURL, token)
	
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
			<div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
				<h2 style="color: #333; text-align: center;">Welcome to Kenyan Food Delivery!</h2>
				<p>Hi %s,</p>
				<p>Thank you for creating an account with Kenyan Food Delivery. Please click the button below to verify your email address:</p>
				
				<div style="text-align: center; margin: 30px 0;">
					<a href="%s" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
						Verify Email Address
					</a>
				</div>
				
				<p>If the button doesn't work, you can copy and paste this link into your browser:</p>
				<p style="background-color: #f1f1f1; padding: 10px; border-radius: 4px; word-break: break-all;">%s</p>
				
				<p>This verification link will expire in 24 hours.</p>
				
				<p>If you didn't create this account, please ignore this email.</p>
				
				<hr style="border: 1px solid #eee; margin: 30px 0;">
				<p style="font-size: 12px; color: #666; text-align: center;">
					Kenyan Food Delivery<br>
					Nairobi, Kenya
				</p>
			</div>
		</body>
		</html>
	`, firstName, verifyURL, verifyURL)

	return s.SendEmail(email, subject, body)
}

// SendPasswordReset sends password reset email
func (s *EmailService) SendPasswordReset(email, firstName, token string) error {
	subject := "Reset Your Password - Kenyan Food Delivery"
	
	// Create reset URL using backend URL
	resetURL := fmt.Sprintf("%s/api/v1/auth/reset-password?token=%s", s.config.BackendURL, token)
	
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
			<div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
				<h2 style="color: #333; text-align: center;">Reset Your Password</h2>
				<p>Hi %s,</p>
				<p>We received a request to reset your password for your Kenyan Food Delivery account. Click the button below to reset your password:</p>
				
				<div style="text-align: center; margin: 30px 0;">
					<a href="%s" style="background-color: #dc3545; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
						Reset Password
					</a>
				</div>
				
				<p>If the button doesn't work, you can copy and paste this link into your browser:</p>
				<p style="background-color: #f1f1f1; padding: 10px; border-radius: 4px; word-break: break-all;">%s</p>
				
				<p>This reset link will expire in 1 hour for security reasons.</p>
				
				<p>If you didn't request a password reset, please ignore this email. Your password will remain unchanged.</p>
				
				<hr style="border: 1px solid #eee; margin: 30px 0;">
				<p style="font-size: 12px; color: #666; text-align: center;">
					Kenyan Food Delivery<br>
					Nairobi, Kenya
				</p>
			</div>
		</body>
		</html>
	`, firstName, resetURL, resetURL)

	return s.SendEmail(email, subject, body)
}

// SendWelcomeEmail sends welcome email after email verification
func (s *EmailService) SendWelcomeEmail(email, firstName string) error {
	subject := "Welcome to Kenyan Food Delivery!"
	
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
			<div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
				<h2 style="color: #333; text-align: center;">Welcome to Kenyan Food Delivery! 🍽️</h2>
				<p>Hi %s,</p>
				<p>Your email has been successfully verified! Welcome to Kenya's premier food delivery platform.</p>
				
				<h3 style="color: #333;">What's Next?</h3>
				<ul>
					<li>🔍 <strong>Explore Restaurants:</strong> Browse through hundreds of local restaurants</li>
					<li>🏠 <strong>Add Your Address:</strong> Set up your delivery locations</li>
					<li>🍕 <strong>Order Your Favorites:</strong> Discover amazing Kenyan and international cuisine</li>
					<li>📱 <strong>Track Your Order:</strong> Real-time delivery tracking</li>
				</ul>
				
				<h3 style="color: #333;">Featured Cuisines:</h3>
				<p>🇰🇪 Traditional Kenyan • 🌶️ Swahili • 🇮🇳 Indian • 🇨🇳 Chinese • 🇮🇹 Italian</p>
				
				<div style="text-align: center; margin: 30px 0;">
					<p style="background-color: #28a745; color: white; padding: 12px 24px; border-radius: 5px; display: inline-block;">
						Download our mobile app to start ordering!
					</p>
				</div>
				
				<p>Need help? Our customer support team is available 24/7 to assist you.</p>
				
				<hr style="border: 1px solid #eee; margin: 30px 0;">
				<p style="font-size: 12px; color: #666; text-align: center;">
					Kenyan Food Delivery<br>
					Nairobi, Kenya<br>
					<a href="mailto:support@kenyanfooddelivery.com">support@kenyanfooddelivery.com</a>
				</p>
			</div>
		</body>
		</html>
	`, firstName)

	return s.SendEmail(email, subject, body)
}
