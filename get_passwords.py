#!/usr/bin/env python3
import sys
import requests
import json
import time

container_id = sys.argv[1] if len(sys.argv) > 1 else None
passwords = []

try:
	response = requests.post('http://localhost:5069/generate-password')
	if response.status_code == 200:
		data = response.json()
		# MULTI_GEN is enabled, so response contains "passwords" array
		if 'passwords' in data:
			passwords = data.get('passwords', [])
		else:
			passwords = [data.get('password', 'Error generating password')]
	else:
		passwords = [f'Error: {response.status_code}' for _ in range(5)]
except Exception as e:
	passwords = [f'Error: {str(e)}' for _ in range(5)]

for idx, pwd in enumerate(passwords, 1):
	print(f'{idx}. {pwd}')
