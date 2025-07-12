package mpesa

import (
	"bytes"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Client represents M-Pesa API client
type Client struct {
	ConsumerKey    string
	ConsumerSecret string
	Environment    string // sandbox or production
	Passkey        string
	Shortcode      string
	BaseURL        string
}

// NewClient creates a new M-Pesa client
func NewClient(consumerKey, consumerSecret, environment, passkey, shortcode string) *Client {
	baseURL := "https://sandbox.safaricom.co.ke"
	if environment == "production" {
		baseURL = "https://api.safaricom.co.ke"
	}

	return &Client{
		ConsumerKey:    consumerKey,
		ConsumerSecret: consumerSecret,
		Environment:    environment,
		Passkey:        passkey,
		Shortcode:      shortcode,
		BaseURL:        baseURL,
	}
}

// AuthResponse represents OAuth response
type AuthResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   string `json:"expires_in"`
}

// GetAccessToken gets OAuth access token
func (c *Client) GetAccessToken() (string, error) {
	url := c.BaseURL + "/oauth/v1/generate?grant_type=client_credentials"
	
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}

	// Set basic auth
	auth := base64.StdEncoding.EncodeToString([]byte(c.ConsumerKey + ":" + c.ConsumerSecret))
	req.Header.Set("Authorization", "Basic "+auth)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("failed to get access token: %s", string(body))
	}

	var authResp AuthResponse
	if err := json.Unmarshal(body, &authResp); err != nil {
		return "", err
	}

	return authResp.AccessToken, nil
}

// STKPushRequest represents STK Push request
type STKPushRequest struct {
	BusinessShortCode string `json:"BusinessShortCode"`
	Password          string `json:"Password"`
	Timestamp         string `json:"Timestamp"`
	TransactionType   string `json:"TransactionType"`
	Amount            string `json:"Amount"`
	PartyA            string `json:"PartyA"`
	PartyB            string `json:"PartyB"`
	PhoneNumber       string `json:"PhoneNumber"`
	CallBackURL       string `json:"CallBackURL"`
	AccountReference  string `json:"AccountReference"`
	TransactionDesc   string `json:"TransactionDesc"`
}

// STKPushResponse represents STK Push response
type STKPushResponse struct {
	MerchantRequestID   string `json:"MerchantRequestID"`
	CheckoutRequestID   string `json:"CheckoutRequestID"`
	ResponseCode        string `json:"ResponseCode"`
	ResponseDescription string `json:"ResponseDescription"`
	CustomerMessage     string `json:"CustomerMessage"`
}

// generatePassword generates M-Pesa password
func (c *Client) generatePassword(timestamp string) string {
	password := c.Shortcode + c.Passkey + timestamp
	return base64.StdEncoding.EncodeToString([]byte(password))
}

// generateTimestamp generates timestamp in required format
func (c *Client) generateTimestamp() string {
	return time.Now().Format("20060102150405")
}

// STKPush initiates STK Push payment
func (c *Client) STKPush(phoneNumber, amount, accountReference, description, callbackURL string) (*STKPushResponse, error) {
	accessToken, err := c.GetAccessToken()
	if err != nil {
		return nil, err
	}

	timestamp := c.generateTimestamp()
	password := c.generatePassword(timestamp)

	// Clean phone number (remove + and ensure it starts with 254)
	if phoneNumber[0] == '+' {
		phoneNumber = phoneNumber[1:]
	}
	if phoneNumber[:3] != "254" {
		if phoneNumber[0] == '0' {
			phoneNumber = "254" + phoneNumber[1:]
		} else {
			phoneNumber = "254" + phoneNumber
		}
	}

	request := STKPushRequest{
		BusinessShortCode: c.Shortcode,
		Password:          password,
		Timestamp:         timestamp,
		TransactionType:   "CustomerPayBillOnline",
		Amount:            amount,
		PartyA:            phoneNumber,
		PartyB:            c.Shortcode,
		PhoneNumber:       phoneNumber,
		CallBackURL:       callbackURL,
		AccountReference:  accountReference,
		TransactionDesc:   description,
	}

	jsonData, err := json.Marshal(request)
	if err != nil {
		return nil, err
	}

	url := c.BaseURL + "/mpesa/stkpush/v1/processrequest"
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var stkResp STKPushResponse
	if err := json.Unmarshal(body, &stkResp); err != nil {
		return nil, err
	}

	return &stkResp, nil
}

// STKQueryRequest represents STK query request
type STKQueryRequest struct {
	BusinessShortCode string `json:"BusinessShortCode"`
	Password          string `json:"Password"`
	Timestamp         string `json:"Timestamp"`
	CheckoutRequestID string `json:"CheckoutRequestID"`
}

// STKQueryResponse represents STK query response
type STKQueryResponse struct {
	ResponseCode         string `json:"ResponseCode"`
	ResponseDescription  string `json:"ResponseDescription"`
	MerchantRequestID    string `json:"MerchantRequestID"`
	CheckoutRequestID    string `json:"CheckoutRequestID"`
	ResultCode           string `json:"ResultCode"`
	ResultDesc           string `json:"ResultDesc"`
	Amount               string `json:"Amount"`
	MpesaReceiptNumber   string `json:"MpesaReceiptNumber"`
	TransactionDate      string `json:"TransactionDate"`
	PhoneNumber          string `json:"PhoneNumber"`
}

// QuerySTKStatus queries STK Push transaction status
func (c *Client) QuerySTKStatus(checkoutRequestID string) (*STKQueryResponse, error) {
	accessToken, err := c.GetAccessToken()
	if err != nil {
		return nil, err
	}

	timestamp := c.generateTimestamp()
	password := c.generatePassword(timestamp)

	request := STKQueryRequest{
		BusinessShortCode: c.Shortcode,
		Password:          password,
		Timestamp:         timestamp,
		CheckoutRequestID: checkoutRequestID,
	}

	jsonData, err := json.Marshal(request)
	if err != nil {
		return nil, err
	}

	url := c.BaseURL + "/mpesa/stkpushquery/v1/query"
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var queryResp STKQueryResponse
	if err := json.Unmarshal(body, &queryResp); err != nil {
		return nil, err
	}

	return &queryResp, nil
}

// CallbackResponse represents M-Pesa callback response
type CallbackResponse struct {
	Body struct {
		StkCallback struct {
			MerchantRequestID string `json:"MerchantRequestID"`
			CheckoutRequestID string `json:"CheckoutRequestID"`
			ResultCode        int    `json:"ResultCode"`
			ResultDesc        string `json:"ResultDesc"`
			CallbackMetadata  struct {
				Item []struct {
					Name  string      `json:"Name"`
					Value interface{} `json:"Value"`
				} `json:"Item"`
			} `json:"CallbackMetadata"`
		} `json:"stkCallback"`
	} `json:"Body"`
}

// ParseCallback parses M-Pesa callback response
func (c *Client) ParseCallback(callbackData []byte) (*CallbackResponse, error) {
	var callback CallbackResponse
	if err := json.Unmarshal(callbackData, &callback); err != nil {
		return nil, err
	}
	return &callback, nil
}

// GetCallbackValue extracts value from callback metadata
func (c *Client) GetCallbackValue(callback *CallbackResponse, name string) interface{} {
	for _, item := range callback.Body.StkCallback.CallbackMetadata.Item {
		if item.Name == name {
			return item.Value
		}
	}
	return nil
}

