.PHONY: up up-offline down password

up:
	docker-compose up -d

up-offline:
	docker-compose up -d -e NO_API_CHECK=true

down:
	docker-compose down

password:
	@if [ ! -f .env.password ]; then \
		cp .env.password.sample .env.password; \
		echo "Created .env.password from .env.password.sample"; \
	fi; \
	caps=$$(echo "$(ARGS)" | grep -q "\-\-no-caps" && echo "false" || echo "true"); \
	numbers=$$(echo "$(ARGS)" | grep -q "\-\-no-numbers" && echo "false" || echo "true"); \
	special=$$(echo "$(ARGS)" | grep -q "\-\-no-special" && echo "false" || echo "true"); \
	length=$$(echo "$(ARGS)" | grep -oP "\-\-chars\s+\K\d+" || echo "12"); \
	docker-compose down 2>/dev/null || true; \
	sed -i.bak "s/PW_LENGTH=.*/PW_LENGTH=$$length/; s/PW_INCLUDE_UPPERCASE=.*/PW_INCLUDE_UPPERCASE=$$caps/; s/PW_INCLUDE_DIGITS=.*/PW_INCLUDE_DIGITS=$$numbers/; s/PW_INCLUDE_SPECIAL=.*/PW_INCLUDE_SPECIAL=$$special/" .env.password; \
	docker-compose --env-file .env.password up -d 2>&1 | grep -v "Creating\|Starting\|created\|started" || true; \
	echo "Generated Passwords (length=$$length, caps=$$caps, numbers=$$numbers, special=$$special):"; \
	python3 $(PWD)/get_passwords.py 2>/dev/null; \
	docker-compose down 2>&1 > /dev/null || true; \
	rm -f .env.password.bak
