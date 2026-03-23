// Package infrastructure はロギングなどのインフラストラクチャレベルのユーティリティを提供します。
package infrastructure

import (
	"fmt"
	"os"
	"path/filepath"
	"time"
)

const logDir = "logs/error"

// LogError logs the error to a file named after the current date in YYYY-MM-DD.log format
func LogError(err error) {
	if err == nil {
		return
	}

	// Get current date
	date := time.Now().Format("2006-01-02")
	filename := fmt.Sprintf("%s.log", date)
	filepath := filepath.Join(logDir, filename)

	// Open or create the file
	file, fileErr := os.OpenFile(filepath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if fileErr != nil {
		// If we can't open the log file, print to stderr as fallback
		fmt.Fprintf(os.Stderr, "Failed to open log file %s: %v\n", filepath, fileErr)
		return
	}
	defer file.Close()

	// Write the error with timestamp
	timestamp := time.Now().Format(time.RFC3339)
	fmt.Fprintf(file, "%s: %v\n", timestamp, err)
}
