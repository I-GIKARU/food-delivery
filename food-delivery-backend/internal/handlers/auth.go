package handlers

import (
	"net/http"

	"kenyan-food-delivery/internal/services"

	"github.com/gin-gonic/gin"
)

// Register handles user registration
func (h *Handler) Register(c *gin.Context) {
	var req services.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	response, err := h.services.Auth.Register(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Registration failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User registered successfully",
		"data":    response,
	})
}

// Login handles user login
func (h *Handler) Login(c *gin.Context) {
	var req services.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	response, err := h.services.Auth.Login(&req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "Login failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful",
		"data":    response,
	})
}

// RefreshToken handles token refresh
func (h *Handler) RefreshToken(c *gin.Context) {
	var req struct {
		RefreshToken string `json:"refresh_token" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	response, err := h.services.Auth.RefreshToken(req.RefreshToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "Token refresh failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Token refreshed successfully",
		"data":    response,
	})
}

// Logout handles user logout
func (h *Handler) Logout(c *gin.Context) {
	// In a stateless JWT system, logout is typically handled client-side
	// by removing the token. For enhanced security, you could implement
	// a token blacklist here.
	
	c.JSON(http.StatusOK, gin.H{
		"message": "Logged out successfully",
	})
}

// GetProfile gets the current user's profile
func (h *Handler) GetProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "User not authenticated",
		})
		return
	}

	user, err := h.services.Auth.GetUserByID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "User not found",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile retrieved successfully",
		"data":    user,
	})
}

// UpdateProfile updates the current user's profile
func (h *Handler) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "User not authenticated",
		})
		return
	}

	var req struct {
		FirstName         string `json:"first_name"`
		LastName          string `json:"last_name"`
		PhoneNumber       string `json:"phone_number"`
		PreferredLanguage string `json:"preferred_language"`
		ProfilePicture    string `json:"profile_picture"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	// Get current user
	user, err := h.services.Auth.GetUserByID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "User not found",
		})
		return
	}

	// Update fields if provided
	if req.FirstName != "" {
		user.FirstName = req.FirstName
	}
	if req.LastName != "" {
		user.LastName = req.LastName
	}
	if req.PhoneNumber != "" {
		user.PhoneNumber = req.PhoneNumber
	}
	if req.PreferredLanguage != "" {
		user.PreferredLanguage = req.PreferredLanguage
	}
	if req.ProfilePicture != "" {
		user.ProfilePicture = req.ProfilePicture
	}

	// Save updated user
	if err := h.db.Save(user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to update profile",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile updated successfully",
		"data":    user,
	})
}

// VerifyEmail handles email verification via JSON (POST)
func (h *Handler) VerifyEmail(c *gin.Context) {
	var req services.VerifyEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	if err := h.services.Auth.VerifyEmail(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Email verification failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Email verified successfully",
	})
}

// VerifyEmailLink handles email verification via URL link (GET)
func (h *Handler) VerifyEmailLink(c *gin.Context) {
	token := c.Query("token")
	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Token is required",
			"message": "Verification token not provided",
		})
		return
	}

	req := &services.VerifyEmailRequest{
		Token: token,
	}

	if err := h.services.Auth.VerifyEmail(req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Email verification failed",
			"message": err.Error(),
		})
		return
	}

	// Return HTML success page for web browsers
	htmlResponse := `
	<!DOCTYPE html>
	<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Email Verified - Kenyan Food Delivery</title>
		<style>
			body { 
				font-family: Arial, sans-serif; 
				margin: 0; 
				padding: 20px; 
				background-color: #f8f9fa;
				display: flex;
				justify-content: center;
				align-items: center;
				min-height: 100vh;
			}
			.container {
				background: white;
				padding: 40px;
				border-radius: 8px;
				box-shadow: 0 2px 10px rgba(0,0,0,0.1);
				text-align: center;
				max-width: 500px;
			}
			.success-icon {
				font-size: 60px;
				color: #28a745;
				margin-bottom: 20px;
			}
			h1 {
				color: #28a745;
				margin-bottom: 20px;
			}
			p {
				color: #666;
				margin-bottom: 15px;
				line-height: 1.5;
			}
			.app-info {
				background-color: #e3f2fd;
				padding: 20px;
				border-radius: 5px;
				margin-top: 20px;
			}
		</style>
	</head>
	<body>
		<div class="container">
			<div class="success-icon">✅</div>
			<h1>Email Verified Successfully!</h1>
			<p>Thank you for verifying your email address. Your account is now active and ready to use.</p>
			<div class="app-info">
				<h3>📱 Next Steps:</h3>
				<p>Open the Kenyan Food Delivery mobile app on your device and log in with your credentials to start ordering delicious food!</p>
			</div>
			<p style="margin-top: 30px; font-size: 12px; color: #999;">
				Kenyan Food Delivery | Nairobi, Kenya
			</p>
		</div>
	</body>
	</html>
	`
	
	c.Header("Content-Type", "text/html; charset=utf-8")
	c.String(http.StatusOK, htmlResponse)
}

// ForgotPassword handles forgot password request
func (h *Handler) ForgotPassword(c *gin.Context) {
	var req services.ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	if err := h.services.Auth.ForgotPassword(&req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to process forgot password request",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "If an account with that email exists, a password reset link has been sent",
	})
}

