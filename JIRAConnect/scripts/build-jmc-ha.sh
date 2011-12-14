#!/bin/bash

echo "................................................................................"
mkdir -p output
cd output
echo "Pulling HockeySDK from GitHub"
if [ -d "HockeySDK" ]; then
	cd HockeySDK
	git pull
	cd ..
else
	git clone https://github.com/codenauts/HockeySDK-iOS HockeySDK
fi

echo "................................................................................"
echo "Pulling JMC from BitBucket"
if [ -d "JMC" ]; then
	cd JMC
	hg pull
	hg update
	cd ..
else
	hg clone https://bitbucket.org/atlassian/jiraconnect-ios JMC
fi

echo "................................................................................"
if [ -d JMC+Hockey ]; then
	echo "Deleting existing release dir."
	rm -rf JMC+Hockey;
fi

echo "Creating new release dir."
mkdir JMC+Hockey
mkdir JMC+Hockey/External
mkdir JMC+Hockey/Hockey
mkdir JMC+Hockey/JMC
mkdir JMC+Hockey/Support

echo "Copying files from HockeySDK."
cp HockeySDK/LICENSE.txt JMC+Hockey/Hockey
cp -R HockeySDK/Classes JMC+Hockey/Hockey
cp -R HockeySDK/Resources JMC+Hockey/Hockey
cp -R HockeySDK/Vendor/CrashReporter.framework JMC+Hockey/External

echo "Copying files from JMC."
cp -R JMC/JIRAConnect/JMCClasses/Base JMC+Hockey/JMC
cp -R JMC/JIRAConnect/JMCClasses/Core JMC+Hockey/JMC
cp -R JMC/JIRAConnect/JMCClasses/Resources JMC+Hockey/JMC
cp -R JMC/JIRAConnect/JMCClasses/LICENSES JMC+Hockey/JMC
cp -R JMC/JIRAConnect/JMCClasses/Libraries/Reachability JMC+Hockey/Support
cp -R JMC/JIRAConnect/Support/SBJSON JMC+Hockey/Support

echo "Deleting any git, hg or svn directories."
find . -type d -name .svn exec rm -rf {} \;
find . -type d -name .git exec rm -rf {} \;
find . -type d -name .hg exec rm -rf {} \;

echo "................................................................................"
echo "Zipping release directory."
zip -r JMC+Hockey.zip JMC+Hockey

echo "Done."
