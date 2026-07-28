---
title: "lsof Process Port Viewer"
tags: [tool, lsof, network, port, go]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[03-tools/_index]]"
---

# lsof Process Port Viewer

tool สำหรับดู active ports และ process บน Linux server โดยใช้ Go และ `lsof`

---

## Example Output

```plaintext
Program: Process Summary Report
Generated on: Thursday, November 14, 2024 - 11:38:11 +07
Duration: 135.760208ms
Total Processes Found: 62

sshd found 7 entries
 sshd - IPv4 TCP on *:22
  • PID: 1256 | User: root | Node: 12345 | FD: 3u | Size: 0t0

apache2 found 7 entries
 apache2 - IPv6 TCP on *:80
  • PID: 2246 | User: www-data | Node: 67891 | FD: 4u | Size: 0t0
```

---

## Prerequisites

- Go 1.18 ขึ้นไป ติดตั้งบน server
- `lsof` ติดตั้งบน server
- สิทธิ์รัน `lsof -i` บน server (อาจต้องใช้ sudo)

---

## Steps

### 1. เช็ค dependencies

```bash
go version
lsof -v
```

ถ้าไม่มี `lsof`:

```bash
sudo apt-get install lsof
```

### 2. สร้างไฟล์บน server

```bash
mkdir -p ~/lsof-port-viewer && vi ~/lsof-port-viewer/main.go
```

### 3. วางโค้ด

```go
package main

import (
	"fmt"
	"os/exec"
	"strings"
	"time"
)

// Process represents each row in the table
type Process struct {
	Command string
	PID     string
	User    string
	FD      string
	Type    string
	Device  string
	SizeOff string
	Node    string
	Name    string
}

// ParseData converts a line of process data into a Process struct
func ParseData(line string) Process {
	fields := strings.Fields(line)
	return Process{
		Command: fields[0],
		PID:     fields[1],
		User:    fields[2],
		FD:      fields[3],
		Type:    fields[4],
		Device:  fields[5],
		SizeOff: fields[6],
		Node:    fields[7],
		Name:    fields[8],
	}
}

// DisplayTable groups and formats process information
func DisplayTable(processes []Process) {
	commandGroups := make(map[string][]Process)

	// Group processes by command
	for _, p := range processes {
		commandGroups[p.Command] = append(commandGroups[p.Command], p)
	}

	// Color codes for formatting
	brightWhite := "\033[1;37m"
	regularWhite := "\033[0;37m"
	lightGreen := "\033[1;32m"
	resetColor := "\033[0m"

	// Display grouped command summaries with detailed info
	for command, group := range commandGroups {
		fmt.Printf("%s%s found %d entries%s\n", brightWhite, command, len(group), resetColor)

		for _, p := range group {
			// Determine protocol type from name or type field
			protocol := "Unknown"
			if strings.Contains(p.Name, "TCP") {
				protocol = "TCP"
			} else if strings.Contains(p.Name, "UDP") {
				protocol = "UDP"
			} else if p.Type == "IPv4" || p.Type == "IPv6" {
				protocol = "IP"
			}

			fmt.Printf(" %s%s%s - %s%s %s on %s%s\n",
				regularWhite, p.Command, resetColor, lightGreen, p.Type, protocol, p.Name, resetColor)

			fmt.Printf(" %s • PID: %s | User: %s | Node: %s | FD: %s | Size: %s%s\n",
				regularWhite, p.PID, p.User, p.Node, p.FD, p.SizeOff, resetColor)
		}
		fmt.Println() // Space between groups
	}
}

func main() {
	startTime := time.Now() // Start time for duration calculation

	// Run `lsof` to gather process information
	out, err := exec.Command("lsof", "-i").Output()
	if err != nil {
		fmt.Println("Error executing command:", err)
		return
	}

	// Process output into structured data
	lines := strings.Split(string(out), "\n")
	var processes []Process
	for _, line := range lines[1:] {
		if line != "" {
			processes = append(processes, ParseData(line))
		}
	}

	// Display header with report details
	totalProcesses := len(processes)
	duration := time.Since(startTime)
	fmt.Println()
	fmt.Printf("Program: Process Summary Report\n")
	fmt.Printf("Generated on: %s\n", startTime.Format("Monday, January 2, 2006 - 15:04:05 MST"))
	fmt.Printf("Duration: %v\n", duration)
	fmt.Printf("Total Processes Found: %d\n\n", totalProcesses)

	// Output process table
	DisplayTable(processes)
}
```

### 4. รัน

```bash
cd ~/lsof-port-viewer
go run main.go
```

---

## Troubleshooting

**`lsof: command not found`**
```bash
sudo apt-get install lsof
```

**`go: command not found`**
```bash
sudo apt install golang-go
```

**output ว่างเปล่า หรือ permission denied**
```bash
sudo go run main.go
```

---

## References

- [lsof man page](https://man7.org/linux/man-pages/man8/lsof.8.html)
- [Go installation guide](https://go.dev/doc/install)