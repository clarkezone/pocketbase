lint:
	golangci-lint run -c ./golangci.yml ./...

test:
	go test ./... -v --cover

test-report:
	go test ./... -v --cover -coverprofile=coverage.out
	go tool cover -html=coverage.out

.PHONY: buildimage
buildimage:
	$(eval IMG := "pocketbase")
	$(eval VERSION := "latest")
	
	@echo ${IMG}
	@echo ${VERSION}

	-podman manifest exists localhost/${IMG}:latest && podman manifest rm localhost/${IMG}:latest

	podman build --arch=amd64 -t ${IMG}:${VERSION}.amd64 -f Dockerfile
	podman build --arch=arm64 -t ${IMG}:${VERSION}.arm64 -f Dockerfile
	
	podman manifest create ${IMG}:${VERSION}
	podman manifest add ${IMG}:${VERSION} containers-storage:localhost/${IMG}:${VERSION}.amd64
	podman manifest add ${IMG}:${VERSION} containers-storage:localhost/${IMG}:${VERSION}.arm64

.PHONY: pushimage
pushimage:
	$(eval IMG := "pocketbase")
	$(eval VERSION := "latest")
	
	@echo ${IMG}
	@echo ${VERSION}

	podman manifest push ${IMG}:${VERSION} docker://registry.dev.clarkezone.dev/${IMG}:${VERSION}