
WP_CONTAINER := wp-web
DB_CONTAINER := wp-database

TEST_IMAGE := jubicoy/wordpress:testing

build-testing:
	docker build -t $(TEST_IMAGE) .
.PHONY: build-testing

bootstrap-local:
	docker run -d --name $(DB_CONTAINER) \
		-P \
		-e "MYSQL_USER=test" \
		-e "MYSQL_PASSWORD=test" \
		-e "MYSQL_DATABASE=wordpress" \
		-e "MYSQL_ROOT_PASSWORD=test" \
		-p 3306:3306 \
		mariadb:10.3 mysqld --skip-name-resolve
	sleep 10
	docker run -d --name $(WP_CONTAINER) \
		-P \
		-e "MYSQL_USER=test" \
		-e "MYSQL_PASSWORD=test" \
		-e "MYSQL_DATABASE=wordpress" \
		-e "DB_HOST=127.0.0.1" \
		-e "DAV_USER=test" \
		-e "DAV_PASS=test" \
		--net=host \
		$(TEST_IMAGE)
.PHONY: bootstrap-local

clean-local:
	-@docker rm -f $(WP_CONTAINER)
	-@docker rm -f $(DB_CONTAINER)
.PHONY: clean-local
