#!/bin/bash

# Variables
device="$1";
this="KaminariCM";

# Set up the cross-compiler
export PATH=$HOME/Toolchains/Uber-5.3/bin:$PATH;
export ARCH=arm;
export SUBARCH=arm;
export CROSS_COMPILE=arm-eabi-;

# Clone the custom anykernel repo
if [ ! -d ../Custom_AnyKernel ]; then
	echo -e "Custom AnyKernel not detected. Cloning git repository...\n";	
	git clone -q -b $device"_cm" https://github.com/Kamin4ri/Custom_AnyKernel ../Custom_AnyKernel;
else
	cd ../Custom_AnyKernel;
	git checkout -q $device"_cm";
	cd ../$this;
fi;

# Output some basic info
echo -e "Building KaminariKernel (CyanogenMod/AOSP version)...";
if [ $device = "falcon" ]; then
	echo -e "Device: Moto G (falcon)";
	device2="Falcon";
	defconfig="falcon_defconfig";
elif [ $device = "peregrine" ]; then
	echo -e "Device: Moto G 4G (peregrine)";
	device2="Peregrine";
	defconfig="peregrine_defconfig";
elif [ $device = "titan" ]; then
	echo -e "Device: Moto G 2nd Gen (titan)";
	device2="Titan";
	defconfig="titan_defconfig";
elif [ $device = "thea" ]; then
	echo -e "Device: Moto G 2nd Gen with LTE (thea)";
	device2="Thea";
	defconfig="titan_defconfig";
else
	echo -e "Invalid device. Aborting.";
	exit 1;
fi;

if [ $2 ]; then
	if [ $2 = "clean_full" ]; then
		echo -e "No version number has been set. The build date & time will be used instead.\n";
		echo -e "The output of previous builds will be removed.\n";
		echo -e "Build started on: `date +"%A, %d %B %Y @ %H:%M:%S %Z (GMT %:z)"`\n";
		if [ $3 ]; then
			echo -e "Number of parallel jobs: $3\n";
		else
			echo -e "Number of parallel jobs: 3\n";
		fi;
		make clean && make mrproper;
	elif [ $2 = "clean" ]; then
		echo -e "No version number has been set. The build date & time will be used instead.\n";
		echo -e "The output of previous builds will be removed.\n";
		echo -e "Build started on: `date +"%A, %d %B %Y @ %H:%M:%S %Z (GMT %:z)"`\n";
		if [ $3 ]; then
			echo -e "Number of parallel jobs: $3\n";
		else
			echo -e "Number of parallel jobs: 3\n";
		fi;
		make clean;
	else
		if [ $2 != "none" ]; then
			version="$2";
			echo -e "Version: "$version"\n";
			if [ $3 ]; then
				if [ $3 = "clean_full" ]; then
					echo -e "The output of previous builds will be removed.\n";
					echo -e "Build started on: `date +"%A, %d %B %Y @ %H:%M:%S %Z (GMT %:z)"`\n";
					if [ $4 ]; then
						echo -e "Number of parallel jobs: $4\n";
					else
						echo -e "Number of parallel jobs: 3\n";
					fi;
					make clean && make mrproper;
				elif [ $3 = "clean" ]; then
					echo -e "The output of previous builds will be removed.\n";
					echo -e "Build started on: `date +"%A, %d %B %Y @ %H:%M:%S %Z (GMT %:z)"`\n";
					if [ $4 ]; then
						echo -e "Number of parallel jobs: $4\n";
					else
						echo -e "Number of parallel jobs: 3\n";
					fi;
					make clean;
				fi;
			fi;
		else
			echo -e "No version number has been set. The build date & time will be used instead.\n";
			echo -e "Build started on: `date +"%A, %d %B %Y @ %H:%M:%S %Z (GMT %:z)"`\n";
			if [ $3 ]; then
				echo -e "Number of parallel jobs: $3\n";
			else
				echo -e "Number of parallel jobs: 3\n";
			fi;
		fi;
	fi;
