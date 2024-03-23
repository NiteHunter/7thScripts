#!/usr/bin/swift

// February 06 2024
// Luke Huapaya
// chmod +x CurrentTime.swift
// ./CurrentTime.swift

import Foundation

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"

// CTRL+Z to exit this loop
while true {
	let currentDateTime = Date()
	let formattedDateTime = dateFormatter.string(from: currentDateTime)
	print("Current Date and Time: \(formattedDateTime)")
	sleep(1)
}

