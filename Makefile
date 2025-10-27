.PHONY: up up-offline down

up:
	docker run -d -p 5069:5069 \
		-e NO_API_CHECK=false \
		-e PW_LENGTH=12 \
		-e PW_INCLUDE_UPPERCASE=false \
		-e PW_INCLUDE_DIGITS=false \
		-e PW_INCLUDE_SPECIAL=false \
		-e PW_EXCLUDE_HOMOGLYPHS=true \
		-e PP_WORD_COUNT=4 \
		-e PP_CAPITALIZE=false \
		-e PP_SEPARATOR_TYPE=dash \
		-e PP_USER_DEFINED_SEPARATOR='' \
		-e PP_MAX_WORD_LENGTH=12 \
		-e PP_INCLUDE_NUMBERS=false \
		-e PP_INCLUDE_SPECIAL_CHARS=false \
		-e PP_LANGUAGE=en \
		-e PP_HIDE_LANG=false \
		-e PP_LANGUAGE_CUSTOM='' \
		-e MULTI_GEN=true \
		-e GENERATE_PP=true \
		-e SHOW_SAVE_SETTINGS=true \
		-e ROBOTS_ALLOW=false \
		-e GOOGLE_SITE_VERIFICATION='' \
		-e DISABLE_URL_CHECK=false \
		-e BASE_PATH='' \
		-e PP_LOCAL_WORDLIST=/app/wordlist.txt \
		-v $(PWD)/wordlist.txt:/app/wordlist.txt \
		jocxfin/pwgen:latest

up-offline:
	docker run -d -p 5069:5069 -e NO_API_CHECK=true jocxfin/pwgen:latest

down:
	docker stop $$(docker ps -q --filter "ancestor=jocxfin/pwgen:latest")

password:
	@caps=$$(echo "$(ARGS)" | grep -q "\-\-no-caps" && echo "false" || echo "true"); \
		numbers=$$(echo "$(ARGS)" | grep -q "\-\-no-numbers" && echo "false" || echo "true"); \
		special=$$(echo "$(ARGS)" | grep -q "\-\-no-special" && echo "false" || echo "true"); \
		length=$$(echo "$(ARGS)" | grep -oP "\-\-chars\s+\K\d+" || echo "12"); \
		existing_container=$$(docker ps -q --filter "ancestor=jocxfin/pwgen:latest" | head -1); \
		docker stop $$existing_container 2>/dev/null || true; \
		container_id=$$(docker run -d -p 5069:5069 \
			-e NO_API_CHECK=false \
			-e PW_LENGTH=$$length \
			-e PW_INCLUDE_UPPERCASE=$$caps \
			-e PW_INCLUDE_DIGITS=$$numbers \
			-e PW_INCLUDE_SPECIAL=$$special \
			-e PW_EXCLUDE_HOMOGLYPHS=true \
			-e PP_WORD_COUNT=4 \
			-e PP_CAPITALIZE=false \
			-e PP_SEPARATOR_TYPE=dash \
			-e PP_USER_DEFINED_SEPARATOR='' \
			-e PP_MAX_WORD_LENGTH=12 \
			-e PP_INCLUDE_NUMBERS=false \
			-e PP_INCLUDE_SPECIAL_CHARS=false \
			-e PP_LANGUAGE=en \
			-e PP_HIDE_LANG=false \
			-e PP_LANGUAGE_CUSTOM='' \
			-e MULTI_GEN=true \
			-e GENERATE_PP=true \
			-e SHOW_SAVE_SETTINGS=true \
			-e ROBOTS_ALLOW=false \
			-e GOOGLE_SITE_VERIFICATION='' \
			-e DISABLE_URL_CHECK=false \
			-e BASE_PATH='' \
			-e PP_LOCAL_WORDLIST=/app/wordlist.txt \
			-v $(PWD)/wordlist.txt:/app/wordlist.txt \
			jocxfin/pwgen:latest); \
		sleep 3; \
		echo "Generated Passwords (length=$$length, caps=$$caps, numbers=$$numbers, special=$$special):"; \
		python3 $(PWD)/get_passwords.py; \
		docker stop $$container_id || true
