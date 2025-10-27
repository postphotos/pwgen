#!/usr/bin/env python3
import sys
import json
import time
import urllib.request
import urllib.error
import asyncio

async def wait_for_service(max_retries=60, timeout=1):
	"""Wait for service to be ready with exponential backoff"""
	for attempt in range(max_retries):
		try:
			req = urllib.request.Request('http://localhost:5069/generate-password', method='POST')
			response = urllib.request.urlopen(req, timeout=timeout)
			return True
		except urllib.error.URLError:
			if attempt < max_retries - 1:
				await asyncio.sleep(0.5)
			continue
		except Exception:
			if attempt < max_retries - 1:
				await asyncio.sleep(0.5)
			continue
	return False

async def fetch_passwords():
	"""Fetch 5 passwords from the API"""
	passwords = []
	try:
		req = urllib.request.Request('http://localhost:5069/generate-password', method='POST')
		response = urllib.request.urlopen(req)
		if response.status == 200:
			data = json.loads(response.read().decode())
			if 'passwords' in data:
				passwords = data.get('passwords', [])
			else:
				passwords = [data.get('password', 'Error generating password')]
		else:
			passwords = [f'Error: {response.status}' for _ in range(5)]
	except Exception as e:
		passwords = [f'Error: {str(e)}' for _ in range(5)]
	return passwords

async def main():
	container_id = sys.argv[1] if len(sys.argv) > 1 else None
	
	# Wait for service to be ready
	print("Waiting for service to be ready...", file=sys.stderr)
	ready = await wait_for_service()
	
	if not ready:
		print("Error: Service did not become ready in time", file=sys.stderr)
		for i in range(1, 6):
			print(f'{i}. Error: Service timeout')
		return
	
	# Fetch passwords
	passwords = await fetch_passwords()
	
	# Print passwords
	for idx, pwd in enumerate(passwords, 1):
		print(f'{idx}. {pwd}')

if __name__ == '__main__':
	asyncio.run(main())
