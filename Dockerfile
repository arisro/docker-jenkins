FROM ubuntu:14.04

RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse" > /etc/apt/sources.list; \
	echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list; \
	echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list; \
	echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update; \
	apt-get -qq install wget

RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add - > /dev/null 2>&1; \
	echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list

RUN export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get -qq install curl git ant jenkins

ADD ./jenkins_configure.sh /jenkins_configure.sh
ADD ./wait4jenkins.sh /wait4jenkins.sh

RUN sh /jenkins_configure.sh

#RUN mkdir -p /home/jenkins/composerbin && chown -R jenkins:jenkins /home/jenkins; \
#	sudo -H -u jenkins bash -c ' \
#		curl -sS https://getcomposer.org/installer | php -- --install-dir=/home/jenkins/composerbin --filename=composer;'; \
#	ln -s /home/jenkins/composerbin/composer /usr/local/bin/; \
#	sudo -H -u jenkins bash -c ' \
#		export COMPOSER_BIN_DIR=/home/jenkins/composerbin; \
#		export COMPOSER_HOME=/home/jenkins;'


RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -; \
	apt-get -qq install nodejs; \
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -; \
	echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list; \
	apt-get update; \
	apt-get -qq install yarn

RUN echo "service jenkins start" >> /run_all.sh; \
	echo "tail -f /var/log/jenkins/jenkins.log;" >> /run_all.sh

EXPOSE 8080

CMD ["sh", "/run_all.sh"]
