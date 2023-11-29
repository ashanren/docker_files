FROM centos:7

# http://bundler.io/man/bundle-config.1.html
ENV                 GEM_HOME=/usr/local/rubygems \
                    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
                    BUNDLE_PATH=/usr/local/rubygems \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
                           PATH="/usr/local/rubygems/bin:$PATH"

RUN yum -y update

 # Install CentOS Linux Software Collections release file.
RUN yum -y install centos-release-scl \
 \
 # Install build tools.
 && yum -y install which file devtoolset-7-gcc devtoolset-7-make \
 \
 # Install system GCC compiler and make in order to allow native gem extensions to compile.
 && yum -y install gcc make \
 \
 # Enable EPEL repository (required to install jemalloc-devel) and update packages.
 && yum -y install epel-release \
 && yum -y update

# Install Ruby dependencies.
RUN yum -y install openssl-devel libyaml-devel readline-devel zlib-devel gdbm-devel ncurses-devel jemalloc-devel libffi-devel rpm-build ruby-devel zlib-devel libxml2* mysql-devel

# Install Java
RUN yum -y install java-1.8.0-openjdk* nodejs \
 \
&& { echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# Install mysql
RUN yum -y install wget \
 && wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm \
 && rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 \
 && rpm -ivh mysql57-community-release-el7-9.noarch.rpm \
 && yum -y install mysql-server mariadb-libs

#Install RVM
#RUN gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
 && curl -sSL https://get.rvm.io | bash -s stable \
 && /bin/bash -l -c "/etc/profile.d/rvm.sh && rvm install 2.4.1"

#Install General Dependencies
RUN yum -y install vim git \
  && yum  install -y yum-utils \
  && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
  && yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \

# Cleanup.
RUN cd / \
# && rm -rf /tmp/ruby* \
 && yum clean all \
 && rm -rf /var/cache/yum

ENTRYPOINT ["/bin/bash"]
