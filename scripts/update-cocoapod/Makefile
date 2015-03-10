# Makefile for building and updating a cordova plugin from a cocoapod spec.
#
# You need to first configure your podfile.
# See the docutmention at:
#   http://github.com/mkcode/cocoapod-to-cordova.git
#
# Targets:
#
#   build:     Builds the cocoapod target for release (ios SDKs and archs).
#              Use this for vendoring the product into the plugin.
#
#   build-sim: Builds the cocoapod target for use in the ios simulator.
#              Use this for developing with the ios simulator.
#

default: build

pod: clean
	pod install --no-integrate

build: pod
	cd Pods && xcodebuild -configuration Release -target $(shell head -n 1 build_target_name.txt)
	mv $(shell head -n 1 product_path.txt) $(shell head -n 1 product_path.txt)-ios
	cd Pods && xcodebuild -configuration Release -sdk iphonesimulator8.2 -target $(shell head -n 1 build_target_name.txt)
	mv $(shell head -n 1 product_path.txt) $(shell head -n 1 product_path.txt)-sim
	lipo -create $(shell head -n 1 product_path.txt)-ios $(shell head -n 1 product_path.txt)-sim -output $(shell head -n 1 product_path.txt)
	rm $(shell head -n 1 product_path.txt)-ios
	rm $(shell head -n 1 product_path.txt)-sim

build-ios: pod
	cd Pods && xcodebuild -configuration Release -target $(shell head -n 1 build_target_name.txt)

build-sim: pod
	cd Pods && xcodebuild -configuration Release -sdk iphonesimulator8.2 -target $(shell head -n 1 build_target_name.txt)

clean:
	-rm -rf Pods
	-rm Podfile.lock
	-rm build_target_name.txt
	-rm product_path.txt
