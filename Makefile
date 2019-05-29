help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

run:  ## Run docker compose
	docker-compose up

build:  ## Build docker
	docker build -t liveui/api-core:local-dev .

build-debug:  ## Build docker image in debug mode
	docker build --build-arg CONFIGURATION="debug" -t liveui/api-core:local-dev-debug .

clean:  ## Clean docker compose and .build folder
	docker-compose stop -t 2
	docker-compose down --volumes
	docker-compose --project-name apicore-test stop -t 2
	docker-compose --project-name apicore-test down --volumes
	rm -rf .build

test:  ## Run tests in docker
	docker-compose --project-name apicore-test down
	docker-compose --project-name apicore-test run --rm api swift test
	docker-compose --project-name apicore-test down

xcode:  ## Generate Xcode project
	cp ./ApiCore.xcodeproj/xcshareddata/xcschemes/ApiCoreRun.xcscheme ./ApiCoreRun.xcscheme
	vapor xcode -n --verbose
	mv ./ApiCoreRun.xcscheme ./ApiCore.xcodeproj/xcshareddata/xcschemes/ApiCoreRun.xcscheme
	
update:  ## Update all dependencies but keep same versions
	cp ./ApiCore.xcodeproj/xcshareddata/xcschemes/ApiCoreRun.xcscheme ./ApiCoreRun.xcscheme
	rm -rf .build
	vapor clean -y --verbose
	vapor xcode -n --verbose
	mv ./ApiCoreRun.xcscheme ./ApiCore.xcodeproj/xcshareddata/xcschemes/ApiCoreRun.xcscheme
	
upgrade:  ## Upgrade all dependencies to the latest versions
	cp ./ApiCore.xcodeproj/xcshareddata/xcschemes/ApiCoreRun.xcscheme ./ApiCoreRun.xcscheme
	rm -rf .build
	vapor clean -y --verbose
	rm -f Package.resolved
	vapor xcode -n --verbose
	mv ./ApiCoreRun.xcscheme ./ApiCore.xcodeproj/xcshareddata/xcschemes/ApiCoreRun.xcscheme

linuxmain:  ## Generate linuxmain file
	swift test --generate-linuxmain