// ResetPasswordLink handles password reset via URL link (GET)
func (h *Handler) ResetPasswordLink(c *gin.Context) {
	token := c.Query("token")
	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Token is required",
			"message": "Reset token not provided",
		})
		return
	}

	// Return HTML form for password reset
	htmlResponse := `
	<!DOCTYPE html>
	<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Reset Password - Kenyan Food Delivery</title>
		<style>
			body { 
				font-family: Arial, sans-serif; 
				margin: 0; 
				padding: 20px; 
				background-color: #f8f9fa;
				display: flex;
				justify-content: center;
				align-items: center;
				min-height: 100vh;
			}
			.container {
				background: white;
				padding: 40px;
				border-radius: 8px;
				box-shadow: 0 2px 10px rgba(0,0,0,0.1);
				text-align: center;
				max-width: 500px;
				width: 100%;
			}
			.form-group {
				margin-bottom: 20px;
				text-align: left;
			}
			.form-group label {
				display: block;
				margin-bottom: 5px;
				color: #333;
				font-weight: bold;
			}
			.form-group input {
				width: 100%;
				padding: 12px;
				border: 1px solid #ddd;
				border-radius: 4px;
				font-size: 16px;
				box-sizing: border-box;
			}
			.form-group input:focus {
				outline: none;
				border-color: #007bff;
			}
			.btn {
				background-color: #007bff;
				color: white;
				padding: 12px 30px;
				border: none;
				border-radius: 4px;
				font-size: 16px;
				cursor: pointer;
				width: 100%;
			}
			.btn:hover {
				background-color: #0056b3;
			}
			h1 {
				color: #333;
				margin-bottom: 20px;
			}
			p {
				color: #666;
				margin-bottom: 20px;
				line-height: 1.5;
			}
			.success-message {
				background-color: #d4edda;
				color: #155724;
				padding: 12px;
				border: 1px solid #c3e6cb;
				border-radius: 4px;
				margin-bottom: 20px;
				display: none;
			}
			.error-message {
				background-color: #f8d7da;
				color: #721c24;
				padding: 12px;
				border: 1px solid #f5c6cb;
				border-radius: 4px;
				margin-bottom: 20px;
				display: none;
			}
			.password-requirements {
				background-color: #e3f2fd;
				padding: 15px;
				border-radius: 5px;
				margin-bottom: 20px;
				text-align: left;
				font-size: 14px;
			}
			.password-requirements ul {
				margin: 10px 0;
				padding-left: 20px;
			}
			.password-requirements li {
				margin-bottom: 5px;
			}
		</style>
	</head>
	<body>
		<div class="container">
			<h1>Reset Your Password</h1>
			<p>Enter your new password below to reset your account password.</p>
			
			<div class="success-message" id="successMessage">
				Password reset successfully! You can now log in with your new password.
			</div>
			
			<div class="error-message" id="errorMessage">
				<!-- Error message will be displayed here -->
			</div>
			
			<form id="resetPasswordForm" method="POST" action="/api/v1/auth/reset-password">
				<input type="hidden" name="token" value="` + token + `">
				
				<div class="form-group">
					<label for="password">New Password:</label>
					<input type="password" id="password" name="password" required minlength="8">
				</div>
				
				<div class="form-group">
					<label for="confirmPassword">Confirm New Password:</label>
					<input type="password" id="confirmPassword" name="confirmPassword" required minlength="8">
				</div>
				
				<div class="password-requirements">
					<strong>Password Requirements:</strong>
					<ul>
						<li>At least 8 characters long</li>
						<li>Contains at least one uppercase letter</li>
						<li>Contains at least one lowercase letter</li>
						<li>Contains at least one number</li>
						<li>Contains at least one special character</li>
					</ul>
				</div>
				
				<button type="submit" class="btn">Reset Password</button>
			</form>
			
			<p style="margin-top: 30px; font-size: 12px; color: #999;">
				Kenyan Food Delivery | Nairobi, Kenya
			</p>
		</div>
		
		<script>
			document.getElementById('resetPasswordForm').addEventListener('submit', function(e) {
				e.preventDefault();
				
				const password = document.getElementById('password').value;
				const confirmPassword = document.getElementById('confirmPassword').value;
				const token = document.querySelector('input[name="token"]').value;
				const errorMessage = document.getElementById('errorMessage');
				const successMessage = document.getElementById('successMessage');
				
				// Hide previous messages
				errorMessage.style.display = 'none';
				successMessage.style.display = 'none';
				
				// Validate passwords match
				if (password !== confirmPassword) {
					errorMessage.textContent = 'Passwords do not match';
					errorMessage.style.display = 'block';
					return;
				}
				
				// Validate password requirements
				if (password.length < 8) {
					errorMessage.textContent = 'Password must be at least 8 characters long';
					errorMessage.style.display = 'block';
					return;
				}
				
				// Submit form data as JSON
				fetch('/api/v1/auth/reset-password', {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
					},
					body: JSON.stringify({
						token: token,
						password: password
					})
				})
				.then(response => response.json())
				.then(data => {
					if (data.message && data.message.includes('successfully')) {
						successMessage.style.display = 'block';
						document.getElementById('resetPasswordForm').style.display = 'none';
					} else {
						errorMessage.textContent = data.message || 'An error occurred';
						errorMessage.style.display = 'block';
					}
				})
				.catch(error => {
					errorMessage.textContent = 'Network error. Please try again.';
					errorMessage.style.display = 'block';
				});
			});
		</script>
	</body>
	</html>
	`
	
	c.Header("Content-Type", "text/html; charset=utf-8")
	c.String(http.StatusOK, htmlResponse)
}

// ResetPassword handles password reset
func (h *Handler) ResetPassword(c *gin.Context) {
	var req services.ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	if err := h.services.Auth.ResetPassword(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Password reset failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Password reset successfully",
	})
}

// ResendVerificationEmail handles resending verification email
func (h *Handler) ResendVerificationEmail(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	if err := h.services.Auth.ResendVerificationEmail(req.Email); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Failed to resend verification email",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Verification email sent successfully",
	})
}

