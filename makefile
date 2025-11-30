runServer:
	cd backend/bin && dart run server.dart

runFrontEnd:
	cd frontend && flutter run -d chrome

run:
	@bash -c '\
	cleanup() { \
	  echo "Cleaning up server..."; \
	  lsof -ti tcp:8080 | xargs -r kill -9; \
	}; \
	trap cleanup EXIT; \
	cd backend/bin && dart run server.dart & \
	sleep 2; \
	cd frontend && flutter run -d chrome \
	'