else
	echo -e "No version number has been set. The build date & time will be used instead.\n";
	echo -e "Build started on: `date +"%A, %d %B %Y @ %H:%M:%S %Z (GMT %:z)"`\n";
fi;

# Build the kernel
make kaminari/$defconfig;

if [ "$2" = "clean" -o "$2" = "clean_full" ]; then
	if [ $3 ]; then	
		make -j$3 CONFIG_NO_ERROR_ON_MISMATCH=y;
	else
		make -j3 CONFIG_NO_ERROR_ON_MISMATCH=y;
	fi;
else
	if [ $4 ]; then	
		make -j$4 CONFIG_NO_ERROR_ON_MISMATCH=y;
	else
		make -j3 CONFIG_NO_ERROR_ON_MISMATCH=y;
	fi;
fi;

# Tell when the build was finished
echo -e "Build finished on: `date +"%A, %d %B %Y @ %H:%M:%S %Z (GMT %:z)"`\n";
	
# Set the build date & time after it has been completed
builddate=`date +%Y%m%d.%H%M%S`;
builddate_full=`date +"%d %b %Y | %H:%M:%S %Z"`;

zipdir="zip_"$device"_cm";
outdir="release_"$device"_cm";

# Make the zip dir if it doesn't exist
if [ ! -d ../$zipdir ]; then
	mkdir ../$zipdir;	
	cp -rf ../Custom_AnyKernel/* ../$zipdir;
fi;

# Make the release dir if it doesn't exist
if [ ! -d ../$outdir ]; then mkdir ../$outdir; fi;

# Copy zImage and create dtb file from device tree blobs
cp -f arch/arm/boot/zImage ../$zipdir/;
if [ "$device" = "falcon" ]; then
	cat arch/arm/boot/msm8226-bigfoot-p1.dtb arch/arm/boot/msm8226-falcon-p1.dtb arch/arm/boot/msm8226-falcon-p2.dtb arch/arm/boot/msm8226-falcon-p2-v2.dtb arch/arm/boot/msm8226-falcon-p2b.dtb arch/arm/boot/msm8226-falcon-p2b1.dtb arch/arm/boot/msm8226-falcon-p3c.dtb > ../$zipdir/dtb;
elif [ "$device" = "peregrine" ]; then
	cat arch/arm/boot/msm8926-peregrine-p1.dtb arch/arm/boot/msm8926-peregrine-p1c.dtb arch/arm/boot/msm8926-peregrine-p2.dtb arch/arm/boot/msm8926-peregrine-p2a1.dtb arch/arm/boot/msm8926-peregrine-p2d.dtb > ../$zipdir/dtb;
elif [ "$device" = "titan" -o "$device" = "thea" ]; then
	cat arch/arm/boot/msm8226-titan-4b.dtb arch/arm/boot/msm8226-titan-4c.dtb arch/arm/boot/msm8226-titan-4d.dtb arch/arm/boot/msm8226-titan-4e.dtb arch/arm/boot/msm8226-titan-4f.dtb arch/arm/boot/msm8926-thea-p1a.dtb arch/arm/boot/msm8926-thea-p1c.dtb arch/arm/boot/msm8926-thea-p2.dtb arch/arm/boot/msm8926-thea-p3.dtb > ../$zipdir/dtb;
fi;
ls -l ../$zipdir/zImage && ls -l ../$zipdir/dtb;
cd ../$zipdir;

# Set zip name
case $version in
	"" | " ")
		# In case the version number hasn't been specified, use the build date and time instead.
		zipname="KaminariCM_"$builddate"_"$device2;
	;;
	*)
		zipname="KaminariCM_v"$version"_"$device2;
	;;
esac;

# Make the zip
if [ $version ]; then
	echo "Version: $version" > version.txt;
else
	echo "Build date and time: $builddate_full" > version.txt;
fi;
zip -r9 $zipname.zip * > /dev/null;
mv $zipname.zip ../$outdir;
