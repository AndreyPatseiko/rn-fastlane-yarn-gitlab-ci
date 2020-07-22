FROM openjdk:8

LABEL maintainer "andrey.patseiko@gmail.com"

ENV DEBIAN_FRONTEND noninteractive


################################################################################################
###
### Environment variables
###
# Android & Gradle
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-6.4.1-all.zip
ENV GRADLE_HOME /usr/local/gradle-6.4.1/bin
ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_SDK_COMPONENTS_LATEST platform-tools,build-tools-23.0.1,build-tools-25.0.3,android-23,android-25,extra-android-support,extra-android-m2repository,extra-google-m2repository
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Install utils
RUN apt update && apt install curl wget -y

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_current.x | bash - \
	&& apt-get install -y nodejs \ 
	&& node -v

#Ruby
RUN apt-get install ruby-full -y

ENV RUBY_MAJOR 2.5
ENV RUBY_VERSION 2.5.1
ENV RUBY_DOWNLOAD_SHA256 886ac5eed41e3b5fc699be837b0087a6a5a3d10f464087560d2d21b3e71b754d
ENV RUBYGEMS_VERSION 3.0.6
ENV BUNDLER_VERSION 1.15.3

# Download & Install Gradle
#RUN cd /usr/local
#RUN wget $GRADLE_URL
#RUN unzip gradle-6.4.1-all.zip
#RUN rm gradle-6.4.1-all.zip
#RUN ln -s /usr/local/gradle-6.4.1/bin/gradle /usr/bin/gradle
RUN apt-get install gradle -y

# Download Android SDK
ENV SDK_URL "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ENV ANDROID_HOME "/usr/local/android-sdk"
ENV ANDROID_VERSION 28
ENV ANDROID_BUILD_TOOLS_VERSION 27.0.3

RUN mkdir "$ANDROID_HOME" \
    && mkdir /root/.android \
    && cd "$ANDROID_HOME" \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip \
    && touch /root/.android/repositories.cfg \
    && echo "### User Sources for Android SDK Manager" >/root/.android/repositories.cfg \
    && echo "# $(date)" >>/root/.android/repositories.cfg

#ENV JAVA_OPTS "-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee"

RUN mkdir "$ANDROID_HOME/licenses" || true \
    && echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$ANDROID_HOME/licenses/android-sdk-license" \
    && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses


# Install Android Build Tool and Libraries
RUN $ANDROID_HOME/tools/bin/sdkmanager --update > /dev/null
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
# \
#    "platforms;android-${ANDROID_VERSION}" \
#    "platform-tools"

# Install Build Essentials
RUN apt-get update && apt-get install build-essential -y && apt-get install file -y && apt-get install apt-utils -y


################################################################################################
###
### Install yarn
###

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	apt update && \
	apt install yarn
	

################################################################################################
###
### Install Fastlane and plugins
###

RUN apt-get install make -y \
	&& apt-get install gcc -y \
	&& apt-get install g++ -y
RUN apt-get install build-essential -y
RUN apt-get install libxml2-dev libsqlite3-dev zlib1g-dev liblzma-dev -y

RUN gem install fastlane -v 2.129.0
RUN gem install fastlane-plugin-appicon
RUN gem install fastlane-plugin-android_change_string_app_name
RUN gem install fastlane-plugin-humanable_build_number
RUN gem update --system "$RUBYGEMS_VERSION"


# Output versions
RUN echo "node -v" && node -v && echo "npm -v" && npm -v && echo "ruby -v" && ruby -v && echo "yarn --version" && yarn --version && echo "gradle -v" && gradle -v

RUN echo "PATH - $PATH"
